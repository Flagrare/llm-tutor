# Pedagogy and Curriculum Theory

Research on how good human tutors construct learning paths on the fly, and what frameworks are most actionable for an LLM tutor that constructs curriculum in real time.

---

## Bloom's Taxonomy — Application to LLM Curriculum Generation

### What It Is

Bloom's Taxonomy (1956, revised 2001 by Anderson & Krathwohl) is a six-level hierarchy of cognitive engagement, ascending from lower-order to higher-order thinking:

1. **Remember** — recall facts, definitions, labels
2. **Understand** — explain, paraphrase, classify
3. **Apply** — use knowledge in a new situation
4. **Analyze** — break into parts, compare, trace causality
5. **Evaluate** — judge, critique, justify
6. **Create** — design, build, synthesize something new

### How Human Tutors Use It

Experienced tutors use Bloom's as a *sequencing ladder*: they start with Remember/Understand questions to probe what the learner already knows, then layer on Apply/Analyze tasks once foundational comprehension is confirmed. They do not skip levels with novices.

The taxonomy also functions as a **diagnostic instrument**: the level at which a learner can correctly respond to questions tells the tutor their current ceiling. A learner who can recall the syntax of a Python decorator but cannot explain *why* you'd use one is at level 1 and needs to be brought to level 2 before being handed an Apply task.

### Actionable Heuristics for LLM Tutoring

- **Default entry point**: Open with a single Remember-level question ("What do you already know about X?") then one Understand-level question ("Can you explain what that does in your own words?"). The answers together reveal the starting level.
- **Sequencing rule**: Never jump more than one level per concept. Remember → Understand → Apply is natural. Remember → Analyze is jarring and produces frustration rather than learning.
- **Question vocabulary map**: Use level-appropriate verbs when constructing questions:
  - Remember: "What is…?", "Name…", "Define…"
  - Understand: "Explain in your own words…", "Why does…?", "What would happen if…?"
  - Apply: "Write a function that…", "Change this code to…"
  - Analyze: "Why did the author structure it this way?", "What's the difference between X and Y?"
  - Evaluate: "Is this a good design? Why?"
  - Create: "Build something that demonstrates…"
- **Pivot rule**: If a learner succeeds at Apply but struggles at Analyze, stay at Apply with varied contexts before ascending. "Can they do it in a different situation?" is the test before ascending.
- **One-session realism**: In a single tutoring session, reaching Apply for a new concept and touching Analyze once is a realistic ceiling for most learners. Evaluate and Create are multi-session goals.

### Limitation

Bloom's tells you *what level to teach at* but not *which concept to teach next* when the topic has internal dependencies. That's where Knowledge Spaces (below) come in.

---

## ZPD — Calibration and "Next Concept" Choice

### What It Is

Vygotsky's Zone of Proximal Development (ZPD) is the gap between what a learner can do independently and what they can accomplish with guidance from a more knowledgeable other. The tutor's job is to operate precisely in that gap — not below it (boring), not above it (frustrating).

The ZPD is not static. It shifts forward as the learner gains competence, and a good tutor tracks it continuously throughout a session.

### How Human Tutors Calibrate ZPD

The key technique is **graduated prompting** — giving hints in escalating specificity rather than answers:

1. General prompt: "What do you think is happening here?"
2. Directed cue: "Look at the return value. What's it returning?"
3. Partial model: "It's returning a function. What does that tell you about what this decorator does?"
4. Full model: Explain it explicitly.

