---
name: tutor-start
description: "Start a Socratic tutoring journey on any user-supplied topic. Generates a learning path of 5-8 prerequisite concepts, calibrates the user's knowledge via 3 graduated prompts, charges 1 cycle, and hands off to the active Echo/Cipher/Vex persona for the dialogue. Invoke with the subject as an argument (e.g. /tutor-start 'python decorators'), or with no argument to be asked. DOES auto-trigger on: 'tutor me on X', 'tutor me through X', 'start a tutoring session on X', '/tutor-start'. DOES NOT auto-trigger on colloquial 'teach me X' or 'explain X' — those usually mean the user wants a quick answer, not a 30-90 minute Socratic dialogue."
---

# Tutor Start

This skill begins a Socratic tutoring journey on a user-supplied topic. It is the load-bearing entry point for the llm-tutor plugin — every other skill (`/tutor-done`, `/tutor-path`, `/tutor-status`, `/tutor-resume`) operates on state this skill creates.

**Explicit invocation only.** Do not auto-fire on colloquial phrases like "teach me X" or "explain Y" — those usually mean the user wants a quick answer, not a 30-90 minute dialogue. Trigger phrases are listed in the frontmatter description above.

---

## Step 0 — Pre-checks

Run these via the `Bash` tool, in order. Treat `STATE` as a shorthand for the helper script path. The plugin guarantees `$CLAUDE_PLUGIN_ROOT` is set when this skill is invoked.

```bash
STATE="$CLAUDE_PLUGIN_ROOT/scripts/state.sh"
```

### 0a. Initialize state (idempotent)

```bash
bash "$STATE" init
```

This creates `state.json` if it doesn't exist; no-op if it does.

### 0b. Refill cycles if a day has passed (defensive — hook should have done this)

```bash
bash "$STATE" refill-cycles
```

### 0c. Read cycles balance

```bash
SALMON=$(bash "$STATE" get .user.cycles)
```

If `$SALMON < 1`, stop here. Print the user-facing message verbatim:

> "Out of cycles — they refill once per day. Run `/tutor-status` to see when next refill is due, or come back tomorrow. (Earning more cycles today is possible via feedback on completed topics, see `/tutor-done`.)"

Exit the skill cleanly. Do NOT proceed to path generation.

### 0d. Resolve the subject

If the user provided an argument (e.g., `/tutor-start "python decorators"`), use that as the subject.

If no argument was provided, ask via free text (NOT `AskUserQuestion` — subjects are open-ended):

> "What do you want to be tutored on? Be specific. Good: 'Python decorators' / 'how Suspense works in React' / 'how auth works in this repo'. Too broad: 'Python' / 'web dev' / 'AI'."

If the user names a topic that's clearly too broad (single-word language name, multi-paragraph stack), push back once: *"Too broad. Pick a sub-topic or one concrete question."* Do NOT proceed with a too-broad subject.

### 0e. Slugify the subject

Convert the subject to a kebab-case slug for use as a state key. Lowercase, alphanumerics and hyphens only, no leading/trailing hyphens.

Examples:
- "Python decorators" → `python-decorators`
- "How auth works in this repo" → `auth-in-this-repo`
- "React's Suspense API" → `react-suspense`

Save the slug as `SLUG` for use in later steps.

### 0f. Check for resume

If the topic already exists in state, this is a re-invocation — resume instead of recharging.

```bash
EXISTING_STATUS=$(bash "$STATE" get ".topics[\"$SLUG\"].status // \"new\"")
```

If `$EXISTING_STATUS` is `in_progress`, print:

> "Resuming `$SLUG` (you've already paid the cycles for this topic). Picking up where we left off."

Then read `current_concept_index` and the concepts array, identify the current concept, and skip to **Step 5** (handoff). Do NOT proceed to path generation, cycles charging, or calibration.

If `$EXISTING_STATUS` is `completed`, print:

