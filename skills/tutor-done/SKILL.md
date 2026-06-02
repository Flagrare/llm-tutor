---
name: tutor-done
description: "Close an active tutoring topic. Calculates XP earned from per-concept first-attempt quality, marks the topic complete in state, runs the hybrid feedback flow (thumbs + targeted rotating question with salmon rewards), and logs feedback for later analysis. Invoke when you're done with a topic. Use with no arg to close the currently-active topic, or pass a slug (/tutor-done python-decorators) to close a specific one. Triggers: '/tutor-done', 'I'm done with this topic', 'close out this tutoring session', 'mark this complete'."
---

# Tutor Done

This skill closes an active tutoring topic — the pair to `/tutor-start`. It calculates the XP earned, marks the topic complete in `state.json`, runs the two-step feedback flow (thumbs + targeted rotating question), and credits the user with salmon rewards for engaging.

The feedback flow is the load-bearing piece. Per the design decisions doc (D4), feedback is rewarded to fix the "users skip it" problem, with anti-gaming guards (symmetric thumbs reward, substantive-answer guard for the targeted question, daily salmon cap).

---

## XP rubric (per-concept)

XP is awarded per concept based on the `first_attempt` field — the user's first interaction with that concept during the session.

| `first_attempt` | XP awarded | Reasoning |
|---|---|---|
| `"success"` | 30 | Solved it on the first try. Earned mastery signal. |
| `"needed_hint"` | 15 | Used the hint ladder; learned something but with scaffolding. |
| `"needed_reveal"` | 5 | Needed the canonical answer revealed. Still engaged, still some learning. |
| `null` | 0 | Concept was never attempted (probably skipped during calibration). No XP. |

A typical 6-concept topic where the user gets most concepts first-try and needed one hint earns ~150 XP. The numbers are tunable in this rubric — adjust here if the felt-pacing turns out wrong.

---

## Step 0 — Resolve the target topic

```bash
STATE="$CLAUDE_PLUGIN_ROOT/scripts/state.sh"
```

### 0a. Subject resolution

If the user provided an argument (e.g., `/tutor-done python-decorators`), use that as the slug.

If no argument, find the active topic:

```bash
ACTIVE=$(bash "$STATE" get '[.topics | to_entries[] | select(.value.status == "in_progress") | .key]')
```

If the active list is empty:

> "No topic in progress. Run `/tutor-status` to see what you've started, or `/tutor-start <subject>` to begin one."

Exit cleanly.

If exactly one in-progress topic, use that slug.

If multiple in-progress topics, ask:

> "Multiple topics in progress: [list]. Which one are you closing? (Type the slug, e.g. `python-decorators`.)"

Wait for the user's choice. Validate it's in the list.

### 0b. Validate state

```bash
CURRENT_STATUS=$(bash "$STATE" get ".topics[\"$SLUG\"].status")
```

If status is `"completed"`:

> "Topic `$SLUG` is already marked complete. Nothing to do."

Exit cleanly.

If status is `"new"` or anything unexpected, refuse gracefully:

> "Topic `$SLUG` isn't in a state I can close. Status: `$CURRENT_STATUS`. Try `/tutor-status`."

Exit cleanly.

---

## Step 1 — Calculate XP and mark complete

### 1a. Iterate concepts and sum XP

Read the concepts array:

```bash
CONCEPTS=$(bash "$STATE" get ".topics[\"$SLUG\"].concepts")
```

For each concept, compute XP per the rubric above. Build a breakdown like:

```
closures:               30  (first try)
first-class functions:  30  (first try)
wrapper functions:      15  (needed a hint)
@ syntax:               30  (first try)
decorators w/ args:     15  (needed a hint)
real-world patterns:    30  (first try)
                       ──── 
                        150 XP
```

You can compute the total atomically via jq:

```bash
XP_EARNED=$(jq -n --argjson c "$CONCEPTS" '
  $c | map(
    if .first_attempt == "success" then 30
    elif .first_attempt == "needed_hint" then 15
    elif .first_attempt == "needed_reveal" then 5
    else 0
    end
  ) | add // 0
')
```

### 1b. Persist

```bash
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
bash "$STATE" add .user.xp "$XP_EARNED"
bash "$STATE" set ".topics[\"$SLUG\"].xp_earned_total" "$XP_EARNED"
bash "$STATE" set ".topics[\"$SLUG\"].status" '"completed"'
bash "$STATE" set ".topics[\"$SLUG\"].completed_at" "\"$NOW\""
```

### 1c. Print breakdown

Show the breakdown table + total to the user. Include the XP delta on `user.xp`:

```
Topic complete: $SLUG

XP earned breakdown:
  [per-concept lines as above]
                       ──── 
                        $XP_EARNED XP

XP: $PREV_XP → $NEW_XP (+$XP_EARNED)
```

Don't print salmon yet — that comes after the feedback flow.

---

## Step 2 — Thumbs feedback (always asked)

Use the `AskUserQuestion` tool. Single-select, two options, no preview:

- **👍 Yes — this helped me learn**
- **👎 No — it didn't work for me**

Question text:

> "Quick check: did this session help you learn?"

Wait for the user's response.

### 2a. Award the thumbs reward (symmetric)

Award +0.5 salmon either way. Reward is symmetric so users can't game by always thumbs-upping. Cap-aware:

