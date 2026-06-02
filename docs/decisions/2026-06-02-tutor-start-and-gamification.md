# Design Decisions: `/tutor-start` and Gamification

- **Date:** 2026-06-02
- **Status:** accepted
- **Informed by:** [`docs/research/2026-06-02-llm-tutor-design-foundations.md`](../research/2026-06-02-llm-tutor-design-foundations.md)

## Context

The three personas (Echo, Cipher, Vex) are written and shipped. Before writing the `/tutor-start` skill or the `UserPromptSubmit` hook for currency accounting, five concrete design decisions needed to be locked in. The research catalog provided the evidence base; this doc records the decisions.

These decisions affect:
- The `/tutor-start` skill (calibration flow, path generation, surface format)
- The `state.json` schema (what we persist per concept across sessions)
- The `UserPromptSubmit` and `/tutor-done` hooks (currency accounting, feedback collection)
- The forthcoming `/tutor-path` slash command (path surfacing)

## Glossary

Defined inline for any reader unfamiliar with the project's terms:

- **XP** (experience points) — the permanent score. Goes up when you complete topics. Never resets.
- **Salmon** — the consumable currency. Resets daily. You spend it to bring the tutor in mid-topic. Borrowed name from boot.dev's "baked salmon" — same idea.
- **Learning path** (sometimes "concept map") — the ordered list of sub-concepts the tutor plans to walk you through for a given topic. The tutor generates it on session start and keeps it internal unless you ask to see it.
- **Concept** — one node on the learning path. E.g., for "Python decorators", `closures` is a concept; `wrapper functions` is another.
- **Topic** — what you asked to learn. E.g., `python-decorators`, `react-suspense`, `auth-in-this-repo`.
- **First-attempt** — whether you got a concept right on your first try, needed a hint, or needed a full reveal. Used for XP fairness.

---

## D1 — Calibration via 3 graduated prompts

**Decision:** When `/tutor-start <subject>` is invoked, the tutor opens with 3 turns of escalating prompts to calibrate the user's existing knowledge. Commits to a novice or intermediate path on turn 4. User can interrupt at any point with "too easy" / "too hard" / "start over" to trigger immediate recalibration.

**Shape:**
1. **General cue (turn 1):** "What's your starting point on X? Have you worked with it before?"
2. **Directed cue (turn 2):** Adapts to turn 1's response. Concrete small task involving the simplest form of X.
3. **Partial model (turn 3):** If they succeeded at 2 → harder version. If they struggled → more scaffolding.

**Why 3, not 2 or 5:**
- 2 doesn't let the tutor triangulate when responses are inconsistent (succeed at general, fail at directed = unclear signal).
- 5+ feels like a test; user patience evaporates.
- 3 gives a discernible pattern (consistently capable / consistently struggling / boundary).

**Design assumption:** calibration is a hypothesis, not a verdict. The tutor will be wrong sometimes; the design makes correction cheap (user can say "this is too easy" any turn).

