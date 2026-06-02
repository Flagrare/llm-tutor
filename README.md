# llm-tutor

A Claude Code plugin that turns Claude into a Socratic tutor for *anything you want to learn* — any codebase, any technology, any project, any concept. Pick a teacher (Echo, Cipher, or Vex), point them at a subject, spend "baked salmon" to bring them in when you're stuck, and earn XP when you understand something on your own.

Inspired by Boots from boot.dev, but generalized: no fixed curriculum, no chosen topics. The tutor scaffolds a path through whatever you bring it.

## Why this exists

> An LLM that exists to make itself less necessary.

Most LLM-as-helper relationships build dependency — you get faster at asking the AI to do things, never build the underlying skill yourself. The relationship is profitable for the AI's owner, expensive for you, and over time, *alienating*: you stop being someone who understands things and start being someone who knows how to prompt for things.

llm-tutor is the alternative. The Socratic guardrails (no answers, only questions; hints in layers; explicit friction to ask for help) aren't a teaching style choice — they're an *anti-capture* mechanism. The point isn't to be the best AI tutor. The point is to be a tutor that, after working with it, leaves you needing it less.

This isn't just a stance — it's empirically backed. A 2025 PNAS study found ChatGPT-with-answers users scored 17% worse on later unsupported tasks; Socratic-style users didn't degrade. An MIT EEG study showed AI-first usage produces measurable *cognitive debt*. The plugin's design is grounded in this evidence; see [`docs/research/2026-06-02-llm-tutor-design-foundations.md`](./docs/research/2026-06-02-llm-tutor-design-foundations.md) for the full research catalog. The framing language we use ("convivial tool") comes from Illich, 1973 — the theoretical lineage we're standing in.

## What you can tutor on

The tutor doesn't ship lessons. You bring the subject; the tutor scaffolds the path.

```
/tutor-start <subject>      "teach me Python decorators"
/tutor-codebase <path>      "tutor me through how auth works in this repo"
/tutor-project              "tutor me on what I'm currently working on"
/tutor-resume               pick up where you left off
/tutor-status               show what's open, XP, salmon
/tutor-done                 mark current topic as understood; claim XP
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

## The salmon economy

Borrowed from boot.dev's Boots:

| | What it is |
|---|---|
| **XP** | Permanent. Earned by understanding a topic without leaning on the tutor too much. Spent when you can't afford a salmon. |
| **Baked salmon (🐟)** | Currency to ask the tutor for help during an active topic. Resets daily. |
| **Topics understood** | Permanent progress. Earned by `/tutor-done`-ing a topic. |

When you've got salmon, asking the tutor for help during a topic costs 1 salmon. When you don't, it costs a chunk of the XP you'd have earned from understanding the topic on your own. After you `/tutor-done` a topic, the tutor is free to chat with about it.

The friction is the point: it makes you genuinely consider "do I need help, or have I just not tried hard enough?" — without forbidding help when you actually need it.

## Status

**Pre-alpha.** Currently shipping:

- [x] Three personas with anti-dependency philosophy (Echo / Cipher / Vex)
- [x] Design decisions locked: calibration depth, path format, state schema, feedback flow ([`docs/decisions/`](./docs/decisions/))
- [x] `state.json` schema + helper script (`scripts/state.sh`) with subcommands for get/set/add/refill-salmon
- [x] `UserPromptSubmit` hook — daily salmon refill check, silent and idempotent
- [x] `/tutor-start <subject>` skill — generates 5–8 concept path, 3-turn calibration, salmon charge, novice/intermediate branch, hand-off to active persona
- [x] `/tutor-done` skill — XP from per-concept first-attempt quality, hybrid feedback flow (thumbs + targeted rotating question with salmon rewards), feedback logged for analysis
- [ ] `/tutor-codebase <path>` skill — codebase-grounded tutoring
- [ ] `/tutor-project` skill — tutor on current work
- [ ] `/tutor-resume`, `/tutor-status`, `/tutor-done` commands
- [ ] `UserPromptSubmit` hook for salmon/XP accounting
- [ ] Statusline segment for [claude-statusline](https://github.com/Flagrare/claude-statusline) showing XP / salmon / current topic
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

## How to try a persona right now

Without installing as a plugin, you can symlink one of the output styles into your user output-styles directory:

```bash
mkdir -p ~/.claude/output-styles
ln -sf $(pwd)/output-styles/echo.md ~/.claude/output-styles/echo.md
# or cipher.md or vex.md
```

Then `/config` → Output style → **Echo** (or Cipher or Vex) → `/clear`. The persona's voice and disposition apply, but currency/topics aren't wired up yet, so this is just persona testing.

## License

MIT
