---
name: tutor-codebase
description: "Start a Socratic tutoring journey grounded in an actual codebase. Reads files via Read/Grep/Glob to build the learning path; concepts carry file:symbol anchors so the tutor can reference real code. Invoke with a path: /tutor-codebase ./my-repo (defaults to 'overview' aspect) or /tutor-codebase ./my-repo 'auth flow' (scoped aspect). Triggers: '/tutor-codebase', 'tutor me through this codebase', 'teach me how this repo works', 'help me understand this code'. Distinct from /tutor-start: this one reads real files to ground the curriculum."
---

# Tutor Codebase

The distinctive skill of llm-tutor. While `/tutor-start` teaches abstract topics from world knowledge, `/tutor-codebase` teaches *this specific codebase* by reading actual files and building a learning path grounded in real code. Per the research catalog, no commercial LLM tutor handles "teach me this codebase" — that's our wedge.

The mechanics parallel `/tutor-start` (calibration, cycle charge, persona handoff) but with three real differences:

1. **Pre-path exploration.** The tutor reads files (`Read`/`Grep`/`Glob`) *before* generating the path. The path's concept ordering reflects the real architecture, not generic textbook ordering.
2. **File-anchored concepts.** Each concept has the format `"<abstract framing> (<file>:<symbol>)"`. The tutor knows what to reference during the dialogue.
3. **Calibration probes familiarity with THIS codebase.** Not "do you know auth in general" — "have you read `src/auth/middleware.ts` before?"

Zero deps: this skill uses Read/Grep/Glob (built-in Claude Code tools) for all codebase exploration. It does NOT call out to other plugins' codebase-exploration skills.

---

## Step 0 — Pre-checks

```bash
STATE="$CLAUDE_PLUGIN_ROOT/scripts/state.sh"
TIER="$CLAUDE_PLUGIN_ROOT/scripts/tier.sh"
```

### 0a. Initialize state + refill cycles

```bash
bash "$STATE" init >/dev/null
bash "$STATE" refill-cycles >/dev/null 2>&1 || true
CYCLES=$(bash "$STATE" get .user.cycles)
```

If `$CYCLES < 1`, refuse:

> "Out of cycles — they refill once per day. Run `/tutor-status` to see when next refill is due."

Exit.

### 0b. Resolve PATH argument

The user invokes `/tutor-codebase <path>` or `/tutor-codebase <path> "aspect description"`.

- The `<path>` is required. Without it, refuse: *"Need a path. Try `/tutor-codebase .` for the current directory, or `/tutor-codebase ./auth` for a subdirectory."*
- Validate that the path exists and is a directory. If not: *"`<path>` isn't a directory I can read."* Exit.

Resolve to absolute path:

```bash
ABS_PATH=$(cd "$USER_PATH" && pwd)
```

### 0c. Resolve aspect

- If the user provided an aspect (e.g., `'auth flow'`, `'how requests are routed'`), use it. Slugify it for the slug.
- If no aspect, default to `"overview"`.

```bash
ASPECT="${ASPECT:-overview}"
ASPECT_SLUG=$(printf "%s" "$ASPECT" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/-\+/-/g; s/^-\|-$//g')
```

### 0d. Slugify the topic

Per locked decision B2: `slug = "{repo-basename}-{aspect-slug}"`.

```bash
REPO_BASENAME=$(basename "$ABS_PATH")
SLUG="${REPO_BASENAME}-${ASPECT_SLUG}"
```

Examples:
- `/tutor-codebase .` from `~/Dev/claude-statusline` → `claude-statusline-overview`
- `/tutor-codebase . 'auth flow'` → `claude-statusline-auth-flow`
- `/tutor-codebase ./agent-skills 'release workflow'` → `agent-skills-release-workflow`

### 0e. Check for resume

If a topic with this slug already exists, branch:

```bash
EXISTING_STATUS=$(bash "$STATE" get ".topics[\"$SLUG\"].status // \"new\"")
```

- `in_progress`: print *"Resuming `$SLUG` (you've already paid the cycle for this topic). Picking up where we left off."* Skip to Step 5.
- `completed`: print *"You marked this complete already. To revisit as fresh, use a different aspect name."* Exit.
- `new`: continue to Step 1.

---

## Step 1 — Explore the codebase (before generating the path)

This is the part `/tutor-start` doesn't have. Before generating concepts, you actually read the code. The depth of exploration depends on the aspect:

### For aspect = "overview" (default)

Goal: build a high-level architectural picture.

Read in this order (use the `Read` tool for each):