**Backed by:** ZPD / graduated prompting research ([catalog Q3, source #03 — Vygotsky / Structural Learning](../research/03-pedagogy-and-curriculum-theory.md)). The pedagogy research established that *direct* knowledge questions ("what do you know about X?") are unreliable because learners are humble or overconfident — but the literature didn't fix N. We pick 3 as the smallest N that triangulates.

---

## D2 — Path surfacing format: "With dependencies"

**Decision:** When the user invokes `/tutor-path` (or asks "show me the path" in conversation), the tutor displays a numbered list with state markers and inline prerequisite annotations.

**Format:**
```
Path for Python decorators (6 concepts):

  [✓] 1. closures
  [✓] 2. first-class functions
  [→] 3. wrapper functions          (needs: 1, 2)
  [ ] 4. @ syntax                    (needs: 3)
  [ ] 5. decorators with arguments  (needs: 4)
  [ ] 6. real-world patterns         (needs: all above)
```

**Marker semantics:**
- `[✓]` = acquired (passed the two-application rule — see D3)
- `[→]` = currently being taught
- `[ ]` = pending

**Why "with dependencies" and not the alternatives:**
- The compact-checklist alternative loses the dependency info — user can't ask "can we skip step 4?" and immediately see what depends on it.
- The conversational-paragraph alternative is harder to scan when the user just wants a quick "where are we" check mid-session.
- Dependencies inline keep the format flat (no tree art) and answer the "what blocks what" question for free.

**Note on invocation:** Path is invocable two ways:
1. Explicit slash command: `/tutor-path`
2. Natural-language ask during a session: "show me the path" / "what are we covering" — the persona files instruct Claude to render the same format.

**Backed by:** No specific research source — derives from the earlier conversation decision ("surface if the user wants to, but keeps as internal control for the LLM"). The dependency-annotated format was chosen over alternatives via direct user pick.

---

## D3 — State persistence: medium detail (per-concept tracking)

**Decision:** `state.json` tracks per-concept first-attempt quality and application count, but does NOT keep a full event log of every dialogue turn.

**Schema:**

```json
{
  "user": {
    "xp": 1240,
    "salmon": 5,
    "salmon_last_reset": "2026-06-02T00:00:00Z"
  },
  "topics": {
    "python-decorators": {
      "status": "in_progress",
      "started_at": "2026-06-02T10:00:00Z",
      "current_concept_index": 2,
      "salmon_paid": true,
      "concepts": [
        {
          "name": "closures",
          "status": "acquired",
          "first_attempt": "success",
          "applications_distinct": 2
        },
        {
          "name": "first-class functions",
          "status": "acquired",
          "first_attempt": "success",
          "applications_distinct": 2
        },
        {
          "name": "wrapper functions",
          "status": "in_progress",
          "first_attempt": "needed_hint",
          "applications_distinct": 1
        },
        {
          "name": "@ syntax",
          "status": "pending",
          "first_attempt": null,
          "applications_distinct": 0
        }
      ],
      "feedback_log": []
    },
    "react-suspense": {
      "status": "completed",
      "completed_at": "2026-05-28T14:30:00Z",
      "concepts": [ /* full history preserved */ ],
      "xp_earned_total": 180,
      "feedback_log": [
        {
          "ts": "2026-05-28T14:31:00Z",
          "thumbs": "up",
          "targeted_question": "Did I give too much away?",
          "targeted_answer": "No, the wrapper-functions hint at rung 3 was exactly the level I needed."
        }
      ]
    }
  }
}
```

**Field semantics:**
- `concept.status` — one of `pending` | `in_progress` | `acquired`
- `concept.first_attempt` — one of `success` | `needed_hint` | `needed_reveal` | `null` (not yet attempted)
- `concept.applications_distinct` — count of distinct contexts where the user applied this concept. A concept becomes `acquired` only when this hits 2 (Knowledge Space Theory rule — see D below).
- `salmon_paid` — whether the user has paid the per-topic entry cost for this topic (1 salmon to start asking for help during this topic)
- `feedback_log` — appended per `/tutor-done` invocation

**Why medium, not light or heavy:**
- Light (topic-status-only) can't support fair XP (no way to distinguish first-try mastery from struggle-with-help) or the two-application acquisition rule.
- Heavy (full event log) is overkill for MVP and risks file corruption / unbounded growth.

**The two-application rule:** A concept is only marked `acquired` after the user successfully applies it in **two distinct contexts**, not after one right answer. From Knowledge Space Theory (Doignon-Falmagne / ALEKS). The `applications_distinct` counter tracks this. "Distinct" is determined by the LLM at the time of attempt — a re-run of the same exercise doesn't count; a new exercise using the same concept does.

**Salmon reset:** `salmon_last_reset` tracks the last daily reset. The `UserPromptSubmit` hook checks this on each render and refills salmon if a day has passed since the last reset.

**Backed by:** Knowledge Space Theory (ALEKS, Doignon-Falmagne) for the two-application rule. Self-Determination Theory (Ryan & Deci) for the first-attempt-quality XP. Both in [catalog](../research/2026-06-02-llm-tutor-design-foundations.md).

---

## D4 — Feedback collection: hybrid thumbs + targeted, with salmon rewards

**Decision:** On `/tutor-done`, the tutor presents a two-step feedback flow with salmon rewards calibrated to discourage gaming.

**Flow:**

```
Step 1 — Thumbs (always asked)
─────────────────────────────────
Topic complete! +180 XP. salmon=5

Did this session help you learn? 👍 / 👎

→ User taps one.
→ +0.5 salmon either way (no incentive to lie either direction).

Step 2 — Targeted question (optional, rotates)
───────────────────────────────────────────────
👍 noted. +0.5 salmon for your feedback.

One more if you want (+1 salmon for a substantive answer):
[rotating question from bank — see D5]
(Free text, or 'no' to skip.)

→ Substantive answer = +1 salmon.
→ "no" / skip = no extra reward (no penalty).
```

**"Substantive answer" guard:** answer string must be > 20 characters AND not literally match `n/a`, `no`, `nothing`, `idk`, `skip`. This prevents farming the +1 by typing "no" repeatedly. 20 chars is roughly one short sentence — enough to write something useful, not enough to type a trivial response.

**Reward currency: salmon, not XP.**
- Salmon is the *consumption* currency (refills daily, spent on tutor help).
- XP is the *permanent* score (earned by topic completion).
- Rewarding feedback with XP would corrupt the permanent score with engagement-farming.
- Rewarding feedback with salmon means "users who help us tune the tutor get more tutor time" — incentives aligned with the project's mission.

**Daily salmon cap:** 5 per day. Feedback rewards don't bypass the cap — they just help you hit it. A user completing one topic + giving full feedback in a day earns 0.5 + 1 + 0.5 (assuming topic completion also gives some salmon) but is still capped at 5 total. Prevents infinite farming.

**Symmetry of 👍 / 👎:** Same +0.5 reward either way. Punishing 👎 with no reward would teach users to always thumb up, corrupting the satisfaction metric.

**Backed by:**
- The need for feedback at all: Boots's documented learning loop is informal (Discord + thumbs-down), and Lane Wagner's ~0.22% like rate ([catalog source: Lane Wagner interview](../research/01-how-boots-actually-works.md)) tells us any LLM tutor will fail often. Need structured feedback from day one.
- Reward calibration: Self-Determination Theory ([catalog source: Ryan & Deci 2020](../research/04-gamification-evidence.md)). Tangible rewards work for feedback only when they reward *engagement*, not the *content* of the answer. The symmetric 👍/👎 reward and the substance-guard for the targeted question both follow from this.

---

## D5 — Rotating feedback question bank

**Decision:** The targeted question in Step 2 of D4's feedback flow cycles through a bank of 5 questions, each probing a different failure mode the tutor knows it has. Selection is **round-robin** (cycle through the bank in order) for the MVP. Future refinement: per-persona selection (Echo most likely to give too much away; Vex most likely to push too hard).

**Question bank (rotates in this order):**

1. **Anti-leak**: "Was there a moment in this session where I gave too much away or pushed when I should have backed off?"
2. **Anti-stuck**: "Were there any moments where you felt genuinely stuck without a clear way forward?"
3. **Persona-fit**: "Did the teacher persona work for this material, or did it feel off? Would another voice have fit better?"
4. **Hint pacing**: "Did I escalate hints too quickly or stay at one level too long? Where did the pacing feel off?"
5. **Validity check**: "Looking back, do you feel you actually learned this, or did we skim past the real thing?"

**Why these five:**
- They map directly to the documented failure modes of LLM tutors and Socratic-method dialogues (from [research catalog](../research/2026-06-02-llm-tutor-design-foundations.md))
- Each question is specific enough to elicit useful detail, broad enough to apply to any topic
- Phrased as "yes/no with optional detail" so even short answers are useful
- The set rotates so the same question doesn't fatigue the user

**Selection logic:**
```
question_index = (total_topics_completed_lifetime) mod 5
```

Simple, deterministic, easy to test. The user gets all 5 questions over 5 topic completions; sees each one again after every 5.

**Persona variant (future):**
Echo-active sessions might over-weight question 1 (anti-leak — Echo's weakness).
Vex-active sessions might over-weight question 4 (hint pacing — Vex's weakness).
Cipher-active sessions might over-weight question 2 (anti-stuck — Cipher's puzzle-framing risk).
Defer to v0.2; the round-robin is fine for MVP.

**Storage:** Each feedback gets logged to the topic's `feedback_log` array (see D3's schema) with timestamp, thumbs result, question shown, and answer.

---

## What's still open

These decisions sit on top of `/tutor-start` and the `UserPromptSubmit` hook, but those skills are not yet written. Specifically:

1. **The text of the 3 graduated calibration prompts.** D1 specifies the structure ("general cue → directed cue → partial model") but doesn't write the actual prompts. The prompts will be generic templates that the tutor adapts per topic.
2. **How the tutor *generates* the learning path on `/tutor-start` invocation.** D2 specifies the surface format but not the generation prompt. Will likely be: "Given topic X, list 5-8 prerequisite concepts in dependency order suitable for a 30-90 minute tutoring session."
3. **What "two distinct applications" means in practice.** D3 mentions the rule; the tutor needs guidance on when to count an application as distinct vs. a repeat.
4. **Codebase-grounding for `/tutor-codebase`.** D5's question bank works generically; for `/tutor-codebase` the questions might need to be adapted (e.g., "did I correctly identify which files matter, or did we go down a wrong path?").
5. **Salmon refill amount and frequency.** D4 assumes daily refill to a cap of 5 but doesn't specify whether refill is +5/day or "refill to 5/day if below 5."