> "You marked this topic complete already. Feel free to chat about it freely (no cycles cost). If you want to revisit as a fresh topic, name it differently — e.g., 'python-decorators-revisit'."

Exit cleanly.

If `$EXISTING_STATUS` is `new`, proceed to Step 1.

---

## Step 1 — Generate the learning path

Using your world knowledge, generate a directed acyclic graph (DAG) of 5–8 prerequisite concepts for the subject. The graph should:

- **Order concepts by dependency**: each concept's prerequisites must come before it.
- **Be appropriately scoped** for a 30–90 minute tutoring session. Not "everything about Python," not "just the @ symbol."
- **Use concise names**: noun phrases of 2–5 words each. Examples: "closures", "wrapper functions", "decorators with arguments". Not "the closure concept and how it relates to lexical scoping".
- **Include only what's truly prerequisite**. If you find yourself adding a concept "for completeness," cut it.

For each concept, identify which earlier concepts it depends on (by 1-based index in your list).

**Internal control:** keep this DAG internal. Don't print the list to the user yet. They'll see it only if they invoke `/tutor-path` (or ask "show me the path"). This is deliberate — surfacing it now would frame the session as a checklist instead of a discovery.

### Write the path to state

For each concept, append an entry to the topic's `concepts` array. Use `state.sh maybe-init-topic` to create the topic entry (idempotent), then `state.sh set` to populate the concepts array.

Each concept entry has the shape:

```json
{
  "name": "closures",
  "depends_on": [],
  "status": "pending",
  "first_attempt": null,
  "applications_distinct": 0
}
```

The `depends_on` field is an array of **1-based indices** into the same `concepts` array — which earlier concepts must be understood before this one makes sense. Examples:

- Concept 1 ("closures") might have `depends_on: []` — it's a foundational concept with no prerequisites in this topic.
- Concept 3 ("wrapper functions") might have `depends_on: [1, 2]` — needs both prior concepts.
- Concept 6 ("real-world patterns") might have `depends_on: [4, 5]` — needs the two preceding, which transitively bring in everything else.

Be honest with the dependency lists. Don't lazy-write `[1, 2, …, N-1]` for everything — that defeats the point. Write only the *direct* dependencies. If concept 6 needs 4 and 5 (which in turn need 3, which needs 1+2), the chain captures everything transitively; you don't need to repeat 1, 2, 3 in concept 6's list.

```bash
bash "$STATE" maybe-init-topic "$SLUG"
```

Then populate the concepts array atomically (single jq write for the whole array):

```bash
CONCEPTS_JSON=$(jq -nc '[
  { "name": "closures",                  "depends_on": [],     "status": "pending", "first_attempt": null, "applications_distinct": 0 },
  { "name": "first-class functions",     "depends_on": [],     "status": "pending", "first_attempt": null, "applications_distinct": 0 },
  { "name": "wrapper functions",         "depends_on": [1, 2], "status": "pending", "first_attempt": null, "applications_distinct": 0 },
  { "name": "@ syntax",                  "depends_on": [3],    "status": "pending", "first_attempt": null, "applications_distinct": 0 },
  { "name": "decorators with arguments", "depends_on": [3, 4], "status": "pending", "first_attempt": null, "applications_distinct": 0 },
  { "name": "real-world patterns",       "depends_on": [4, 5], "status": "pending", "first_attempt": null, "applications_distinct": 0 }
]')
bash "$STATE" set ".topics[\"$SLUG\"].concepts" "$CONCEPTS_JSON"
```

---

## Step 2 — Charge cycles

Deduct 1 cycle, mark `cycles_paid` true:

```bash
bash "$STATE" add .user.cycles -1
bash "$STATE" set ".topics[\"$SLUG\"].cycles_paid" true
NEW_BAL=$(bash "$STATE" get .user.cycles)
```

Print the charge to the user briefly:

> "Tutoring you on **$SUBJECT**. ⚡ Charged 1 cycle. Balance: $NEW_BAL remaining today."

Keep this terse — one line. The user wants to start, not read a receipt.

