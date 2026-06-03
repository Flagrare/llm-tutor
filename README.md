# llm-tutor

A Claude Code plugin that turns Claude into a Socratic tutor for *anything you want to learn* — any codebase, any technology, any project, any concept. Pick a teacher (Echo, Cipher, or Vex), point them at a subject, spend "cycles" to bring them in when you're stuck, and earn XP when you understand something on your own.

Inspired by Boots from boot.dev, but generalized: no fixed curriculum, no chosen topics. The tutor scaffolds a path through whatever you bring it.

## Try it

Three commands to install, one to pick a teacher, one to start learning:

```
/plugin marketplace add Flagrare/llm-tutor
/plugin install llm-tutor@llm-tutor
/reload-plugins
/config → Output style → Echo → /clear
/tutor-start "Python decorators"
```

Echo's opening turn will look something like this — calibrating where you're starting from, then handing you a small task to see what your mental model is, before any explanation lands:

```
Echo:  I'm going to be your tutor for "Python decorators." Three quick
       check-in questions first — they calibrate where I should pitch,
       not a test. Say "too easy" or "too hard" any time. Here we go:

       What's your starting point on decorators? Have you worked with
       higher-order functions in Python — passing functions as arguments,
       returning them — or is this brand new?

You:   I've passed functions around before. Not sure I've returned one
       from another though.

Echo:  Try this. I have:

           def add(a, b): return a + b

       Without using the @ symbol, write a `logged_add` that prints
       "called add" before calling add. Type it as code — I want to
       see your mental model, not the canonical answer.
```

