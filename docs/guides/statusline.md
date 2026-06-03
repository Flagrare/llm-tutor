# Statusline integration

You've installed llm-tutor and you want your tier, cycles balance, and active topic visible without running `/tutor-status` every minute. This guide walks the install, the icon modes, the toggle, and the uninstall — plus the escape hatch for using llm-tutor's segment renderer in a non-Claude-Code statusline.

The integration works alongside **whatever statusline you're already running** — claude-statusline, a custom shell script, none at all. It wraps your existing `statusLine.command` instead of replacing it, so your current statusline keeps rendering and llm-tutor's segment shows up as an extra row beneath. For the design rationale behind that wrapper pattern, see [`docs/decisions/2026-06-03-statusline-integration-architecture.md`](../decisions/2026-06-03-statusline-integration-architecture.md).

## Install

```
/tutor-statusline-install
```

The installer saves your current `~/.claude/settings.json` `statusLine.command` (whatever it is) to `~/.claude/llm-tutor/wrapped-statusline.json` and swaps in a thin wrapper. Each render, the wrapper pipes Claude Code's status JSON to your original command and captures its stdout — so your existing statusline still renders — then appends llm-tutor's segment as an additional row.

A typical result with claude-statusline below: two original rows on top, llm-tutor's row appended in the active teacher's signature color.

```
claude-opus-4-7  │  🧠  high              📂 my-repo  🌿 main ~+ ↑2  │  ctx: [████░░░░░░] 38%
                                                       5h:42% 🔥 [1h20m]  │  7d:8% 🍃 [3d4h]  │  $1.23
🎙  ECHO · 🏷  Booted ▰▱▱▱▱ · ⚡  4/5 · 📖  python-decorators ▰▰▱▱▱
```

The persona label (`ECHO` / `CIPHER` / `VEX`) plus accent color is the row's signature — it owns its line instead of blending into the rest of the statusline. XP-toward-next-tier and concept-progress render as 5-cell bars; cycles glow yellow when only one is left.

## Toggle

To hide the segment without uninstalling:

```
/tutor-statusline-toggle off    # wrapper still runs, segment hidden
/tutor-statusline-toggle on     # segment back
/tutor-statusline-toggle        # cycle between
```

When off, the wrapper passes the original statusline through unchanged. Useful for screen-sharing, recording, or any time you want the row out of the way without unwiring the integration.

## Icons

Four icon modes mirror claude-statusline's pattern so the llm-tutor row matches the aesthetic of the host statusline:

```
/tutor-statusline-icons              # cycle: emoji → nerd → unicode → ascii → emoji
/tutor-statusline-icons nerd         # set explicit mode
```

| Mode | Persona avatar | Tier | Bolt | Topic | Bar cells |
|---|---|---|---|---|---|
| `emoji` (default) | 🎙 | 🏷 | ⚡ | 📖 | ▰▱ |
| `nerd` | `nf-md-school` | `nf-md-trophy-outline` | `nf-fa-bolt` | `nf-fa-book` | ▰▱ |
| `unicode` | ※ | ✦ | ⚡ | ▷ | ▰▱ |
| `ascii` | `[E]` / `[C]` / `[V]` / `[T]` | `^` | `*` | `>` | `#-` |

The choice persists in `~/.claude/llm-tutor/statusline.conf`. Nerd-mode glyphs require a Nerd Font in your terminal; the other three modes work anywhere.

## Tuning the topic-name truncation

The active topic's display name renders in the segment as `📖 <name>`. By default we truncate names longer than 40 characters with an ellipsis (`…`); this is a safety net for pathological cases (60+ character subjects), since the wrapped statusline competes with itself for row width.

If you want different behavior, edit `~/.claude/llm-tutor/statusline.conf` and add a line:

```
SLUG_MAX_LEN=0     # no truncation; render the full name regardless of length
SLUG_MAX_LEN=60    # truncate at 60 characters instead of 40
SLUG_MAX_LEN=20    # tight cap for narrow terminals
```

A garbled value silently falls back to no truncation rather than erroring — the statusline isn't a place to fail loudly.

## Uninstall

```
/tutor-statusline-uninstall
```

Restores your original `statusLine.command` byte-for-byte. Your tutoring progress (XP, cycles, topics) stays intact — only the wrapper plumbing is removed. If you reinstall later, the saved-original is still there to wrap.

## How it stays decoupled

The wrapper-based design has four properties worth knowing about, especially if you're debugging an edge case or thinking about extending the integration.

`settings.json` references `~/.claude/llm-tutor/statusline-wrapper.sh`, which is a six-line bash **shim** written once by `/tutor-statusline-install`. Each render, the shim runs `ls | sort -V | tail -1` against the plugin's cache directory to find the latest installed version, then `exec`s *that version's* wrapper. So a `/plugin update llm-tutor + /reload-plugins` is sufficient — the next statusline render picks up the new version automatically, no install rerun, no session restart. (Earlier versions used a symlink that was refreshed by a `SessionStart` hook; that approach left a stale-render window when users updated mid-session. v0.4.1 replaced it with the shim.)

The wrapper is silent on failure. If your original command goes missing — for instance, you uninstalled claude-statusline without uninstalling llm-tutor's wrapper first — the wrapper degrades to llm-tutor's segment alone rather than producing a blank statusline. You see a visibly degraded statusline, not a broken one.

Re-installing is a no-op. The installer detects an already-wrapped statusline and refuses to double-wrap, which would otherwise produce `Wrapper(Wrapper(Original))` and recurse on uninstall.

Persona color is read at render time, not at install time. The wrapper extracts `output_style.name` from Claude Code's status JSON on every render, so switching teachers via `/config` updates the row's color immediately — no need to re-run install.

## Using the renderer directly (non-Claude-Code statuslines)

If you've built your own statusline outside Claude Code — a tmux right-status line, a fish prompt, a starship segment — you can shell out to llm-tutor's segment renderer directly:

```bash
~/.claude/llm-tutor/statusline-segment.sh            # default: ANSI + emoji ⚡
~/.claude/llm-tutor/statusline-segment.sh --plain    # ASCII, no color
~/.claude/llm-tutor/statusline-segment.sh --json     # raw signals for custom formatting
```

The symlink at that stable path is created by `/tutor-statusline-install`, so run install once first even if you're not going to use the wrapper itself. The segment exits silently (empty output, exit 0) when no tutoring session is active, so unconditional wiring is safe.