The level at which the learner needs help reveals the current ZPD boundary. A learner who answers at step 1 is below their ZPD for this concept (it's too easy). A learner who cannot answer even at step 3 may be above it (the concept needs more prerequisites).

**Contingent scaffolding** — adjusting support moment-to-moment based on responses — is the operationalization of ZPD work. Research shows contingent scaffolding is 2.5x more effective than fixed support structures.

The practical **test-teach-retest** loop:
1. Probe what the learner can do with graduated hints
2. Teach at the revealed edge
3. Probe again to confirm forward movement

### "I Do / We Do / You Do" — The Fading Model

This three-step release model operationalizes ZPD in practice:
- **I do**: Expert models the concept explicitly, making thinking visible
- **We do**: Guided practice; tutor provides contingent hints as needed
- **You do**: Learner attempts independently; tutor observes and only intervenes on error

The transition between steps is data-driven: move to "We do" when the learner can articulate the concept; move to "You do" when they succeed with minimal hints. **Do not rush the "We do" phase.** Most one-on-one tutoring fails by moving to "You do" too early.

### When to Introduce the Next Concept

VanLehn's research on tutoring granularity reveals the operative rule: **as long as the student is making progress, don't intervene or pivot**. Introduce a new concept when:
- The current concept has been demonstrated in at least 2 different contexts (transfer check)
- The learner can explain *why* the concept works, not just *how* (Understand level confirmed)
- A new concept is a prerequisite for the next thing the learner wants to do

Do not introduce a new concept because the current one "seems learned." Premature topic changes are the most common tutoring failure mode.

### Actionable Heuristics for LLM Tutoring

- Start every session with 2–3 graduated-prompt exchanges before teaching anything. These calibrate the ZPD boundary.
- Track the *minimum hint level* needed per concept. If a learner needs level-3 hints consistently, they are at the top of their ZPD and need reinforcement, not advancement.
- Use errors as information: a wrong answer reveals which prerequisite is missing, not that the learner "doesn't get it." Diagnose the missing prerequisite and address it before re-attempting the target concept.

---

## Scaffolding Frameworks

### Bruner's Scaffolding Theory

Bruner (building on Vygotsky) defined scaffolding as temporary support provided by a more knowledgeable other that enables the learner to accomplish a task beyond their current independent capability. The critical word is **temporary**: scaffolding that is never removed becomes a crutch, not a bridge.

Key properties of good scaffolding:
- **Reduction of choices**: Scaffold by constraining the problem space, not by giving answers. Instead of solving the problem for the learner, eliminate the irrelevant variables so they can focus on the target concept.
- **Task specification**: Make the goal concrete and achievable at the learner's current level.
- **Frustration control**: Keep the difficulty in the productive range — hard enough to require effort, not so hard it generates despair.
- **Fading**: Explicitly plan when and how the scaffold will be removed.

### Spiral Curriculum (Bruner, 1960)

The spiral curriculum is Bruner's framework for concept revisitation: introduce a concept simply, revisit it with increased complexity and breadth across multiple sessions. Each re-encounter builds on the last.

This maps directly to a single tutoring session as a micro-spiral:
- First pass: concrete example, simple case
- Second pass: abstract the pattern
- Third pass: apply to a novel variant

The spiral also explains why you should **intentionally re-surface concepts** from earlier in a session as later concepts build on them. "This is the same pattern we saw in X" is a scaffold, not a detour.

### Cognitive Apprenticeship (Collins, Brown & Newman, 1989)

The most complete framework for sequencing within a tutoring session. Six methods in a specific order:

1. **Modeling** — Expert solves a representative problem while making thinking visible. Annotated walkthroughs, think-aloud narration.
2. **Coaching** — Learner attempts; tutor provides hints, feedback, reminders, new tasks based on observed performance.
3. **Scaffolding** — Targeted support (worked examples, templates, constraints) that the tutor fades as competence grows.
4. **Articulation** — Learner explains their reasoning aloud. This is not optional — it is the mechanism by which implicit understanding becomes explicit and transferable.
5. **Reflection** — Learner compares their process to the expert's. Tutor highlights gaps and effective strategies.
6. **Exploration** — Learner formulates and solves their own problems. Indicates readiness; do not rush to this.

**Three sequencing principles from Collins et al.:**
- **Global before local**: Give the learner a full mental map of the domain before drilling into components. Teach what a decorator *does for you* before teaching how it is implemented.
- **Increasing complexity**: Introduce simple canonical cases first, then variants and edge cases.
- **Increasing diversity**: Practice across multiple distinct contexts so the learner learns *when* to apply the concept, not just *how*.

### Worked Example Effect (Kirschner, Sweller & Clark, 2006)

Directly relevant: novices learn better from studying worked examples than from solving problems with minimal guidance. The reason is cognitive load — problem-solving search exhausts working memory before learning can consolidate.

**Practical rule**: With novices (levels 1–2 on Bloom's), default to worked examples with think-aloud narration. Only move to unguided problem-solving once the learner can predict the next step in a worked example before you reveal it. This is the threshold.

The worked example effect fades as expertise grows (the "expertise reversal effect"): advanced learners benefit *more* from generating solutions independently than from studying examples. Recognize which regime the learner is in and switch accordingly.

---

## Concept Dependency / Knowledge Spaces

### Doignon-Falmagne Knowledge Space Theory (1985)

Knowledge Space Theory (KST) provides a mathematical formalization of the insight that knowledge in a domain is not linear — it is a partially ordered lattice of concepts where some must be learned before others, but many orderings are valid.

A **knowledge space** is the set of all *feasible knowledge states* a learner can be in. ALEKS (the adaptive math tutoring system) is built on KST and uses approximately 350 concepts for Algebra 1, generating millions of feasible knowledge states.

The key product of KST for tutoring is the **prerequisite frontier**: given a learner's current knowledge state, the frontier is the set of concepts they are *ready to learn next* — directly reachable with their current knowledge, not too easy, not requiring prerequisites they lack.

### Practical Prerequisite Graph

Even without a full KST implementation, you can reason with a simpler directed acyclic graph (DAG) of prerequisites:

```
understand functions
    └─► understand closures
            └─► understand decorators
                    ├─► write simple decorators
                    └─► understand decorator factories
                            └─► use @functools.wraps
```

For any concept a learner wants to learn, the tutor's first job is to **walk the prerequisite DAG upward** until it hits a concept the learner already knows. That is the start point.

### LLM Applicability

Recent research (2024–2025) demonstrates that LLMs can construct accurate prerequisite graphs for educational concepts without pre-built knowledge bases. The ACE system and related work show that LLMs can identify prerequisite relationships between concepts and generate structured knowledge graphs from topic descriptions.

**Practical implication**: An LLM tutor can, at session start, internally generate a prerequisite DAG for the target topic, then use diagnostic questions (Bloom's Remember/Understand level) to locate the learner's current position in that DAG. Teaching then proceeds forward through the DAG one node at a time.

### Knowledge Tracing

Knowledge tracing systems model the probability that a learner has acquired a knowledge component given their history of successes and failures. The key insight: **a single correct answer does not confirm learning**. Mastery is typically operationalized as 3+ correct responses across varied contexts before a concept is marked "acquired" and the next concept in the DAG is unlocked.

---

## Productive Failure

### What It Is

Manu Kapur's productive failure (PF) is a two-phase learning design where learners attempt to solve novel problems *before* receiving instruction:

**Phase 1 — Generation**: Learner attempts to solve a problem without being taught the method. They will likely fail or produce incomplete solutions. The tutor provides minimal guidance, encouraging multiple solution attempts.

**Phase 2 — Consolidation**: Tutor delivers explicit instruction on the canonical solution. Crucially, the instruction explicitly connects back to the solutions the learner generated in Phase 1, including the failed ones.

### Why It Works

The generation phase creates *cognitive activation*: the learner's failed attempts produce "mental slots" — representations of what the problem is, what constraints matter, what a solution needs to satisfy. When the correct method is then taught, it slots into these prepared representations rather than being stored as disconnected procedure.

Randomized controlled studies show PF learners demonstrate significantly better **conceptual understanding and transfer** than direct-instruction-first learners, even though procedural fluency is equivalent. The more distinct solution attempts a learner generates (even wrong ones), the better their post-instruction performance.

### Conditions for Success

PF only works when:
- The problem is *moderately difficult* — not trivially easy, not impossibly hard
- The learner can make *meaningful progress* through exploration (some prerequisite concepts are in place)
- Phase 2 explicitly references the Phase 1 attempts
- The learner attempts **multiple solution paths**, not just one

PF fails when the learner has **no prerequisites** for the concept being taught. If a learner has never encountered closures, asking them to "figure out how decorators work" before instruction produces random guessing, not productive struggle. Productive failure requires a foothold.

### Application to One-Session LLM Tutoring

This framework inverts the traditional "explain then practice" structure:

| Traditional | Productive Failure |
|---|---|
| Explain concept → assign problem | Pose problem → learner struggles → then explain |
| Learner learns procedure | Learner builds conceptual understanding |
| Transfer is poor | Transfer is strong |

**Practical implementation**: After confirming prerequisites exist (via ZPD calibration), pose the target problem *before* explaining the target concept. Ask "how might you approach this?" and "what else could you try?" Collect 2–3 attempts, then provide the canonical explanation that directly addresses what the learner tried. This is more effective than any amount of upfront explanation.

**Spaced repetition note**: Spaced repetition (Anki/SuperMemo) is a multi-session technique and has limited direct applicability within a single session. However, the underlying *desirable difficulty* principle applies: testing is more effective than re-studying, and introducing brief retrieval challenges of earlier-session concepts before moving on leverages the same mechanism.

---

## Practical Heuristics for Dynamic Curriculum Construction

These are the operational rules that fall out of the research above, synthesized for an LLM tutor that receives "teach me X" with no prior context about the learner.

### 1. Construct the prerequisite DAG first (Knowledge Space Theory)

Before doing anything else, mentally build a DAG of 4–8 prerequisite concepts for the target topic. This is the curriculum skeleton. The learner's diagnostic responses will determine the entry point.

**Example for "teach me decorators":**
```
understand functions → closures → first-class functions → decorators → decorator factories
```

### 2. Calibrate with 2 diagnostic questions, not a quiz (ZPD + Bloom's)

Ask one Remember-level and one Understand-level question about the most foundational prerequisite. Do not ask more than 2 before beginning. The goal is to locate the ZPD boundary quickly, not to comprehensively assess.

- If they nail both: start 2–3 nodes up the DAG from the prerequisite
- If they nail Remember but fail Understand: start at the prerequisite's Understand level
- If they fail Remember: go one node further back in the DAG

### 3. Open with a model, not a problem (Cognitive Apprenticeship + Worked Example Effect)

For a learner new to the concept, provide a worked example with explicit narration of your reasoning. "Here is a decorator. Here is what it does. Here is *why* this works." Make the expert thought process visible before asking the learner to do anything.

### 4. Pose a generation challenge before explaining the next layer (Productive Failure)

Once the learner has a foothold (can answer Understand-level questions), pose a problem one step beyond their confirmed knowledge *before* explaining it. Collect their attempt. Then explain. This ordering produces better conceptual retention than explaining first.

### 5. Test transfer with a variant, not a repeat (Knowledge Tracing)

Do not count a concept as "learned" after one correct answer. Pose the same concept in a different context: "Now what if the decorator needs to take an argument?" A learner who cannot adapt has procedural, not conceptual, mastery. Stay at the current node until transfer holds.

### 6. Re-surface earlier concepts as later ones build on them (Spiral Curriculum)

When introducing concept N+1, explicitly connect it back to concept N: "This is the same idea as the closure we looked at earlier — it's just being applied in a new context." This is not review; it is deepening the spiral. It also serves as a lightweight retrieval challenge that consolidates earlier learning.

### 7. Track the minimum hint level and adjust pace accordingly

If the learner is answering at hint-level 1 (general prompt), advance faster. If they consistently need hint-level 3–4, slow down and reinforce before advancing. VanLehn's research confirms that intervention granularity is one of the strongest predictors of tutoring effectiveness.

### 8. "Unit" of learning = one DAG node demonstrated in two contexts

The right unit for a tutoring session is not a concept, not a skill, and not a question — it is a concept *demonstrated in two distinct contexts*. One context confirms understanding; the second confirms transfer. When a learner can apply a concept to a variant they haven't seen before, move to the next node.

### 9. For novices, explain first; for intermediate learners, challenge first

The Kirschner-Sweller worked example effect and productive failure apply at different expertise levels:
- **Novice** (no prerequisites): Worked example first. Unguided problem-solving is cognitively overloading before prerequisites are in place.
- **Intermediate** (prerequisites confirmed): Challenge first, then explain. Productive failure delivers significantly better conceptual understanding.
- **Advanced** (multiple prerequisites, some application experience): Challenge with minimal scaffolding, reflect together, skip basic instruction.

Calibrate which regime applies at session start.

### 10. End with an articulation prompt (Cognitive Apprenticeship)

Before closing a concept or session, ask the learner to explain the concept back in their own words without reference to the examples used. This is not a test — it is the mechanism by which implicit understanding becomes explicit and transferable. If they cannot do it, the concept is not yet consolidated; do one more pass.

---

## Sources

- Bloom, B.S. (1956). *Taxonomy of Educational Objectives*. [Bloom's Taxonomy — UFL](https://teach.ufl.edu/resource-libraryold/blooms-taxonomy/)
- Anderson & Krathwohl (2001). Revised Bloom's Taxonomy. [University at Buffalo — Bloom's Revised](https://www.buffalo.edu/catt/teach/develop/design/learning-outcomes/blooms.html)
- Bloom, B.S. (1984). The 2 Sigma Problem. [Wikipedia — Bloom's 2 Sigma Problem](https://en.wikipedia.org/wiki/Bloom%27s_2_sigma_problem)
- Vygotsky, L.S. Zone of Proximal Development. [SimplyPsychology — ZPD](https://www.simplypsychology.org/zone-of-proximal-development.html)
- ZPD teacher application. [Structural Learning — ZPD Teacher's Guide](https://www.structural-learning.com/post/the-zone-of-proximal-development-a-teachers-guide)
- Bruner, J. Scaffolding theory. [Prospero Teaching — Bruner's Scaffolding Theory](https://www.prosperoteaching.com/scaffolding-in-teaching/what-is-bruners-scaffolding-theory/)
- Bruner, J. Spiral curriculum. [Structural Learning — Spiral Curriculum](https://www.structural-learning.com/post/the-spiral-curriculum-a-teachers-guide)
- Collins, A., Brown, J.S., & Holum, A. (1991). Cognitive Apprenticeship. [American Federation of Teachers](https://www.aft.org/ae/winter1991/collins_brown_holum)
- Collins, A., Brown, J.S., & Newman, S.E. (1989). Cognitive Apprenticeship. [Learning Theories Reference](https://www.learning-theories.org/doku.php?id=instructional_design:cognitive_apprenticeship)
- Doignon, J.-P., & Falmagne, J.-C. (1985). Knowledge Space Theory. [Wikipedia — Knowledge Space](https://en.wikipedia.org/wiki/Knowledge_space)
- ALEKS — Knowledge Space Theory application. [ALEKS Research Page](https://www.aleks.com/about_aleks/knowledge_space_theory)
- Kapur, M. (2015). Learning from Productive Failure. *Learning: Research and Practice*. [Tandfonline](https://www.tandfonline.com/doi/abs/10.1080/23735082.2015.1002195)
- Kapur, M. (2014). Productive Failure in Learning Math. *Cognitive Science*. [Wiley Online Library](https://onlinelibrary.wiley.com/doi/10.1111/cogs.12107)
- Kapur, M. Productive Failure (2025 overview). [Bold Science PDF](https://boldscience.org/wp-content/uploads/2025/04/Productive-Failure.pdf)
- Kirschner, P.A., Sweller, J., & Clark, R.E. (2006). Why Minimal Guidance Does Not Work. [Andy Matuschak Notes](https://notes.andymatuschak.org/zUiDqjKiS3udc3wcvcFbcpc)
- VanLehn, K. (2011). Relative Effectiveness of Human Tutoring, ITS, and Other Systems. [Semantic Scholar](https://www.semanticscholar.org/paper/The-Relative-Effectiveness-of-Human-Tutoring,-and-VanLehn/3b924661db089b3511465ae48e6400e20a1dd232)
- LLM-assisted prerequisite graph construction. [ACE: AI-Assisted Knowledge Graphs](https://jedm.educationaldatamining.org/index.php/JEDM/article/download/737/218)
- LLM curriculum knowledge graph. [arXiv — LLM Knowledge Graph Completion](https://arxiv.org/html/2501.12300v1)
- Spaced repetition research. [Justin Math — Cognitive Science of Spaced Repetition](https://www.justinmath.com/cognitive-science-of-learning-spaced-repetition/)
- Interleaving vs blocked practice. [MDPI — Interleaving Effectiveness](https://www.mdpi.com/2076-328X/15/5/662)