---

## Step 3 — Calibrate (3 graduated prompts)

You're going to run 3 turns of graduated prompts to figure out where to start them on the path. The goal is **not** to test — it's to find the boundary between what they can already do and what they can't. **Observe what they can do, don't ask what they know.**

Open the calibration phase with a posture statement:

> "Three quick check-in questions before we start the real tutoring — these calibrate where I should pitch, not a test. Say *'too easy'* / *'too hard'* / *'start over'* anytime to recalibrate, or *'just teach me'* to skip the rest of the calibration."

### Round 1 — General cue

The opener probes their starting point WITHOUT asking the unreliable "what do you know" question. Phrase it as "where are you coming in from."

For coding topics: *"What's your starting point on $SUBJECT? Have you worked with [the parent concept / a sibling tech] before, or is this brand new?"*

For codebase topics (`/tutor-codebase`-style scoped invocations the user might make through this skill): *"Are you familiar with how this codebase is laid out generally? Have you read [an obvious entry-point file]?"*

For conceptual topics: *"What's your background on $SUBJECT? Where are you coming from — adjacent concepts you've worked with?"*

**Wait for the user's response. One question. Do not lecture.**

### Round 2 — Directed cue

Based on Round 1, give them a concrete small task involving the simplest form of the topic. **Don't ask them to explain — ask them to do.**

Examples:
- Decorators: *"Try this: I have `def add(a, b): return a + b`. Without using `@` syntax, write a 'logged_add' that prints something before calling add."*
- Suspense: *"Sketch what JSX would look like for a component that wants to wait for some data to load before rendering its children. Use any pseudo-syntax — I just want to see your mental model."*
- Codebase auth: *"Where in this repo would you start looking to understand how a logged-in request is identified? Name a file or directory."*

**Wait for the user's response. One question. Do not lecture.**

### Round 3 — Partial model

Adapt to Round 2's outcome:

- **If they nailed Round 2**: Give a harder version. *"Right. Now extend it — what if you wanted that logging behavior on ANY function, not just `add`? What's the smallest change?"*

- **If they struggled at Round 2**: Drop down a rung with more scaffolding. *"OK — let's slow down. Forget the function part for a moment. In Python, can you assign a function to a variable? Show me what that looks like."*

**Wait for the user's response. One question. Do not lecture.**

### Classify

After Round 3, classify them as `novice` or `intermediate`:

- **Novice**: Struggled at Round 2 even with the scaffolding in Round 3. Or explicitly said "I have no idea what any of this is." Or got Round 2 wrong in a way that suggests they don't have the prerequisites for the chosen path.
- **Intermediate**: Got Round 2 mostly right, OR struggled at Round 2 but recovered at Round 3 with a substantive attempt.

Save the classification:

```bash
bash "$STATE" set ".topics[\"$SLUG\"].calibration" '"intermediate"'   # or "novice"
```

### Mid-calibration interrupts

If at any round the user says:

- *"too easy"* → Skip ahead in the path. Mark earlier concepts as `acquired` and start later. Tell them: *"Calibrating up. Skipping past [concepts X, Y]."*
- *"too hard"* → Drop down to an earlier prerequisite. Stop calibration; classify as novice. Tell them: *"Calibrating down. Starting with the foundations."*
- *"start over"* → Restart calibration from Round 1.
- *"just teach me"* → End calibration immediately. Classify as intermediate by default. Move to Step 4.

These interrupts make calibration a hypothesis, not a verdict.

---

## Step 4 — Position on the path

Based on the calibration outcome, mark which concepts the user has *already demonstrated* and set the current concept index.

### Marking demonstrated concepts

For each concept the user explicitly demonstrated during calibration (Rounds 2 and 3), mark it as acquired with `first_attempt: "success"`:

```bash
bash "$STATE" set ".topics[\"$SLUG\"].concepts[N].status" '"acquired"'
bash "$STATE" set ".topics[\"$SLUG\"].concepts[N].first_attempt" '"success"'
bash "$STATE" set ".topics[\"$SLUG\"].concepts[N].applications_distinct" 1
```

