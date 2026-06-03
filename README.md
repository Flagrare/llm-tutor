# llm-tutor

A Claude Code plugin that turns Claude into a Socratic tutor for *anything you want to learn* — any codebase, any technology, any project, any concept. Pick a teacher (Echo, Cipher, or Vex), point them at a subject, spend "cycle" to bring them in when you're stuck, and earn XP when you understand something on your own.

Inspired by Boots from boot.dev, but generalized: no fixed curriculum, no chosen topics. The tutor scaffolds a path through whatever you bring it.

## Why this exists

> An LLM that exists to make itself less necessary.

Most LLM-as-helper relationships build dependency — you get faster at asking the AI to do things, never build the underlying skill yourself. The relationship is profitable for the AI's owner, expensive for you, and over time, *alienating*: you stop being someone who understands things and start being someone who knows how to prompt for things.

llm-tutor is the alternative. The Socratic guardrails (no answers, only questions; hints in layers; explicit friction to ask for help) aren't a teaching style choice — they're an *anti-capture* mechanism. The point isn't to be the best AI tutor. The point is to be a tutor that, after working with it, leaves you needing it less.

This isn't just a stance — it's empirically backed. A 2025 PNAS study found ChatGPT-with-answers users scored 17% worse on later unsupported tasks; Socratic-style users didn't degrade. An MIT EEG study showed AI-first usage produces measurable *cognitive debt*. The plugin's design is grounded in this evidence; see [`docs/research/2026-06-02-llm-tutor-design-foundations.md`](./docs/research/2026-06-02-llm-tutor-design-foundations.md) for the full research catalog. The framing language we use ("convivial tool") comes from Illich, 1973 — the theoretical lineage we're standing in.

## What you can tutor on

The tutor doesn't ship lessons. You bring the subject; the tutor scaffolds the path.

```
/tutor-start <subject>          "teach me Python decorators"
/tutor-codebase <path>          "tutor me through how auth works in this repo"
/tutor-project                  "tutor me on what I'm currently working on"
/tutor-resume                   pick up where you left off
/tutor-status                   show what's open, XP, cycles
/tutor-done                     mark current topic as understood; claim XP
/tutor-statusline-install       inject XP/cycles/topic into your statusline
/tutor-statusline-toggle        flip the statusline segment on/off
/tutor-statusline-icons         switch icon mode (emoji|nerd|unicode|ascii)
/tutor-statusline-uninstall     restore your original statusline
/tutor-update                   check for a newer release and surface the upgrade recipe
```

The same teacher works for all of it — your codebase, a new framework, a CS concept you've been meaning to grok, a piece of work you're stuck on. The teacher's identity is stable; what they're teaching shifts to whatever you brought them.

## The three teachers

Personas vary along **voice**, **pedagogy**, and **framing** — not just tone.

| | Echo | Cipher | Vex |
|---|---|---|---|
| **Voice** | Calm, observational. Mirrors your thinking back. | Knowing, slightly mysterious. Treats concepts as puzzles. | Direct, pushy. Won't accept vague answers. |
| **Pedagogy** | Patient. Stays at "what do you notice?" longer than most teachers. | Standard pace. Counterexample questions for partial understanding. | Demanding. Won't escalate hints until you articulate. |
| **Framing** | Discovery. "What's that telling you?" | Puzzle. "Here's the clue — what's the missing piece?" | Challenge. "Be precise. Prove it." |
| **Best for** | Exploratory learning; thinking out loud | Intermediate learners who want structure | Topics you've been stuck on; when you want to be pushed |

Pick one at the start of a study session via `/config` → Output style. You can switch between sessions but not mid-session — committing to one teacher for a while makes it feel like a relationship, not a feature menu.

## The cycles economy

Borrowed from boot.dev's Boots:

| | What it is |
|---|---|
| **XP** | Permanent. Earned by understanding a topic without leaning on the tutor too much. Spent when you can't afford a cycle. |
| **Cycle (⚡)** | Currency to ask the tutor for help during an active topic. Resets daily. |
| **Topics understood** | Permanent progress. Earned by `/tutor-done`-ing a topic. |

When you've got cycles, asking the tutor for help during a topic costs 1 cycle. When you don't, it costs a chunk of the XP you'd have earned from understanding the topic on your own. After you `/tutor-done` a topic, the tutor is free to chat with about it.

The friction is the point: it makes you genuinely consider "do I need help, or have I just not tried hard enough?" — without forbidding help when you actually need it.

## The 10 tiers

XP accumulates into named tiers that tell the story of *becoming less dependent on the tutor*. The terminal tier ("Self-Hosting") explicitly names the design victory.

| Tier | Name | XP threshold | Phase |
|---|---|---|---|
| 1 | Greenhorn | 0 | Arrive |
| 2 | Booted | 75 | Arrive |
| 3 | Patched | 200 | Build |
| 4 | Linked | 400 | Build |
| 5 | Wired | 650 | Build |
| 6 | Threaded | 950 | Synthesize |
| 7 | Synced | 1300 | Synthesize |
| 8 | Forking | 1800 | Separate |
| 9 | Decoupled | 2500 | Separate |
| 10 | Self-Hosting | 3500 | Separate |