1. **README** (`README.md`, `readme.md`, or similar). Always read first if it exists.
2. **Manifest files** that describe the project shape: `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`, `Gemfile`. Read whichever exists.
3. **Top-level directory listing** via `Glob` (e.g., `*` to see what's at the root).
4. **Entry-point files** if obvious from the manifest (e.g., `main.py`, `src/index.ts`, `cmd/main.go`).
5. **Configuration files** that signal architecture: `.github/workflows/`, `docker-compose.yml`, `Makefile`.

Stop here — for overview, you're building a 30-90 minute tutoring session, not a deep dive. Don't read every file; you'll generate concepts that the tutor will read more carefully during the dialogue.

### For aspect = a specific subject (e.g., "auth flow")

Goal: locate files relevant to that aspect and read enough to scope the learning path.

1. **README** for orientation (skim).
2. **Grep for the aspect's keywords** across the codebase:
   - For "auth": `Grep` for `auth|session|login|token|middleware|jwt` (case-insensitive)
   - For "requests": `Grep` for `request|handler|route|controller|api`
   - Adapt the regex to the aspect's vocabulary.
3. **Read the top-hit files** — the 3–6 files where the aspect's vocabulary clusters. Don't read every file that matches; pick the ones that look load-bearing.
4. **Trace one canonical path** from entry to exit (e.g., for auth: where does a logged-in request first identify the user?). This gives the path generation a real spine.

### Hard rules during exploration

- **Cap your exploration at ~10 file reads.** More than that and you're over-budget. The point is to inform path generation, not to deeply learn the codebase yourself.
- **Don't try to summarize the codebase to the user yet.** That's not what they asked for. They asked for a tutoring session. The exploration is for YOUR information.
- **If the codebase is genuinely too large or unfamiliar** (e.g., a 100k-file monorepo and the aspect is "overview"), refuse gracefully: *"`$ABS_PATH` is large. Scope it to a sub-aspect — try `/tutor-codebase $USER_PATH 'how the X module works'` instead."* Exit.

---

## Step 2 — Generate the learning path

Now with code in your context, generate 5-8 concepts as the curriculum. Per the locked decision A3, each concept has the mixed format:

```
"<abstract framing> (<file>:<symbol or section>)"
```

Examples (for an "overview" of a typical Express auth flow):

- `request entry and routing (src/server.ts:app.use)`
- `session middleware ordering (src/middleware/index.ts)`
- `auth middleware (src/auth/middleware.ts:requireAuth)`
- `session validation (src/auth/session.ts:validateSession)`
- `token refresh path (src/auth/refresh.ts:refreshToken)`
- `unauthenticated fallback (src/auth/middleware.ts:requireAuth — 401 branch)`

For each concept, identify which earlier concepts it directly depends on (by 1-based index). The dependency rules are the same as in `/tutor-start`'s D2 — only list direct dependencies, let chains transitively cover the rest.

### Write the path to state

```bash
bash "$STATE" maybe-init-topic "$SLUG"

# Add codebase-specific fields beyond the standard topic schema
bash "$STATE" set ".topics[\"$SLUG\"].codebase_path" "\"$ABS_PATH\""
bash "$STATE" set ".topics[\"$SLUG\"].aspect" "\"$ASPECT\""
```

Then populate the concepts array. The schema is the same as `/tutor-start` plus an optional `anchor` field on each concept:

```bash
CONCEPTS_JSON=$(jq -nc '[
  { "name": "request entry and routing", "anchor": "src/server.ts:app.use",
    "depends_on": [], "status": "pending", "first_attempt": null, "applications_distinct": 0 },
  { "name": "session middleware ordering", "anchor": "src/middleware/index.ts",
    "depends_on": [1], "status": "pending", "first_attempt": null, "applications_distinct": 0 },
  { "name": "auth middleware", "anchor": "src/auth/middleware.ts:requireAuth",
    "depends_on": [2], "status": "pending", "first_attempt": null, "applications_distinct": 0 }
]')
bash "$STATE" set ".topics[\"$SLUG\"].concepts" "$CONCEPTS_JSON"
```

The `anchor` field carries the file path (and optional `:symbol`) the tutor will reference during the dialogue. `/tutor-path` doesn't display anchors by default — they're for the tutor's use, not user-facing browsing.

---

## Step 3 — Charge cycle

Same as `/tutor-start`:

```bash
bash "$STATE" add .user.cycles -1
bash "$STATE" set ".topics[\"$SLUG\"].cycles_paid" true
NEW_BAL=$(bash "$STATE" get .user.cycles)
```

```
"Tutoring you on $REPO_BASENAME ($ASPECT). ⚡ Charged 1 cycle. Balance: $NEW_BAL remaining today."
```

---

## Step 4 — Calibrate (3 graduated prompts — codebase-specific)

Same structure as `/tutor-start`'s Step 3 (3 turns, escalating), but the questions probe familiarity with THIS codebase, not the technology in general.

> "Three quick check-in questions before we start the real tutoring — these calibrate where I should pitch. Say *'too easy'* / *'too hard'* / *'start over'* anytime to recalibrate, or *'just teach me'* to skip the rest of the calibration."

### Round 1 — General cue

Probe familiarity with the repo at all.

For overview aspect: *"Have you worked in this codebase before? Read the README, poked at any files, run any commands?"*

For specific aspect: *"What do you currently think happens when [aspect-relevant trigger]? E.g., for 'auth flow': when a logged-in user makes a request, what do you think happens between the browser and the database?"*

**Wait for response.** One question. No lecturing.

### Round 2 — Directed cue

Concrete probe of a real file. Use a file from your exploration.

> "Open `<a-relevant-file-you-read>`. What's the first thing you'd predict it does, just from the file name?"

Or:

> "If I removed `<file-or-function>`, what would break first?"

The user attempts. If they get it right, they have *some* familiarity. If they're way off, they're starting fresh.

### Round 3 — Partial model

Based on Round 2:

- If they nailed it: harder probe. *"Now: how does `<file-A>` relate to `<file-B>`?"*
- If they struggled: drop down. *"Forget what it does. Just: what kind of file is this? A controller? A library? A test?"*

### Classify and persist

```bash
bash "$STATE" set ".topics[\"$SLUG\"].calibration" '"intermediate"'   # or "novice"
```

Same interrupts honored: *"too easy"* / *"too hard"* / *"start over"* / *"just teach me"*.

---

## Step 5 — Position on path

Same as `/tutor-start`'s Step 4. Mark calibration-demonstrated concepts as `acquired` with `first_attempt: "success"` and `applications_distinct: 1`. Set `current_concept_index` to the first non-demonstrated concept and mark it `in_progress`.

---

## Step 6 — Hand off to the persona

Print the handoff. Codebase tutoring almost always wants productive-failure framing (the user is here to learn the code, and reading + failing + understanding is the path):

### For intermediate calibration

> "OK. You've got [concepts 1, …, N] already. We're starting at concept (N+1): **[name]** (anchored in `[file:symbol]`).
>
> Productive-failure approach — I'll point you at the file, you read it and tell me what you think it's doing. We'll talk about it after you've attempted.
>
> [Pose the first concrete question — match the active persona's voice. Echo asks discovery questions; Cipher poses puzzles; Vex demands precise predictions.]"

### For novice calibration

> "OK. Let's start at the foundations. We're at concept 1: **[name]** (anchored in `[file:symbol]`).
>
> Worked-example approach — I'll walk you through this one in detail, then you'll do the next concept more independently.
>
> [Show what the file does, anchoring claims to specific lines. End with a question that requires understanding to answer.]"

After this point, the persona's instructions govern. The persona has the codebase-path context now (the topic's `codebase_path` field) and can request more file reads during the dialogue as needed.

---

## Hard rules for this skill

1. **One thing at a time.** Don't read 30 files in one tool batch. Don't print exploration findings AND ask calibration. Sequence.
2. **Cap exploration at ~10 reads.** More than that and you've over-spent on the pre-path work.
3. **Don't summarize the codebase to the user during exploration.** That's not what they asked for. They want to be tutored *through* it, not handed a summary.
4. **Never write the canonical solution during calibration.** Even for codebase tutoring — if a calibration question has a "right" answer (e.g., "what does this function return for `null`?"), let the user try; don't pre-empt.
5. **Cycle charged exactly once per (codebase, aspect) pair.** Re-invoking `/tutor-codebase` on the same slug resumes for free.
6. **Refuse on too-broad scope.** If the codebase is huge and aspect is "overview" with no narrowing, push back: "Scope it to a sub-aspect."
7. **Path persisted at the codebase_path field.** Future `/tutor-resume` invocations on this topic can reference where the code lives — and surface a clear error if the directory has moved or been deleted since.

---

## Failure modes to actively prevent

| Failure | Prevention |
|---|---|
| Tutor reads 50 files trying to "understand the codebase" before generating the path | Step 1's hard cap (~10 reads). After 10, generate the path with what you have. |
| Concepts are too abstract (no file anchors) | Per A3, every concept must have an anchor. If the LLM generates an unanchored concept, append `(?)` and flag — better to acknowledge missing detail than fake it. |
| Calibration questions reveal the canonical solution | Pose questions about what the user *thinks*, not what the file *actually does*. Even if you know, ask. |
| Path generation gives generic "auth in a TypeScript app" concepts that ignore the actual code | The exploration step is supposed to prevent this. If after 10 reads you can't ground the concepts in the actual code, refuse: *"I'm not seeing enough structure in `$ABS_PATH` to scaffold a path. Could you point me at a starting file?"* |
| User's path moves between sessions | `/tutor-resume` checks `codebase_path` exists; if not, surfaces an error. Not this skill's job to handle, but the field is here for it. |

---

## Edge cases

- **Empty directory** → "Nothing to tutor on. `$ABS_PATH` is empty." Exit.
- **Directory has only one file** → Refuse or downscope: "This is a one-file codebase. Maybe `/tutor-start` for the underlying topic instead?"
- **Path contains files but no recognizable manifest** → Proceed with Glob-based discovery. Read the largest few source files to infer structure.
- **Path is in a different repo than CWD** → Fine. `cd` into it for the duration of exploration if needed (`(cd "$ABS_PATH" && command)`), then return to the user's cwd for state writes.
- **Aspect is genuinely too broad** ("everything") → Same as `/tutor-start`'s broad-subject pushback. Refuse and ask for narrowing.
- **Codebase is in a language the tutor isn't strong in** → Lean on the README and structure heavily; the LLM can still scaffold a learning path even when it can't perfectly read the code.