(Note: `applications_distinct = 1` after calibration, not 2 — the two-application rule means they need to apply it again in a *different* context during the actual lesson to fully acquire. Calibration is one application.)

### Set the starting concept

Set `current_concept_index` to the first concept the user did NOT demonstrate:

```bash
bash "$STATE" set ".topics[\"$SLUG\"].current_concept_index" 3   # or whatever
bash "$STATE" set ".topics[\"$SLUG\"].concepts[3].status" '"in_progress"'
```

---

## Step 5 — Hand off to the persona

Print the handoff message. This is the cue for the active persona (Echo, Cipher, or Vex — whichever output style the user has on) to take over the conversation.

### For intermediate calibration (productive-failure path)

> "OK. You've got [concepts 1, 2, … N] already. We're starting at concept (N+1): **[current concept name]**.
>
> Productive-failure approach — I'm going to give you a problem first, and we'll talk about the canonical approach after you've attempted it. Here we go:
>
> [Pose the FIRST CONCRETE PROBLEM that uses the current concept. Match the persona's voice — Echo phrases it as discovery, Cipher as a puzzle, Vex as a challenge.]"

### For novice calibration ("I do / We do / You do" path)

> "OK. Let's lay down the foundations. We're starting at concept 1: **[concept 1 name]**.
>
> Worked-example approach — I'll show you what this looks like first, then we'll do a couple together, then you'll do one alone.
>
> [Worked example, matching the persona's voice. Then ask: "Does that make sense? Tell me in your own words what just happened."]"

---

## After Step 5

Your job as the skill is done. The user is now in a tutoring conversation with the active persona. From this point on, the persona's instructions (in their output style file) govern the dialogue — hint layers, one-question-per-turn, no answer-leak, etc.

The user can:
- Continue the dialogue normally
- Invoke `/tutor-path` to see the learning path
- Invoke `/tutor-status` to see XP / cycles / progress
- Invoke `/tutor-done` when they want to close the topic
- Invoke `/tutor-start` again on the same topic to resume (no recharge)

---

## Hard rules for this skill

1. **One thing at a time.** Don't print the path AND the calibration question in the same turn. Don't charge cycles AND ask Round 1 in the same turn. Sequence matters.
2. **Never reveal the canonical solution during calibration.** The Round 2 task may have a "right answer" — let the user try it; do not pre-empt with the solution.
3. **Never write the full curriculum to the user up-front.** The DAG is internal control by design (per the locked-in design decision). Surface it ONLY on `/tutor-path`.
4. **Charge cycles exactly once per topic.** The `cycles_paid` field is your guard — never deduct twice.
5. **Refuse to start with broad subjects.** "Python" is too broad; push back once and require specificity.
6. **No code blocks during calibration questions.** Inline references like `def add(a, b)` are fine; full snippets aren't until the user is writing code in response.
7. **Don't lecture during calibration.** Calibration is *observing*. Lecturing pre-loads what you want them to know and corrupts the signal.

---

## Failure modes to actively prevent

| Failure | Prevention |
|---|---|
| User pays cycles, gets bad path, gives up | Step 1 quality is critical. Generate concept names that are concrete and ordered correctly. If a concept name feels like jargon, reword it. |
| Calibration runs forever | Hard cap at Round 3. Even if the signal is ambiguous, classify and move on. The user can interrupt with "too easy"/"too hard" later. |
| Resume vs new-topic ambiguity | Step 0f handles this explicitly. Always check existing status before charging cycles. |
| Cycles=0 but user has rich XP and wants to spend it | NOT IMPLEMENTED in MVP. The cost is cycles; XP doesn't fall back. Future work — see decision doc D4's open items. |
| User says "too easy" but the skill keeps calibrating | Honor the interrupt immediately. Skip to Step 4 with the classification adjusted. |
