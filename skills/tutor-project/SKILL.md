---
name: tutor-project
description: "Start a tutoring session on the current working directory — convenience wrapper for /tutor-codebase against $PWD. Accepts an optional aspect: /tutor-project (defaults to overview) or /tutor-project 'how requests flow'. Triggers: '/tutor-project', 'tutor me on this project', 'tutor me on what I'm working on', 'teach me this'."
---

# Tutor Project

A thin wrapper around `/tutor-codebase` that uses the user's current working directory as the path. Use this when you want to tutor on whatever you're already inside — no need to type a path.

This skill does not duplicate `/tutor-codebase`'s logic. It resolves CWD as the codebase path and follows the same procedure that lives in [`skills/tutor-codebase/SKILL.md`](../tutor-codebase/SKILL.md).

---

## When to use this vs `/tutor-codebase`

- **`/tutor-project`** — tutor on the directory you're currently in
- **`/tutor-codebase <path>`** — tutor on a *different* directory (e.g., a repo you've cloned but aren't `cd`-ed into)

The slug format and aspect handling are identical in both skills.

---

## Procedure

### Step 0a — Resolve CWD

```bash
ABS_PATH=$(pwd)
```

Validate it's a directory you can read. (It almost certainly is — you're already in it — but check defensively.)

### Step 0b — Resolve aspect

If the user provided an argument (e.g., `/tutor-project 'how requests flow'`), use that as the aspect.

If not, default to `"overview"` per locked decision C2.

### Step 0c — Compute slug

Per locked decision B2: `slug = "{basename-of-PWD}-{aspect-slug}"`.

```bash
REPO_BASENAME=$(basename "$ABS_PATH")
ASPECT_SLUG=$(printf "%s" "$ASPECT" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/-\+/-/g; s/^-\|-$//g')
SLUG="${REPO_BASENAME}-${ASPECT_SLUG}"
```

### Step 1 onward — Follow `/tutor-codebase`'s steps

With `$ABS_PATH`, `$ASPECT`, and `$SLUG` resolved, **follow steps 0d–6 from `/tutor-codebase/SKILL.md` exactly**. The flow is identical from this point: resume-check → explore the codebase → generate path → charge cycle → calibrate → position on path → hand off to persona.

Do not re-implement the exploration, path generation, calibration, or handoff logic here. Read `tutor-codebase/SKILL.md` as your source of truth for those steps.

---

## Hard rules

Same hard rules as `/tutor-codebase` — they all apply unchanged:

1. One thing at a time (don't read 30 files in one batch)
2. Cap exploration at ~10 file reads
3. Don't summarize the codebase during exploration — that's not what the user asked for
4. Never reveal canonical solutions during calibration
5. Cycle charged exactly once per (codebase, aspect) pair (the existing-topic resume check in /tutor-codebase's Step 0e handles this)
6. Refuse on too-broad scope

The full rationale and worked examples for each rule are in `tutor-codebase/SKILL.md`.

---

## What this skill adds beyond `/tutor-codebase .`

Strictly speaking, `/tutor-codebase .` does exactly the same thing. So why have this skill at all?

- **Discoverability.** "tutor me on what I'm working on" is a common framing; surfacing it as its own slash command makes it findable in the picker.
- **Convenience.** Skipping the `.` argument feels right when the intent is "this thing I'm already in."
- **Trigger phrases.** This skill matches `tutor me on this project` / `tutor me on what I'm working on` more naturally than `/tutor-codebase` would.

The implementation cost is small (this short file) and the UX win is real.
