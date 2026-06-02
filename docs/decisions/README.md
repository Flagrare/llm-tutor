# Design decisions

Locked-in design decisions for llm-tutor. Each entry pairs a *what* (the decision itself) with a *why* that cross-links back to the [research catalog](../research/) when the decision was empirically backed.

## Decisions

| Date | Topic | Backing research |
|------|-------|------------------|
| 2026-06-02 | [`/tutor-start` and gamification](./2026-06-02-tutor-start-and-gamification.md) — 5 decisions covering calibration depth, path surfacing format, state schema, feedback flow, and the rotating-question bank | [llm-tutor design foundations](../research/2026-06-02-llm-tutor-design-foundations.md) |

## Adding a decision

When a design call is locked in, drop a markdown file in this directory using a `YYYY-MM-DD-topic-slug.md` filename. Each decision should explain:

1. **Context** — what was the situation that required a decision?
2. **Decision** — what was chosen?
3. **Why** — what evidence or reasoning backed it? If research informed it, link to `docs/research/<slug>.md`.
4. **What's still open** — any sub-decisions deferred to future work.

The "why" cross-link is what gives the decision durability — six months from now, someone asking "why did we pick this?" should be able to follow the link to the evidence.