Three Echo properties show up immediately: calibration before instruction, productive failure (you try first, the canonical comes after), and no answer-leak (decorators haven't been explained yet). Cipher and Vex apply the same Socratic structure with different voices — see [The three teachers](#the-three-teachers) below.

## Quick start

1. **Pick a teacher.** `/config` → Output style → **Echo** (or Cipher or Vex) → `/clear`. Committing to one for a study session makes it feel like a relationship, not a feature menu. You can switch between sessions, just not mid-conversation.
2. **Start a topic.** `/tutor-start "your subject"` for anything specific, or `/tutor-project` to tutor you on the codebase you're currently in. The tutor charges 1 cycle and generates an internal learning path.
3. **Talk back.** The tutor hints in layers and won't give you the answer until you've made the discovery yourself. Type "too easy" or "too hard" anytime to recalibrate.
4. **Close the loop.** `/tutor-done` when you can explain it without help. XP lands based on first-attempt quality per concept.

## Commands

| Command | Use it when |
|---|---|
| `/tutor-start <subject>` | You know what you want to learn — "Python decorators", "how Suspense works in React", "dependency injection". |
| `/tutor-codebase <path>` | You want to be tutored through a specific codebase or directory, with concepts anchored to real files. |
| `/tutor-project` | Shorthand for `/tutor-codebase .` — tutor on whatever you're currently working in. |
| `/tutor-resume` | Pick up a paused topic with a brief orientation. |
| `/tutor-status` | Dashboard — XP, cycles balance with refill ETA, active and completed topics. |
| `/tutor-path` | See the tutor's internal learning path for the current topic. Hidden by default. |
| `/tutor-done` | Mark the current topic understood and claim XP. |
| `/tutor-statusline-install` | Render tier, cycles, and topic progress in your statusline. See [Statusline integration](#statusline-integration). |
| `/tutor-statusline-toggle` | Show or hide the statusline row without uninstalling. |
| `/tutor-statusline-icons` | Switch icon mode (`emoji`, `nerd`, `unicode`, `ascii`). |
| `/tutor-statusline-uninstall` | Restore your original statusline byte-for-byte. |
| `/tutor-update` | Check GitHub for a newer release; surface the upgrade recipe when behind. |

## Why this exists

> An LLM that exists to make itself less necessary.

Every major LLM product is *incentivized to make you ask it more*. Anthropic, OpenAI, Google — they sell tokens; every bit of your cognition outsourced is revenue. The flywheel rewards the product when you stop being someone who understands things and start being someone who knows how to prompt for things. It's profitable for the AI's owner, expensive for you, and over time, *alienating*.

llm-tutor inverts that incentive. The Socratic guardrails — no answers, only questions; hints in layers; an explicit cost to ask for help — aren't a teaching-style choice. They're **anti-incentives**: design moves that punish over-reliance and reward independent struggle. The point isn't to be the best AI tutor. The point is to be a tutor that, after working with it, leaves you needing it less. The win condition is you uninstalling this.

This isn't just a stance — it's empirically backed. A 2025 PNAS study found ChatGPT-with-answers users scored 17% worse on later unsupported tasks; Socratic-style users didn't degrade. An MIT EEG study showed AI-first usage produces measurable *cognitive debt* — neural under-encoding visible on a scan. Ivan Illich named this kind of tool a **convivial tool** in 1973: one that amplifies its user's autonomy instead of substituting for it. A bicycle, not an e-bike. Most LLM products are e-bikes — they replace effort. llm-tutor is meant as a bicycle. The full research catalog is in [`docs/research/`](./docs/research/).

## The three teachers

Personas vary along **voice**, **pedagogy**, and **framing** — not just tone.

| | Echo | Cipher | Vex |
|---|---|---|---|
| **Voice** | Calm, observational. Mirrors your thinking back. | Knowing, slightly mysterious. Treats concepts as puzzles. | Direct, pushy. Won't accept vague answers. |
| **Pedagogy** | Patient. Stays at "what do you notice?" longer than most teachers. | Standard pace. Counterexample questions for partial understanding. | Demanding. Won't escalate hints until you articulate. |
| **Framing** | Discovery. "What's that telling you?" | Puzzle. "Here's the clue — what's the missing piece?" | Challenge. "Be precise. Prove it." |
| **Best for** | Exploratory learning; thinking out loud | Intermediate learners who want structure | Topics you've been stuck on; when you want to be pushed |

## Cycles and tiers

Borrowed from boot.dev's Boots, designed around a single principle: **make help-seeking expensive, make independence cheap.** Every move below is an anti-incentive against the failure mode the research catalog describes — reaching for the AI before reaching for your own attempt.

| | What it is |
|---|---|
| **XP** | Permanent. Earned by understanding a topic without leaning on the tutor too much. Spent when you can't afford a cycle. |
| **Cycle (⚡)** | Currency to ask the tutor for help during an active topic. Resets daily. |
| **Topics understood** | Permanent progress. Earned by `/tutor-done`-ing a topic. |

When you've got cycles, asking the tutor for help during a topic costs 1 cycle. When you don't, it costs a chunk of the XP you'd have earned from understanding the topic on your own. After `/tutor-done`, the tutor is free to chat with about it. The friction is the point — it makes you genuinely consider *"do I need help, or have I just not tried hard enough?"* without forbidding help when you actually need it.

XP accumulates into ten named tiers that tell the story of *becoming less dependent on the tutor*. The terminal tier ("Self-Hosting") explicitly names the design victory.

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

Tier is **cosmetic only** — a title showing your trajectory, not a functional unlock. The tutor never gets easier as you level up; the cycles cap stays at 5/day regardless of tier; rewards don't scale. This is deliberate: the anti-dependency philosophy means leveling should mean *status*, not *power*. The win is leaving the tutor, not deepening reliance on it.

## Statusline integration

llm-tutor renders your tier, cycles balance, and current topic + progress as an extra row in your Claude Code statusline — visible without `/tutor-status`. It works alongside **whatever statusline you're already running** (claude-statusline, a custom shell script, or none at all) by wrapping your existing `statusLine.command` rather than replacing it.

```
claude-opus-4-7  │  🧠  high              📂 my-repo  🌿 main ~+ ↑2  │  ctx: [████░░░░░░] 38%
                                                       5h:42% 🔥 [1h20m]  │  7d:8% 🍃 [3d4h]  │  $1.23
🎙  ECHO · 🏷  Booted ▰▱▱▱▱ · ⚡  4/5 · 📖  python-decorators ▰▰▱▱▱
```

Persona-colored signature, progress bars instead of N/M fractions, four icon modes matching claude-statusline's pattern. One-command install (`/tutor-statusline-install`), full uninstall preserves your original byte-for-byte. See [`docs/guides/statusline.md`](./docs/guides/statusline.md) for the install / toggle / icons / uninstall reference, or [`docs/decisions/2026-06-03-statusline-integration-architecture.md`](./docs/decisions/2026-06-03-statusline-integration-architecture.md) for the wrapper-pattern rationale.

## Design constraint: no plugin dependencies

llm-tutor depends only on standard Claude Code primitives — built-in tools (Bash, Read, Grep, Glob, Edit, WebFetch, etc.), the plugin component types defined in Claude Code's plugin reference (skills, slash commands, hooks, output styles), and the user's filesystem. It does **not** depend on any other plugin, skill ecosystem, or third-party Claude Code extension.

The trade-off is some duplication of effort — `/tutor-codebase` implements its own file exploration using Read/Grep/Glob rather than calling out to a shared codebase-exploration skill, and the persona files, dialogue engine, and gamification all ship inside this plugin. The benefit is that installing llm-tutor onto a fresh Claude Code install just works, and the plugin can't be broken by changes to external plugins.

## Relationship to flagrare:tutor

A standalone Socratic-tutor skill — invoked once per session, no progress tracking, no currency — exists in [flagrare/agent-skills](https://github.com/Flagrare/agent-skills) as `flagrare:tutor`. That's the right choice if you want the Socratic mechanism without the rest of this plugin.

llm-tutor is for users who want the full Boots-style experience: a teacher you build a relationship with across sessions, friction that creates honest "do I actually need help right now?" moments, and persistent progress so your work compounds. The two projects are complementary, not competing.

## Status

**Alpha.** All twelve commands ship and work; statusline integration is feature-complete; the next milestone is plugin-marketplace registration. Full ship-log in [`docs/roadmap.md`](./docs/roadmap.md).

## Documentation

- [`docs/guides/statusline.md`](./docs/guides/statusline.md) — Statusline integration install, toggle, icons, uninstall.
- [`docs/decisions/`](./docs/decisions/) — Architecture Decision Records. Why the gamification works the way it does, why the statusline integration is wrapper-based.
- [`docs/research/`](./docs/research/) — Research catalog. The PNAS / MIT studies and the Illich theoretical lineage that ground the anti-dependency philosophy.
- [`docs/roadmap.md`](./docs/roadmap.md) — Full ship-log and what's next.

## License

MIT — see [`LICENSE`](./LICENSE).
