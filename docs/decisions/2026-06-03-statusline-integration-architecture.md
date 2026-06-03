# Statusline Integration Architecture

- **Date:** 2026-06-03
- **Status:** accepted
- **Informs:** [`plugins/llm-tutor/scripts/statusline-{wrapper,install,segment,icons,toggle,uninstall}.sh`](../../plugins/llm-tutor/scripts/), the `SessionStart` refresh-symlinks hook, the four `/tutor-statusline-*` user commands.

## Context

llm-tutor needs to surface tier, cycles, and current-topic progress in the user's Claude Code statusline. Claude Code's statusline mechanism is a single command — `~/.claude/settings.json`'s `statusLine.command` field — that runs on every render and emits one line of text to stdout. Whatever the user already has there (`claude-statusline`'s `statusline.sh`, a custom shell script, nothing at all), that single command is the only path text reaches the statusline.

That fact forces a question with two parts.

First: **how does llm-tutor's segment reach the statusline at all?** llm-tutor cannot just "publish" a rendered line, because there's no statusline-side wiring to read it. Something has to *compose* llm-tutor's segment with whatever else the user wants visible.

Second: **where does the rendering logic live?** In llm-tutor (good for schema evolution, requires a stable rendering contract), in `claude-statusline` (couples the two repos and excludes users on other statusline schemes), or split (a fragile shared format that decays).

The plugin's architectural constraint applies. From [the gamification ADR](./2026-06-02-tutor-start-and-gamification.md): *llm-tutor depends only on standard Claude Code primitives.* No hard dependency on `claude-statusline`, no shared library, no "install these two first." A user with a custom statusline who installs only llm-tutor should get the integration. A user with `claude-statusline` who chooses never to install llm-tutor should be unaffected.

## D1 — Wrap the existing statusline rather than coexist with it

**Decision:** `/tutor-statusline-install` replaces the user's `statusLine.command` with a llm-tutor wrapper script, after saving the original. The wrapper feeds Claude Code's stdin to the saved original, captures its stdout, and appends llm-tutor's segment as an extra row. `/tutor-statusline-uninstall` restores the saved original byte-for-byte.

The shape:

```
Claude Code ──stdin──▶  llm-tutor-wrapper.sh  ──┬──▶ run wrapped original ──▶ original output
                                                └──▶ run segment renderer ──▶ llm-tutor row
                                              concatenate, emit to stdout
```

### What we considered and rejected

