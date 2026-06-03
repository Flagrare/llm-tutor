# Roadmap

The README's Status line is the one-word maturity claim. This is the full ledger — what's shipped, what's next, and what's been considered but not committed to.

## Shipped

### v0.1.0 — Core tutoring
- Three personas with anti-dependency philosophy (Echo / Cipher / Vex), each varying along voice, pedagogy, and framing.
- Locked design decisions for calibration depth, path-surfacing format, state schema, feedback flow, and the rotating-question bank ([`docs/decisions/2026-06-02-tutor-start-and-gamification.md`](./decisions/2026-06-02-tutor-start-and-gamification.md)).
- `state.json` schema with a CLI helper (`scripts/state.sh`) for get/set/add/refill-cycles.
- `UserPromptSubmit` hook for daily cycles refill — silent and idempotent.
- `/tutor-start <subject>` — generates a 5–8 concept learning path, runs a 3-turn calibration, charges cycles, branches novice or intermediate, hands off to the active persona.
- `/tutor-done` — XP from per-concept first-attempt quality, hybrid feedback flow (thumbs + a targeted rotating question with cycles rewards), feedback logged for later analysis.
- `/tutor-path` — render the learning path on demand with state markers and dependency annotations (internal-by-default).
- `/tutor-status` — dashboard showing XP, cycles balance with refill ETA, active topics with progress, completed topics with XP earned, lifetime stats.
- `/tutor-resume` — pick up a paused topic with a brief orientation and hand off to the persona.
- `/tutor-codebase <path>` — codebase-grounded tutoring with file-anchored concepts (the distinctive value vs. commercial LLM tutors).
- `/tutor-project` — convenience wrapper for `/tutor-codebase .` (tutor on the current working directory).

### v0.2.0 — Statusline integration (initial)
- Wrapper-based statusline integration that works with any Claude Code statusline (claude-statusline, custom shell script, none at all). Saves the user's original `statusLine.command` and swaps in a thin wrapper.
- `/tutor-statusline-install`, `/tutor-statusline-toggle`, `/tutor-statusline-uninstall`.

### v0.3.0 — Statusline visual redesign
- Persona-colored row (Echo cyan, Cipher purple, Vex red-orange, no-persona neutral). Wrapper extracts `output_style.name` from Claude Code's status JSON on each render.
- XP-toward-next-tier and concept-progress rendered as 5-cell bars instead of N/M fractions.
- Cycles balance glows yellow when ≤ 1 (warns before the next `/tutor-start` would fail).
- `/tutor-statusline-icons` — four icon modes (emoji, nerd, unicode, ascii) mirroring claude-statusline's pattern.
- Install output shows a persona-aware preview before the user restarts.
- `SessionStart` hook self-heals the wrapper symlinks across plugin upgrades.
- Architectural rationale captured in [`docs/decisions/2026-06-03-statusline-integration-architecture.md`](./decisions/2026-06-03-statusline-integration-architecture.md).

### v0.4.0 — Update check
- `/tutor-update` — compares the installed plugin-cache version against the latest GitHub release, prints the release notes inline when a newer version is out, and surfaces the two commands needed to upgrade.

### v0.4.1 — Self-locating wrapper (durability)
- `/tutor-statusline-install` now writes a small bash **shim** at `~/.claude/llm-tutor/statusline-wrapper.sh` instead of a symlink. Each render, the shim self-locates the latest plugin cache version and execs its wrapper.
- `/plugin update llm-tutor` followed by `/reload-plugins` is now sufficient to see new statusline behavior — no `/tutor-statusline-install` rerun, no session restart. Closes the gap where mid-session plugin upgrades produced stale renders until next restart.
- Wrapper lazily refreshes the segment symlink (`~/.claude/llm-tutor/statusline-segment.sh`) so direct shell-out users (the path documented in [`docs/guides/statusline.md`](./guides/statusline.md)) also see the latest version's output.
- `SessionStart` hook removed — the self-locating shim makes it redundant.
- Migration: users on v0.2.0–v0.4.0 should re-run `/tutor-statusline-install` once to upgrade to the shim. After that, all future upgrades self-heal.

### v0.5.0 — Human topic names, separator rule, configurable truncation
- **Topics carry a `display_name`** alongside their slug. `/tutor-start "What closures are in Python"` now stores both — the slug `what-closures-are-in-python` stays as the state key, and `"What closures are in Python"` renders in the statusline. Mixed case, spaces, reads as the question you asked rather than a path-style identifier. Backward compatible: topics created before this release continue to render their slug.
- **Dim full-width separator rule** between the host statusline and llm-tutor's row when the wrapper has an original to append below. Signals "this is a separate section" so the eye doesn't read it as a third row of the host's content. Width auto-detects via `$COLUMNS` → `tput cols` → 80. Mode-aware: `─` for emoji/nerd/unicode, `-` for ascii.
- **Truncation default bumped from 20 to 40 chars**, with a new `SLUG_MAX_LEN` knob in `~/.claude/llm-tutor/statusline.conf`. Set it to `0` to disable truncation entirely, or any positive integer to set a custom cap. Most real subjects render full-width by default now.

### v0.5.1 — display_name reaches /tutor-status and /tutor-resume
- `/tutor-status` now renders the dashboard with human display names instead of slugs. Active and completed topic rows show the subject you typed at `/tutor-start`, not the kebab-cased key.
- `/tutor-resume` uses the display name in its orientation message ("Resuming Python decorators." instead of "Resuming python-decorators.") and accepts the display name or a substring of it when disambiguating between multiple active topics — you no longer have to remember the exact slug.
- Backward compatible: topics created before v0.5.0 still render their slug-key, since they have no `display_name` to fall back to.

## In flight

- **Plugin marketplace publishing.** Topic tags applied to the GitHub repo (`claude-code-plugin`, `claude-code`, etc.), `claude plugin validate --strict` passes on both the plugin and marketplace manifests, submission filed to Anthropic's `claude-plugins-community` channel on 2026-06-03 via `claude.ai/settings/plugins/submit`. Awaiting review (timeline undocumented; expect weeks). Once approved, the plugin becomes installable via `/plugin install llm-tutor@claude-community` and the [discoverable catalog at the GitHub mirror](https://github.com/anthropics/claude-plugins-community) syncs nightly.
- Follow-up after approval: PRs to [`hesreallyhim/awesome-claude-code`](https://github.com/hesreallyhim/awesome-claude-code) (45.6k stars) and [`ComposioHQ/awesome-claude-plugins`](https://github.com/ComposioHQ/awesome-claude-plugins) (1.7k stars) — both PR-based with table-row metadata. Deferred until the community-marketplace listing lands so the PR can cite it as a quality signal. See the [marketplace landscape research catalog](./research/2026-06-03-plugin-marketplace-landscape.md) for the full priority order.

## Considered but not committed

*(empty)*

When a feature is shipped, move its bullet from **Next** to **Shipped** under the release version it landed in. When something is considered but not committed, note it here with a one-line context so future-us doesn't relitigate the same questions.
