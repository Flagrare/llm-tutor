# llm-tutor

A Claude Code plugin that turns Claude into a gamified Socratic tutor. Pick a teacher (Echo, Cipher, or Vex), work through lessons at your own pace, spend "baked salmon" to ask the teacher for help, earn XP when you complete a lesson on your own. Inspired by Boots from boot.dev, but for any subject and any session.

## Why a plugin

A standalone tutor skill — invoked once per session, no progress tracking, no currency — exists in [flagrare/agent-skills](https://github.com/Flagrare/agent-skills) under `flagrare:tutor`. Use that one if you want the Socratic mechanism without the rest.

This plugin is for people who want the **full Boots-style experience**: a curriculum to work through, a teacher you build a relationship with across sessions, friction (the salmon cost) that creates honest "do I actually need help right now?" moments, and persistent progress so your work compounds.

## The three teachers

Personas vary along **voice**, **pedagogy**, and **framing** — not just tone.

| | Echo | Cipher | Vex |
|---|---|---|---|
| **Voice** | Calm, observational. Mirrors your thinking back. | Knowing, slightly mysterious. Treats concepts as puzzles. | Direct, pushy. Won't accept vague answers. |
| **Pedagogy** | Patient. Stays at "what do you notice?" longer than most teachers. | Standard pace. Counterexample questions for partial understanding. | Demanding. Won't escalate hints until you articulate. |
| **Framing** | Discovery. "What's that telling you?" | Puzzle. "Here's the clue — what's the missing piece?" | Challenge. "Be precise. Prove it." |
| **Best for** | Exploratory learning, when you want to think out loud | Intermediate learners who want structure | Topics you've been stuck on; experienced learners who want to be pushed |

Pick one at the start of a study session via `/config` → Output style. You can switch between study sessions but not mid-session (the session would feel like a different conversation halfway through).

## The salmon economy

Borrowed from boot.dev's Boots. Three things you track:

| | What it is |
|---|---|
| **XP** | Permanent. Earned by completing lessons on your own. Spent when you can't afford a salmon. |
| **Baked salmon (🐟)** | Your "ask the teacher" currency. Costs 1 salmon to bring the teacher in mid-lesson. Resets daily (?). |
| **Lessons complete** | Permanent progress. |

If you have salmon, asking the teacher for help during a lesson costs 1 salmon. If you don't have any, it costs 50% of the XP you'd earn from completing the lesson. After you complete a lesson, the teacher is free to chat with about that material.

The friction is the point: it makes you genuinely consider "do I need help, or have I just not tried hard enough?" — without forbidding help when you actually need it.

## Status

**Pre-alpha.** Currently shipping:

- [x] Persona output style: Echo (calm, patient, discovery-framing)
- [ ] Personas: Cipher, Vex
- [ ] State file schema (`state.json`: XP, salmon, current lesson, history)
- [ ] Lesson skill (`/tutor-lesson <N>`) — loads lesson content, engages strict dialogue mode
- [ ] Curriculum browser (`/tutor-curriculum`)
- [ ] Status (`/tutor-status`)
- [ ] Lesson completion (`/tutor-complete`)
- [ ] `UserPromptSubmit` hook for salmon/XP accounting
- [ ] First lesson set (TBD topic)
- [ ] Statusline segment for [claude-statusline](https://github.com/Flagrare/claude-statusline) showing XP / salmon / current lesson

## How to test the Echo persona right now

Without installing as a plugin, you can symlink the output style into your user output-styles directory:

```bash
mkdir -p ~/.claude/output-styles
ln -sf $(pwd)/output-styles/echo.md ~/.claude/output-styles/echo.md
```

Then `/config` → Output style → **Echo** → `/clear`. The strict dialogue rules apply, but currency/lessons aren't wired up yet, so this is just persona testing.

## Install (eventually)

Will be installable via Claude Code's plugin system once the curriculum and gamification layers are built. Not yet.

## License

MIT
