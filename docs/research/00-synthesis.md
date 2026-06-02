# Research Synthesis — Design Implications

Five parallel agents researched: how Boots actually works (#01), LLM-tutor landscape (#02), pedagogy theory (#03), gamification evidence (#04), and anti-dependency design (#05). This doc threads the findings together.

## What's now empirically backed (not just intuition)

| Design choice | Evidence |
|---|---|
| **The anti-dependency thesis** | MIT EEG study (2025) shows AI-first usage produces *cognitive debt* — measurable neural under-encoding. PNAS 2025: ChatGPT-with-answers users scored 17% worse on later unsupported tasks; Socratic users didn't degrade. The "tool that makes itself unnecessary" framing isn't a vibe — it's a measurable distinction. |
| **The salmon cost** | Bjork's generation effect — requiring an attempt before assistance is one of the most robustly replicated conditions for durable learning. The salmon cost punishes *skipping the struggle*, which is pedagogically defensible. Different from Duolingo's Hearts (which punish failure — predatory pattern). |
| **Hint layers (ours: 5; Boots: 0)** | Boots's primary failure mode reported by users: when stuck, Boots "just repeats the task and calls you 'cub'." It has no escalation path. Our 5-rung hint ladder is the direct fix. |
| **Pre-/post-completion behavior split** | Boots branches its system prompt on `lesson_completed`. Our personas already do this ("in a lesson vs. between lessons"). Confirmed pattern. |

## What changes in the design (sharpest implications)

### 1. Don't ASK what the user knows. PROBE with graduated prompts.

My earlier design decision ("yes, probe existing knowledge first") was framed as a calibration *question*. The pedagogy research says this is wrong. The ZPD framework (Vygotsky + structural learning research) says: never ask "what do you know?" directly — apply graduated prompts of increasing specificity (general cue → directed cue → partial model → full model) and **observe the minimum level at which the learner succeeds**.

That's the calibration. The user answering "I sort of know decorators" tells you nothing useful — they're either humble or overconfident, and you can't tell which. The user successfully responding to a general cue tells you exactly where they are.

**Action:** Rewrite the `/tutor-start` design to use graduated prompts as the calibration step, not direct questions.

### 2. Productive Failure: problem BEFORE explanation (for non-novices)

Manu Kapur's work shows that posing the target problem *before* the canonical explanation produces significantly better conceptual transfer than explanation-first — **for learners who have the prerequisites in place**. For true novices (no foothold), worked examples first (Kirschner-Sweller).

This means `/tutor-start` needs an initial bifurcation: detect novice vs intermediate via the graduated prompts, then branch:
- **Novice path:** worked example → guided practice → independent attempt ("I do / We do / You do")
- **Intermediate path:** challenge → struggle → connect to canonical explanation after attempt

### 3. Concept "acquired" needs TWO distinct applications, not one

A single right answer doesn't mark mastery. Knowledge Space Theory (Doignon-Falmagne, used in ALEKS) marks a concept acquired only after the learner successfully applies it in *two distinct contexts*. This changes `/tutor-done`'s semantics: the user can claim a topic done, but the system tracks per-concept-application coverage and can flag "you've seen X used once but never applied it yourself" as a hidden gap.

### 4. The Knowledge Space DAG as the foundation of `/tutor-start`

For a given topic, the LLM generates a directed acyclic graph of 5–8 prerequisite concepts on session start. That's the curriculum. Teaching proceeds forward through the DAG, one node at a time. The DAG is **internal control** (per our earlier decision) but **surfaceable on user request** ("show me the path you've planned").

This solves the "what order do I teach concepts in" problem concretely without needing a pre-built ontology. The LLM can generate the DAG from a topic description, including for highly specific cases like "auth in this codebase."

### 5. XP tied to first-attempt quality, not bare completion

Self-determination theory + gamification research: extrinsic rewards (XP) tied to *completion* slide into rewarded-presence territory and crowd out intrinsic motivation. XP tied to *first-attempt success* (sharpshooter-style) preserves the competence-feedback signal that genuinely supports learning.

Practical: track per-concept "first-attempt success" vs "needed hint" vs "needed reveal" — XP awarded accordingly, not for finishing the topic.

### 6. Build structured feedback collection from day one

Boot.dev's improvement loop is *informal* (Discord reports + thumbs-down data). Lane Wagner: "Giving the right context to the LLM is like all the work." Their best like rates are ~0.22% — humbling, and a reminder that any LLM tutor will fail often. We should build feedback into the MVP, not bolt it on later.

Practical: after every `/tutor-done`, a one-question feedback prompt ("Did this session help you understand X? Y/N + optional comment") logged to state.

## What stays the same

- **Three personas (Echo / Cipher / Vex)** — the differentiation along voice + pedagogy + framing is good
- **Salmon currency model** — backed by Bjork's generation effect
- **Hint layers (5 rungs)** — directly addresses Boots's failure mode
- **Persistence across sessions** — confirmed against Khanmigo / Duolingo pattern
- **Plugin shape** (output styles + skills + hooks) — still right

## Two surprises worth flagging

1. **Boots's actual like rate is ~0.22%** — across both GPT-4o and Claude 3.5 Sonnet. Even the best-tuned commercial LLM tutor has low absolute user satisfaction. We should set expectations accordingly and design for graceful failure, not chase a 100% solution.

2. **The unclaimed market is "teach me this codebase"** — ChatGPT Study Mode and TutorAI handle generic dynamic topics. *Nobody* handles "tutor me through how auth works in this specific repo." That's our distinctive design space. `/tutor-codebase <path>` should be a first-class command, not a sub-feature of `/tutor-start`.

## Frameworks to adopt as language

From the anti-dependency research:

- **"Convivial tool"** (Illich, 1973) — the theoretical name for what we're building. Use in docs.
- **"Original bicycle for the mind"** (Jobs, but as reclaimed framing) — explicitly position against the "e-bike AI" drift where the motor replaces effort.
- **"Gradual Release of Responsibility — I do, We do, You do"** — pedagogical architecture for sessions.

## Design decisions still open

After this synthesis, what's left to decide:

1. **Calibration depth** — How many graduated prompts before we commit to novice/intermediate? Two? Three? Five? Need to balance accuracy vs. user patience.
2. **DAG surfacing UX** — When the user asks "show me the path," what does that look like? Concept names? Concept names + their dependencies? A visual?
3. **Per-attempt tracking schema** — what does `state.json` look like at the per-concept-per-attempt level? Could get heavy fast.
4. **Feedback collection format** — quick 👍/👎? Optional text? Per-session or per-concept?
