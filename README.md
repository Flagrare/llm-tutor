# llm-tutor

A Claude Code plugin that turns Claude into a Socratic tutor. Instead of writing the answer for you, Claude asks questions, reveals hints in layers, and refuses to hand over the solution until you've made the discovery yourself.

Inspired by Boots from boot.dev, but for any subject and any session.

## Status

**Pre-alpha.** Currently ships only the Tutor output style — the persona itself. Lesson curriculum, XP/currency mechanics, and progress tracking are planned (see Roadmap).

## What it does today

Once installed and activated:

- Claude leads with questions, not code.
- When you're stuck, you get the smallest possible hint first. You have to ask (or fail) your way up the hint ladder.
- Claude will write scaffolding (project skeletons, test harnesses, library boilerplate), but marks the *learning bits* as `# TODO(you)` for you to fill in.
- "Just tell me" works — but only after one more nudge, and the reveal comes paired with a question about what you missed.

## What it will do (roadmap)

- [x] **Socratic output style** — the persona itself
- [ ] **Lessons as skills** — `/tutor-lesson <topic>` loads a lesson into context
- [ ] **Curriculum browser** — `/tutor-curriculum` lists what's available
- [ ] **XP + currency state** — per-user `state.json` tracks progress and "asking budget"
- [ ] **`UserPromptSubmit` hook** — deducts currency when you ask for help mid-lesson (creates honest friction)
- [ ] **Statusline integration** — XP / currency / current-lesson segments for [claude-statusline](https://github.com/Flagrare/claude-statusline)

## Install

Not yet — this is pre-alpha. Once published it'll be installed via Claude Code's plugin system.

## Activate the tutor mode

After installing, run `/config` and select **Output style** → **Tutor**. The change takes effect on the next `/clear` or new session.

## License

MIT