Tier is **cosmetic only** — it's a title showing your trajectory, not a functional unlock. The tutor never gets easier as you level up; the cycles cap stays at 5/day regardless of tier; rewards don't scale. This is deliberate: the anti-dependency philosophy means leveling should mean *status*, not *power*. The win is leaving the tutor, not deepening reliance on it.

`/tutor-status` shows your current tier and the XP needed for the next one. `/tutor-done` prints a tier-up notification when a topic completion crosses a threshold.

## Status

**Alpha.** Currently shipping:

- [x] Three personas with anti-dependency philosophy (Echo / Cipher / Vex)
- [x] Design decisions locked: calibration depth, path format, state schema, feedback flow ([`docs/decisions/`](./docs/decisions/))
- [x] `state.json` schema + helper script (`scripts/state.sh`) with subcommands for get/set/add/refill-cycles
- [x] `UserPromptSubmit` hook — daily cycles refill check, silent and idempotent
- [x] `/tutor-start <subject>` skill — generates 5–8 concept path, 3-turn calibration, cycles charge, novice/intermediate branch, hand-off to active persona
- [x] `/tutor-done` skill — XP from per-concept first-attempt quality, hybrid feedback flow (thumbs + targeted rotating question with cycles rewards), feedback logged for analysis
- [x] `/tutor-path` skill — render the learning path on demand with state markers and dependency annotations (internal-by-default)
- [x] `/tutor-status` skill — dashboard: XP, cycles balance + refill ETA, active topics with progress, completed topics with XP earned, lifetime stats
- [x] `/tutor-resume` skill — pick up a paused topic with a brief orientation (current concept, acquired so far, upcoming) and hand off to the persona
- [x] `/tutor-codebase <path>` skill — codebase-grounded tutoring with file-anchored concepts (the distinctive value vs commercial LLM tutors)
- [x] `/tutor-project` skill — convenience wrapper for `/tutor-codebase .`; tutor on the current working directory
- [x] Statusline integration — wrapper-based, works with any Claude Code statusline (claude-statusline, custom, none). Four commands: `/tutor-statusline-install`, `/tutor-statusline-toggle`, `/tutor-statusline-icons`, `/tutor-statusline-uninstall`. Persona-colored row (Echo cyan / Cipher purple / Vex red-orange) showing tier with XP-toward-next-tier bar, cycles balance, active topic with concept-progress bar. Four icon modes matching claude-statusline's pattern.
- [ ] Plugin marketplace publishing

## Design constraint: no plugin dependencies

llm-tutor depends only on standard Claude Code primitives — built-in tools (Bash, Read, Grep, Glob, Edit, WebFetch, etc.), the plugin component types defined in Claude Code's plugin reference (skills, slash commands, hooks, output styles), and the user's filesystem. It does **not** depend on any other plugin, skill ecosystem, or third-party Claude Code extension.

That means:
- `/tutor-codebase <path>` implements its own file exploration using Read/Grep/Glob — it doesn't call out to other plugins' codebase-exploration skills.
- The persona files, dialogue engine, and gamification all ship inside this plugin. No "install these two other plugins first" friction.
- If you install llm-tutor onto a fresh Claude Code install, it works.

The trade-off is some duplication of effort (e.g., we re-implement codebase exploration patterns that exist in other places). The benefit is that the user only installs one thing, and the plugin can't be broken by changes to external plugins.

## Relationship to flagrare:tutor