*Asking the user to wire the segment into their own statusline.* This is the lowest-coupling option, and the one this skill spent the longest considering. It fails on friction. The user would need to: discover that llm-tutor ships a segment script, find a stable path that survives plugin version bumps (the cache directory has a version number in it), edit their statusline (which they may not have written — `claude-statusline`'s `statusline.sh` is a download, not a local file the user authored), and re-edit on every plugin update. The result: most users never wire it, the gamification surface stays hidden, and the cycles/XP system feels optional in a way that suppresses engagement entirely. The gamification only works when the user can see their progress without asking for it.

*Asking `claude-statusline` to add a `SHOW_TUTOR` flag and read llm-tutor's state directly.* This was the initial implementation (a `claude-statusline` v2.5.0 draft that was never shipped). It works only for `claude-statusline` users; users on other statuslines get nothing. It also couples the two repos' release cycles: any change to llm-tutor's `state.json` schema, or to the tier thresholds, requires a coordinated `claude-statusline` release. We backed out the draft and reset.

*Pre-rendering the segment to a known file every N seconds; user's statusline reads the file.* This requires user-side wiring (same as the first alternative) and introduces a write/read race the segment renderer would need to handle with atomic writes. More mechanism, same friction problem.

The wrapper pattern is unusual for Claude Code plugins. The standard plugin shape — slash commands, hooks, skills — doesn't compose across plugins on shared output channels, because there are very few shared output channels in the harness. The statusline is one of them, and there is no built-in composition story. Wrapping is what makes composition possible without forcing the user to *be* the composer.

### Trade-offs we accept

The wrapper runs every render alongside the original command. Whatever the original cost was, the wrapper cost is at least that plus our segment renderer (one `jq` call and a tier lookup — single-digit milliseconds on a warm cache). Acceptable.

The wrapper mutates `settings.json`, which is a user-owned file. The install script saves the original `statusLine` block to `~/.claude/llm-tutor/wrapped-statusline.json` before mutating, and `/tutor-statusline-uninstall` restores it verbatim. Idempotency on re-install is enforced by detecting our wrapper symlink in the current `command` field; if it's already there, we no-op rather than re-wrap. Without that check we'd produce `Wrapper(Wrapper(Original))` and recurse on uninstall.

If the user removes `claude-statusline` (or whichever original was wrapped) without first running `/tutor-statusline-uninstall`, the wrapper's saved-original command points at a missing file. The wrapper degrades to emitting only llm-tutor's segment — visibly degraded, but not blank, and the user has a clear signal that something on their end needs fixing.

## D2 — Rendering logic lives in llm-tutor, not in any statusline

**Decision:** All segment rendering — the tier-name table, `jq` queries against `state.json`, glyph maps for the four icon modes, persona color application, the two progress bars — lives in `plugins/llm-tutor/scripts/statusline-segment.sh`. No statusline reproduces any of llm-tutor's data model.

### Why we don't duplicate the tier table in `claude-statusline`

The first draft did. The thresholds (`Greenhorn @ 0 XP`, `Booted @ 75`, …) were hardcoded in `claude-statusline`'s `statusline.sh`. The problem surfaced within the same session: any change to the tier table — adding a tier, renaming one, adjusting a threshold — would require a coordinated release across both repos. So would any change to `state.json`'s shape. We want to be able to evolve tiers and schema without breaking the statusline render.

The segment script is the contract. `claude-statusline` does not know how llm-tutor stores XP, what the tier names are, or what the icon modes look like. It knows only one thing: calling `~/.claude/llm-tutor/statusline-segment.sh` returns a single rendered line of statusline text. Schema evolution stays inside llm-tutor.

The same boundary makes the wrapper work with any host statusline. A user on a bespoke statusline doesn't have to vendor in llm-tutor's tier table to get the integration. They get whatever the segment script emits today, including any tier additions or visual changes that ship in future llm-tutor releases.

### Trade-offs we accept

The segment script becomes a runtime dependency the wrapper must locate. v0.2.0–v0.4.0 handled this with two symlinks under `~/.claude/llm-tutor/` pointing into the versioned plugin cache, refreshed by a `SessionStart` hook. That worked but exposed a gap: `/plugin update` followed by `/reload-plugins` does *not* fire a `SessionStart` event, so a user who updated mid-session kept seeing the previously-cached version's render until they restarted Claude Code or re-ran `/tutor-statusline-install`. We hit this in v0.3.0 → v0.4.0 testing.

v0.4.1 replaced the symlink approach with a self-locating **shim**. `/tutor-statusline-install` writes a six-line bash file (not a symlink) at `~/.claude/llm-tutor/statusline-wrapper.sh` that, on every render, runs `ls | sort -V | tail -1` against `~/.claude/plugins/cache/llm-tutor/llm-tutor/` to find the highest-semver-sorted cache directory, then `exec`s that directory's `statusline-wrapper.sh`. The shim itself never changes; the wrapper logic in the cache self-updates with every plugin upgrade. `/plugin update llm-tutor + /reload-plugins` is now sufficient — no install rerun, no session restart, no `SessionStart` hook. The wrapper script in the cache, in turn, resolves `SEGMENT_SH` via its own `${BASH_SOURCE[0]}` directory, so it always finds the latest segment renderer as well; and it lazily refreshes the segment symlink in `$STATE_DIR` so direct shell-out users (the path documented in the statusline guide for non-Claude-Code statuslines) also see the current version.

The wrapper-to-segment contract is "exec the script, capture stdout." Simpler than a shared library, but less typed — there's no compile-time check that the segment script accepts the env vars the wrapper passes (`LLM_TUTOR_PERSONA`, plus `ICONS` honored from the conf file). We mitigate via documented contract: the wrapper passes `LLM_TUTOR_PERSONA` and reads stdout, nothing else. Integration smoke tests cover the four icon modes and the three persona variants.

## What's still open

*Segment placement.* The wrapper appends llm-tutor's segment as a row beneath the wrapped original's output. Some users might prefer left-of-original, right-aligned, or inline. We do not expose a `LLM_TUTOR_PLACEMENT` knob today. The single `printf "%s\n%s" "$original" "$segment"` line in `statusline-wrapper.sh` is the only thing that has to change if we add one.

*Multiple wrapping plugins competing for the row.* If another plugin ships its own wrapping installer, install order determines composition order, and uninstall is order-sensitive. We've documented this in the install script comments. We have not built a registry that arbitrates across wrapping plugins, because no other plugin currently uses this pattern. If a second one ships, we'll need one.

*Self-healing under plugin uninstall.* If the user uninstalls the llm-tutor plugin without first running `/tutor-statusline-uninstall`, the shim's `ls` against the cache directory returns empty and the shim exits silently — settings.json still points at the wrapper path, but no segment renders. We don't detect-and-prompt this case. A wrapper-side check could surface a one-line "llm-tutor plugin is gone, run /tutor-statusline-uninstall to clean up" warning, but that's intrusive for a rare event and would be the wrong place to fail loudly anyway. Deferred.

*Migration from pre-v0.4.1 installs.* Users who installed under the symlink model (v0.2.0–v0.4.0) keep their old symlink wrapper until they re-run `/tutor-statusline-install` once, which overwrites the symlink with the shim. After that single migration, all future upgrades self-heal without action. The v0.4.1 release notes flag this; `/tutor-update` could detect-and-prompt this state, but we haven't built that detection yet.
