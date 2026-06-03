---
name: tutor-resume
description: "Pick up a paused tutoring session. Finds the user's active in-progress topic, briefly reorients them (where they are, what's acquired, what's coming), and hands the dialogue back to the active persona. If multiple topics are in progress, asks which one. Invoke when you're returning after a break. Triggers: '/tutor-resume', 'continue', 'pick up where I left off', 'back to the tutor', 'resume tutoring'."
---

# Tutor Resume

The "pick up where you left off" skill. After a break — minutes, hours, or days — the user invokes this to be re-oriented into their active topic without having to remember the slug or re-invoke `/tutor-start`.

This skill is read-mostly: it queries state to find the active topic, prints an orientation message, and hands off to the persona. It does NOT charge cycles (the user already paid when they originally invoked `/tutor-start` on this topic; resume is free).

---

## Step 0 — Defensive setup

```bash
STATE="$CLAUDE_PLUGIN_ROOT/scripts/state.sh"
bash "$STATE" init >/dev/null
bash "$STATE" refill-cycles >/dev/null 2>&1 || true
```

---

## Step 1 — Find active topics

```bash
ACTIVE_SLUGS=$(bash "$STATE" get '[.topics | to_entries[] | select(.value.status == "in_progress") | .key]')
ACTIVE_COUNT=$(echo "$ACTIVE_SLUGS" | jq 'length')
```

### Branch: no active topics

If `ACTIVE_COUNT` is 0:

> "No topics in progress. Run `/tutor-start <subject>` to begin one, or `/tutor-status` to see your completed topics."

Exit cleanly.

### Branch: one active topic

If `ACTIVE_COUNT` is 1, use that slug. Skip to Step 2.

```bash
SLUG=$(echo "$ACTIVE_SLUGS" | jq -r '.[0]')
```

### Branch: multiple active topics

If `ACTIVE_COUNT` > 1, list them with brief progress info and ask the user to pick.

```bash
echo "You have $ACTIVE_COUNT active topics:"
echo
echo "$ACTIVE_SLUGS" | jq -r '.[]' | nl -w1 -s'. ' | while read -r line; do
  # line is "1. slug-name"
  num=$(echo "$line" | cut -d. -f1)
  slug=$(echo "$line" | cut -d'.' -f2- | sed 's/^ //')
  acquired=$(bash "$STATE" get ".topics[\"$slug\"].concepts | map(select(.status == \"acquired\")) | length")
  total=$(bash "$STATE" get ".topics[\"$slug\"].concepts | length")
  current_name=$(bash "$STATE" get ".topics[\"$slug\"].concepts[\"$(bash "$STATE" get ".topics[\"$slug\"].current_concept_index")\"].name // \"?\"")
  printf "  %s. %-30s (concept %s/%s: %s)\n" "$num" "$slug" "$((acquired + 1))" "$total" "$current_name"
done
echo
echo "Which one are you resuming? (Type the slug, or just the number.)"
```

Wait for the user's answer. Accept either:
- A slug matching one of the active topics
- A 1-based number (e.g., "2")

Validate the input. If invalid: "I don't see that as one of the active topics. Try again." Re-prompt.

---

## Step 2 — Read the topic's state for orientation

```bash
CONCEPTS=$(bash "$STATE" get ".topics[\"$SLUG\"].concepts")
CURRENT_IDX=$(bash "$STATE" get ".topics[\"$SLUG\"].current_concept_index")
CALIBRATION=$(bash "$STATE" get ".topics[\"$SLUG\"].calibration")
TOTAL=$(echo "$CONCEPTS" | jq 'length')
ACQUIRED_COUNT=$(echo "$CONCEPTS" | jq '[.[] | select(.status == "acquired")] | length')

# Current concept name (1-based for display)
CURRENT_NAME=$(echo "$CONCEPTS" | jq -r ".[$CURRENT_IDX].name")
CURRENT_POS=$((CURRENT_IDX + 1))

# Comma-separated names of acquired concepts (in order)
ACQUIRED_NAMES=$(echo "$CONCEPTS" | jq -r '[.[] | select(.status == "acquired") | .name] | join(", ")')

# Comma-separated names of upcoming pending concepts (in order, AFTER current)
UPCOMING_NAMES=$(echo "$CONCEPTS" | jq -r --argjson i $CURRENT_IDX \
  '[.[($i + 1):] | .[] | select(.status == "pending") | .name] | join(" → ")')
```

---

## Step 3 — Print the orientation

The orientation is brief — 3-4 lines max. The user is RESUMING, not starting; they don't need a tutorial on what the path looks like (that's `/tutor-path`).

```bash
echo "Resuming $SLUG."
echo
echo "You're at concept $CURRENT_POS/$TOTAL: $CURRENT_NAME"
if [ -n "$ACQUIRED_NAMES" ]; then
  echo "Already acquired: $ACQUIRED_NAMES"
fi
if [ -n "$UPCOMING_NAMES" ] && [ "$UPCOMING_NAMES" != "" ]; then
  echo "Up next: $UPCOMING_NAMES"
fi
echo
```

Example output:

```
Resuming python-decorators.

You're at concept 3/6: wrapper functions
Already acquired: closures, first-class functions
Up next: @ syntax → decorators with arguments → real-world patterns
```

---

## Step 4 — Hand off to the persona

This is the hand-off cue. The active persona (Echo / Cipher / Vex via output style) picks up the dialogue from here.

The hand-off message depends on the calibration branch the user was on when the topic was started:

### For intermediate calibration (productive-failure path)

> "Picking up at $CURRENT_NAME. Match what we were doing before — pose a fresh problem on this concept (productive-failure style) and let the user attempt. If you can sense they need scaffolding from how long the pause has been, drop down a hint rung; otherwise keep the difficulty where it was."

### For novice calibration ("I do / We do / You do" path)

> "Picking up at $CURRENT_NAME. Match what we were doing before — worked example or guided practice as appropriate. If you can sense they need a refresher, recap in one sentence before the next question; otherwise keep moving."

The skill ends here. The persona takes over.

---

## Hard rules

1. **No cycles charge.** Resume is free; the user already paid when they first invoked `/tutor-start` on this topic. The `cycles_paid: true` flag in state is the receipt.
2. **Don't re-do calibration.** The user calibrated when they started the topic. Resume picks up where they left off; it doesn't re-test.
3. **No path printing.** The orientation message doesn't render the full learning path. The user can invoke `/tutor-path` if they want that.
4. **Brief orientation.** 3-4 lines, then hand off. Long orientations break the resume feel — the user wants to continue working, not read a status report.
5. **Don't auto-pick on ambiguity.** When multiple topics are in progress, ask. Auto-picking the most-recent is a guess; the user might want the older one.

---

## Edge cases

- **`current_concept_index` is past the array length** (could happen if `/tutor-done` was almost called but failed) → Treat as "at the last concept" and continue. Don't crash.
- **Active topic with no concepts** (a failed `/tutor-start`) → Print: "`$SLUG` has no concepts — looks like the path generation failed. Try `/tutor-start $SLUG` to regenerate." Exit.
- **User picks a slug not in the active list when prompted** → Re-prompt with the same list. Don't fall through to `/tutor-start` semantics.
- **All concepts are already acquired but status is still in_progress** → Tell user: "All concepts on this path are marked acquired. You can run `/tutor-done $SLUG` to close it out." Exit.