A standalone Socratic-tutor skill — invoked once per session, no progress tracking, no currency — exists in [flagrare/agent-skills](https://github.com/Flagrare/agent-skills) as `flagrare:tutor`. That's the right choice if you want the Socratic mechanism without the rest of this plugin.

llm-tutor is for users who want the full Boots-style experience: a teacher you build a relationship with across sessions, friction that creates honest "do I actually need help right now?" moments, and persistent progress so your work compounds. The two projects are complementary, not competing.

## Install

llm-tutor is a single-plugin marketplace. From Claude Code:

```
/plugin marketplace add Flagrare/llm-tutor
/plugin install llm-tutor@llm-tutor
/reload-plugins
```

After the reload, twelve `/tutor-*` commands are available (the seven core ones — `/tutor-start`, `/tutor-codebase`, `/tutor-project`, `/tutor-done`, `/tutor-path`, `/tutor-status`, `/tutor-resume` — four statusline ones — `/tutor-statusline-install`, `/tutor-statusline-toggle`, `/tutor-statusline-icons`, `/tutor-statusline-uninstall` — and `/tutor-update` for checking GitHub for a newer release). The three personas show up under `/config` → Output style (Echo, Cipher, Vex), and the daily cycles refill hook fires silently on every user prompt.

To pick a teacher: `/config` → Output style → **Echo** (or Cipher or Vex) → `/clear`. Then `/tutor-start <subject>` or `/tutor-project` to begin.

## Statusline integration

llm-tutor can render your tier, cycles balance, and active topic + progress directly in your Claude Code statusline. It works alongside **whatever statusline you're already using** — claude-statusline, a custom shell script, or none at all. You don't need to install or modify any other plugin.

### Install

```
/tutor-statusline-install
```

This saves your current `~/.claude/settings.json` `statusLine.command` (whatever it is) to `~/.claude/llm-tutor/wrapped-statusline.json` and swaps in a thin wrapper. Each render, the wrapper:

1. Pipes Claude Code's status JSON to your original command and captures its stdout (so your existing statusline still renders).
2. Appends llm-tutor's segment as an additional row.

A typical result with claude-statusline below — two original rows on top, llm-tutor's row appended in the active teacher's signature color:

```
claude-opus-4-7  │  🧠  high              📂 my-repo  🌿 main ~+ ↑2  │  ctx: [████░░░░░░] 38%
                                                       5h:42% 🔥 [1h20m]  │  7d:8% 🍃 [3d4h]  │  $1.23
🎙  ECHO · 🏷  Booted ▰▱▱▱▱ · ⚡  4/5 · 📖  python-decorators ▰▰▱▱▱
```

The persona label (`ECHO` / `CIPHER` / `VEX`) plus accent color is the row's signature — it owns its line instead of blending into the rest of the statusline. XP-toward-next-tier and concept-progress render as 5-cell bars; cycles glow yellow when only one is left.

### Toggle

To hide the segment without uninstalling:

```
/tutor-statusline-toggle off    # wrapper still runs, segment hidden
/tutor-statusline-toggle on     # segment back
/tutor-statusline-toggle        # cycle between
```

When off, the wrapper passes the original statusline through unchanged. Useful for screen-sharing.

### Icons

Four icon modes mirroring claude-statusline's pattern, so the llm-tutor row matches the aesthetic of the host statusline:

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

### Uninstall

```
/tutor-statusline-uninstall
```

Restores your original `statusLine.command` byte-for-byte. Your tutoring progress (XP, cycles, topics) stays intact — only the wrapper plumbing is removed. If you reinstall later, the saved-original is still there to wrap.

### How it stays decoupled

For the reasoning behind the wrapper pattern (vs. asking users to wire the segment into their own statusline, vs. baking the integration into claude-statusline), see [`docs/decisions/2026-06-03-statusline-integration-architecture.md`](./docs/decisions/2026-06-03-statusline-integration-architecture.md).

- **Versioned plugin path is hidden behind a stable symlink.** `settings.json` references `~/.claude/llm-tutor/statusline-wrapper.sh`, which is a symlink to the actual script in the plugin cache. When the plugin upgrades, the symlink target changes; `settings.json` doesn't need to.
- **Symlinks self-heal across plugin upgrades.** A `SessionStart` hook re-runs `ln -sf` against the current `$CLAUDE_PLUGIN_ROOT` every session, so a `/plugin update llm-tutor` followed by `/reload-plugins` is enough — no re-install required.
- **The wrapper is silent on failure.** If your original command goes missing (e.g., you uninstalled claude-statusline without uninstalling llm-tutor's wrapper first), the wrapper degrades to llm-tutor's segment alone rather than producing a blank statusline.
- **Re-installing is a no-op.** The installer detects an already-wrapped statusline and refuses to double-wrap (which would otherwise cause `Wrapper(Wrapper(Original))` recursion on uninstall).
- **Persona color is read at render time, not at install time.** The wrapper extracts `output_style.name` from Claude Code's status JSON on every render — switching teachers via `/config` updates the row's color immediately, without re-running install.

### Using the renderer directly (non-Claude-Code statuslines)

If you've built your own statusline outside Claude Code — a tmux right-status line, a fish prompt, a starship segment — you can shell out to the renderer:

```bash
~/.claude/llm-tutor/statusline-segment.sh            # default: ANSI + emoji ⚡
~/.claude/llm-tutor/statusline-segment.sh --plain    # ASCII, no color
~/.claude/llm-tutor/statusline-segment.sh --json     # raw signals for custom formatting
```

The symlink at that stable path is created by `/tutor-statusline-install`, so run install once first even if you're not going to use the wrapper itself. The segment exits silently (empty output, exit 0) when no tutoring session is active, so unconditional wiring is safe.

## Repository structure

This repo is a one-plugin marketplace:

```
llm-tutor/                         # marketplace root
├── .claude-plugin/marketplace.json
├── plugins/
│   └── llm-tutor/                 # the plugin
│       ├── .claude-plugin/plugin.json
│       ├── output-styles/         # Echo, Cipher, Vex
│       ├── skills/                # 12 /tutor-* skills
│       ├── hooks/                 # SessionStart (refresh-symlinks) + UserPromptSubmit (refill-cycles)
│       ├── scripts/               # state.sh, tier.sh, statusline-{segment,wrapper,install,uninstall,toggle,icons}.sh
│       └── state/                 # example.json (schema reference)
├── docs/
│   ├── research/                  # research catalog from initial design
│   └── decisions/                 # D1-D6 design decisions
└── README.md
```

## License

MIT