```bash
CUR=$(bash "$STATE" get .user.salmon)
CAP=$(bash "$STATE" get .user.salmon_cap)
NEW_SALMON=$(jq -n --argjson cur "$CUR" --argjson cap "$CAP" '[$cur + 0.5, $cap] | min')
bash "$STATE" set .user.salmon "$NEW_SALMON"
```

Print the receipt one line:

> "👍 noted (or 👎 noted). +0.5 salmon. balance=$NEW_SALMON"

---

## Step 3 — Targeted rotating question

Now pick a question from the bank using round-robin selection.

### 3a. Pick the question

```bash
COMPLETED_COUNT=$(bash "$STATE" get '[.topics | to_entries[] | select(.value.status == "completed")] | length')
QUESTION_INDEX=$(( (COMPLETED_COUNT - 1) % 5 ))
```

The `- 1` is because this topic just got marked complete, so the count already includes it; for the first-ever completion the count is 1 and we want question index 0.

Use the question at `QUESTION_INDEX` from the bank below.

### 3b. Question bank

| Index | Failure mode | Question |
|---|---|---|
| 0 | Anti-leak | Was there a moment in this session where I gave too much away or pushed when I should have backed off? |
| 1 | Anti-stuck | Were there any moments where you felt genuinely stuck without a clear way forward? |
| 2 | Persona-fit | Did the teacher persona work for this material, or did it feel off? Would another voice have fit better? |
| 3 | Hint pacing | Did I escalate hints too quickly or stay at one level too long? Where did the pacing feel off? |
| 4 | Validity check | Looking back, do you feel you actually learned this, or did we skim past the real thing? |

### 3c. Ask via free text (NOT AskUserQuestion)

The user might write 2 sentences or just say "no" — free text fits better than a picker. Phrase like:

> "One more if you want (+1 salmon for a substantive answer):
>
> [SELECTED QUESTION]
>
> (Free text, or just type 'no' to skip.)"

Wait for the user's response.

### 3d. Substantive-answer check

Define "substantive" as:
- length > 20 characters AFTER trimming whitespace, AND
- not literally matching any of these (case-insensitive): `no`, `n/a`, `nothing`, `idk`, `skip`, `none`, `na`, `nope`

If substantive: award +1 salmon (cap-respecting):

```bash
CUR=$(bash "$STATE" get .user.salmon)
CAP=$(bash "$STATE" get .user.salmon_cap)
NEW_SALMON=$(jq -n --argjson cur "$CUR" --argjson cap "$CAP" '[$cur + 1.0, $cap] | min')
bash "$STATE" set .user.salmon "$NEW_SALMON"
```

If not substantive (skipped/short): no extra reward. Don't punish, don't lecture.

### 3e. Log the feedback

Append to `feedback_log` regardless of substance:

```bash
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ENTRY=$(jq -n \
  --arg ts "$NOW" \
  --arg thumbs "$THUMBS" \
  --arg q "$QUESTION_TEXT" \
  --arg a "$USER_ANSWER" \
  '{ ts: $ts, thumbs: $thumbs, targeted_question: $q, targeted_answer: $a }')

bash "$STATE" set ".topics[\"$SLUG\"].feedback_log" \
  "$(bash "$STATE" get ".topics[\"$SLUG\"].feedback_log" | jq --argjson e "$ENTRY" '. + [$e]')"
```

(For atomicity, this can be done in a single jq write if you want — the pattern above does it in two reads for clarity.)

---

## Step 4 — Summary

Print the closing summary. Keep it short.

```
Done. $SLUG is in your completed log.

XP earned: $XP_EARNED  (total: $NEW_XP)
Salmon: $NEW_SALMON / $CAP

You're free to chat about this material at no salmon cost from here on. 
Start something new with /tutor-start, or see /tutor-status for the overview.
```

---

## Hard rules

1. **Calculate XP from the concepts array, not from heuristics.** The user gets the XP their first-attempt record says, not a rounded estimate.
2. **Thumbs reward is symmetric.** Always +0.5 salmon either way. If you give 👎 less reward than 👍, the metric becomes useless.
3. **Substantive guard for the +1 salmon.** Length > 20 chars AND not in the skip list. This is the anti-gaming defense.
4. **Cap-respect salmon rewards.** Never push salmon over `salmon_cap`. Use `jq … | min` for the capping math.
5. **Always log feedback** to `feedback_log`, even when the user skipped the targeted question. The thumbs alone is data.
6. **Round-robin question, no skipping.** The user gets all 5 questions over 5 completed topics. Don't try to be smart about which to ask — the rotation is the whole point.
7. **One sequence per turn.** Don't print the XP breakdown AND ask thumbs AND ask the targeted question all at once. Three separate user-facing turns.
8. **Don't lecture about the salmon rewards.** Mention them once in passing ("+0.5 salmon", "+1 salmon"). Don't explain the gamification economy in the closing message.

---

## Edge cases

- **No topic in progress** → tell the user, exit.
- **Multiple topics in progress** → ask which one.
- **Already-completed topic** → tell user it's already done, exit.
- **All concepts have `first_attempt: null`** (user never engaged) → XP = 0. Still allow completion. Show "0 XP earned — you didn't engage much with this one. The topic is closed."
- **Salmon already at cap** → reward computes to no-change; print "+0.5 salmon (capped at $CAP)". Be honest about the cap.
- **User answers `"no"` in lowercase** → not substantive. `"No"` and `"NO"` also not substantive (case-insensitive skip list).
- **User writes exactly 20 characters** → not substantive (strictly > 20, not >=).
