# Research: llm-tutor Design Foundations

- **Slug:** `2026-06-02-llm-tutor-design-foundations`
- **Date:** 2026-06-02
- **Status:** complete
- **Triggered by:** Pivot to "meta-tutor" vision — llm-tutor as a Claude Code plugin that teaches any subject the user brings (codebase, technology, project, concept) via Socratic method, with an explicit anti-dependency design goal. Needed empirical grounding before writing `/tutor-start` and committing to a gamification model.
- **Informed:**
  - The persona files (`output-styles/echo.md`, `cipher.md`, `vex.md`) — anti-dependency philosophy section
  - The project README — convivial-tool framing, "teach me this codebase" positioning
  - Forthcoming `/tutor-start` skill design — graduated prompts, Knowledge Space DAG, Productive Failure bifurcation
  - Forthcoming `state.json` schema — per-concept first-attempt tracking, two-application acquisition rule

## Question

For an LLM-powered Socratic tutor that constructs curricula on the fly for arbitrary topics:
1. What does the existing reference implementation (Boots, boot.dev) actually do internally, and what are its documented failure modes?
2. What does the current commercial + research LLM-tutor landscape look like in 2026, and what's the unclaimed market space?
3. What pedagogical frameworks support on-the-fly curriculum construction for novel topics?
4. Is the gamification (salmon currency + XP) empirically defensible, or is it cargo-culted Duolingo?
5. Is "designing AGAINST user dependency" a known design tradition, and what concrete patterns enforce it?

## Sources

### [Lane Wagner on the Engineering Behind Boot.dev](https://elite-ai-assisted-coding.dev/p/lane-wagner-boot-dev)
- **Authors / Org:** Lane Wagner (boot.dev founder), interviewed by Aaron Erickson (Elite AI-Assisted Coding)
- **Type:** engineering blog (interview)
- **Published:** unknown (2024 or 2025; the article cites Boots metrics that suggest late 2024)
- **Accessed:** 2026-06-02
- **Relevance:** high (primary)
- **What this contributed:** The single most-load-bearing source for what Boots actually does. Provided: (1) the "context curation beats volume" finding — they tried 100k tokens of student history and it made Boots worse, so they curate (lesson body + challenge + reference solution + student's current code + past struggles + history + mastery scores); (2) confirmation that the lesson solution stays in context and the prompt enforces non-leak; (3) the ~0.22% like rate even on the best LLM, which calibrates expectations for any LLM tutor. Lane's quote that became a guiding principle: *"Giving the right context to the LLM is like all the work."*

### [Boot.dev Trustpilot reviews](https://www.trustpilot.com/review/www.boot.dev)
- **Authors / Org:** anonymous user reviewers (Trustpilot)
- **Type:** user reviews
- **Published:** ongoing
- **Accessed:** 2026-06-02
- **Relevance:** high
- **What this contributed:** The documented user-experienced failure mode of Boots: when the Socratic prompt fails to find a good escalation, Boots "just repeats the task requirements and calls you 'cub' and tells you to figure it out," leaving users "extremely frustrated." This is the evidence base for the design decision to bake explicit hint layers (Layers 1–5) into our personas, rather than rely on emergent Socratic scaffolding from a system prompt alone.

### [Boot.dev Beat (June 2025)](https://www.boot.dev/blog/news/bootdev-beat-2025-06/)
- **Authors / Org:** Lane Wagner / boot.dev team
- **Type:** vendor blog
- **Published:** 2025-06
- **Accessed:** 2026-06-02
- **Relevance:** medium
- **What this contributed:** Confirms the pre-/post-completion prompt-branch design pattern — Boots's behavior shifts to "deepen understanding" mode after a lesson is complete, and this is implemented as an explicit branch keyed on a `lesson_completed` flag, not a soft instruction. Our persona files already reflected this intuition; this source confirmed it's the right structural choice.

### [Khanmigo overview — Khan Academy blog](https://blog.khanacademy.org/khanmigo-math-computation-and-tutoring-updates/)
- **Authors / Org:** Khan Academy
- **Type:** vendor blog
- **Published:** 2025
- **Accessed:** 2026-06-02
- **Relevance:** medium
- **What this contributed:** The closest commercial precedent for our Socratic-first stance. Khanmigo is built on "hints, not answers" as a founding constraint. It uses a pre-authored curriculum (the Khan Academy lesson tree), which clarifies what's NOT yet done commercially: dynamic curriculum for arbitrary user-brought topics.

### [ChatGPT Study Mode (FAQ)](https://help.openai.com/en/articles/11780217-chatgpt-study-mode-faq) and [announcement post](https://openai.com/index/chatgpt-study-mode/)
- **Authors / Org:** OpenAI
- **Type:** vendor docs
- **Published:** 2025-07
- **Accessed:** 2026-06-02
- **Relevance:** high
- **What this contributed:** The closest direct analogue to llm-tutor's "teach me anything" mode in a commercial product. Study Mode generates a session-scoped roadmap for any user-supplied topic and works Socratically through it. But it is *ephemeral* (no persistence across sessions), *generalist* (no codebase grounding), and limited to ChatGPT's context. This source establishes the design space we share and the gap llm-tutor fills: persistent progress + codebase tutoring.

### [TutorAI](https://tutorai.me/)
- **Authors / Org:** TutorAI team (no founder named on landing page)
- **Type:** commercial product page
- **Published:** ongoing
- **Accessed:** 2026-06-02
- **Relevance:** low
- **What this contributed:** Demonstrates that dynamic curriculum *outline* generation is commercially viable but typically shallow — generates a static course outline in seconds with no adaptive depth or per-concept calibration. Negative evidence: shows what NOT to do (one-shot outline generation without ongoing adaptation).

### [DeepTutor (open-source LLM tutor)](https://github.com/HKUDS/DeepTutor)
- **Authors / Org:** HKUDS research group (Hong Kong University)
- **Type:** open-source project + accompanying paper
- **Published:** 2025
- **Accessed:** 2026-06-02
- **Relevance:** medium
- **What this contributed:** Open-source reference for how an academic LLM-tutor system structures itself — useful for the implementation-pattern angle. Confirmed that "recursive prerequisite tracing" (asking the LLM to generate prerequisite graphs on the fly) is a viable cold-start approach for unknown topics.

### [Knowledge Space Theory (ALEKS / Doignon-Falmagne)](https://www.aleks.com/about_aleks/knowledge_space_theory) and [Wikipedia summary](https://en.wikipedia.org/wiki/Knowledge_space)
- **Authors / Org:** Jean-Paul Doignon (Université libre de Bruxelles), Jean-Claude Falmagne (UC Irvine); ALEKS Corporation as commercial implementer
- **Type:** academic theory + vendor doc + encyclopedia
- **Published:** original theory 1985; ALEKS deployment ongoing
- **Accessed:** 2026-06-02
- **Relevance:** high (primary theory)
- **What this contributed:** The foundational framework for "what order do I teach concepts in." Concepts form a directed acyclic graph of prerequisites; a learner's "knowledge state" is a subset of mastered concepts; teaching proceeds forward through the DAG one node at a time. The key empirical claim: mark a concept "acquired" only after two distinct applications, not one — a single right answer doesn't indicate mastery. This is the foundation of our `/tutor-start` design.

### [Vygotsky's Zone of Proximal Development — Structural Learning](https://www.structural-learning.com/post/the-zone-of-proximal-development-a-teachers-guide) and [SimplyPsychology summary](https://www.simplypsychology.org/zone-of-proximal-development.html)
- **Authors / Org:** original theory by Lev Vygotsky (1934); secondary write-ups by Structural Learning and SimplyPsychology
- **Type:** academic theory + secondary educational summaries
- **Published:** original 1934; secondaries ongoing
- **Accessed:** 2026-06-02
- **Relevance:** high
- **What this contributed:** The "graduated prompting" calibration pattern that REVERSES our earlier "ask what they know" plan. The ZPD framework establishes that direct knowledge questions ("what do you know about X?") are unreliable — learners are either humble or overconfident, and you can't tell which. Instead: apply prompts of increasing specificity (general cue → directed cue → partial model → full model) and observe the minimum level the learner succeeds at. That minimum IS the calibration. This is now load-bearing for `/tutor-start`'s opening turns.

### [Productive Failure (Manu Kapur)](https://boldscience.org/wp-content/uploads/2025/04/Productive-Failure.pdf) and [Bellwether: Productive Struggle](https://bellwether.org/publications/productive-struggle/)
- **Authors / Org:** Manu Kapur (ETH Zürich); Bellwether (education policy nonprofit)
- **Type:** academic paper + policy report
- **Published:** Kapur's original work 2008–2015; Bellwether 2024
- **Accessed:** 2026-06-02
- **Relevance:** high
- **What this contributed:** The "problem before explanation" pedagogical pattern, and crucially the *bifurcation* rule: this works for learners with prerequisites in place (intermediate regime), but with true novices, worked examples first (Kirschner-Sweller). This drives `/tutor-start`'s novice-vs-intermediate branch decision. Direct claim: randomized studies show problem-first produces significantly better conceptual transfer than explanation-first FOR LEARNERS WITH PREREQUISITES.

### [Bjork & Bjork on Desirable Difficulties (UCLA)](https://bjorklab.psych.ucla.edu/wp-content/uploads/sites/13/2016/04/EBjork_RBjork_2011.pdf)
- **Authors / Org:** Elizabeth Bjork and Robert Bjork (UCLA Bjorklab)
- **Type:** academic paper
- **Published:** 2011
- **Accessed:** 2026-06-02
- **Relevance:** high (primary)
- **What this contributed:** The empirical foundation for the salmon-cost mechanic. The "generation effect" — that requiring an attempt before assistance produces durable learning — is one of the most robustly replicated findings in the cognitive science of learning. The salmon cost is the operationalization of this in our plugin. This source is what lets us say "the salmon design is empirically defensible," not "we copied boot.dev."

### [Bavli et al. 2025 — ChatGPT and Learning Loss (PNAS)](https://www.pnas.org/doi/10.1073/pnas.2422633122) — secondary write-up at [The Hechinger Report](https://hechingerreport.org/kids-chatgpt-worse-on-tests/)
- **Authors / Org:** I. Bavli, A. Ho, R. Mahowald, K. Levy (lead authors); Princeton + collaborators
- **Type:** peer-reviewed academic paper (PNAS) + secondary education-press article
- **Published:** 2025
- **Accessed:** 2026-06-02
- **Relevance:** high (primary)
- **What this contributed:** Direct empirical evidence for the anti-dependency thesis: students using standard ChatGPT (answer-on-demand) scored 17% worse on subsequent unsupported tasks; students using Socratic-style tutoring did NOT show this degradation. This is the strongest single data point justifying our entire design stance.

### [MIT Media Lab — "Your Brain on ChatGPT" cognitive debt study](https://www.edtechinnovationhub.com/news/mit-study-shows-chatgpt-reshapes-student-brain-function-and-reduces-creativity-when-used-from-the-start)
- **Authors / Org:** Nataliya Kosmyna et al., MIT Media Lab; secondary coverage by EdTech Innovation Hub
- **Type:** academic study with EEG measurement; secondary news write-up
- **Published:** 2025
- **Accessed:** 2026-06-02
- **Relevance:** high
- **What this contributed:** The EEG-level evidence for "AI-first usage produces measurable neural under-encoding" — *cognitive debt*. Key sequence-dependent finding: independence-first → AI-revision produces strong encoding; AI-first → independence produces weak encoding. This single finding directly justifies our design constraint that the tutor must refuse help until an attempt is made. Reframes the salmon cost from "friction mechanic" to "evidence-based neural-encoding intervention."

### [Self-Determination Theory (Ryan & Deci)](https://selfdeterminationtheory.org/wp-content/uploads/2020/04/2020_RyanDeci_CEP_PrePrint.pdf)
- **Authors / Org:** Richard M. Ryan, Edward L. Deci (University of Rochester)
- **Type:** academic paper / theory overview
- **Published:** 2020 (theory dates from 1985 onward)
- **Accessed:** 2026-06-02
- **Relevance:** high (primary)
- **What this contributed:** The theoretical framework for distinguishing safe gamification (competence feedback) from harmful gamification (task-contingent tangible rewards that crowd out intrinsic motivation — the "overjustification effect"). Drove the design refinement: XP should be tied to first-attempt quality (competence signal), NOT bare completion (rewarded-presence pattern).

### [Why Duolingo's Gamification is a Trojan Horse (Divinations)](https://divinations.substack.com/p/why-duolingos-gamification-is-a-trojan-horse) and [Time for Duolingo to Ditch the Heart System (DuoPlanet)](https://duoplanet.com/its-time-for-duolingo-to-ditch-the-heart-system/)
- **Authors / Org:** Nathan Baschez (Divinations) and uncredited author (DuoPlanet)
- **Type:** engineering blog (Divinations) + fan-site critique (DuoPlanet)
- **Published:** Divinations 2023; DuoPlanet 2024
- **Accessed:** 2026-06-02
- **Relevance:** medium
- **What this contributed:** Critical perspective on Duolingo's Hearts system — punishes *failure* as a monetization mechanism, which crowds out learning (failure is the signal you need more practice, not a punishable offense). Sharpens our salmon-cost framing: the salmon punishes *skipping the struggle*, not failure. Important counter-evidence that gamification can be predatory; the source we'd lose if we wanted to gloss over the failure modes.

### [Ivan Illich — Tools for Conviviality (1973)](https://arl.human.cornell.edu/linked%20docs/Illich_Tools_for_Conviviality.pdf)
- **Authors / Org:** Ivan Illich
- **Type:** book (PDF hosted at Cornell)
- **Published:** 1973
- **Accessed:** 2026-06-02
- **Relevance:** medium (provides theoretical name for the design stance)
- **What this contributed:** The theoretical name "convivial tool" — a tool that preserves rather than replaces user autonomy. This is the language we should use in the project README and docs to position llm-tutor against the dependency-building default of most LLM products. The framing isn't just useful for marketing — it's a clarifying philosophical anchor.

### [E-bike for the Mind (Josh Brake)](https://joshbrake.substack.com/p/an-e-bike-for-the-mind) and [Generative AI is the E-bike of the Mind (Future Campus)](https://futurecampus.com.au/2025/02/14/generative-ai-is-the-e-bike-of-the-mind/)
- **Authors / Org:** Josh Brake (Harvey Mudd) and Future Campus editorial
- **Type:** engineering blog + EdTech publication
- **Published:** 2024–2025
- **Accessed:** 2026-06-02
- **Relevance:** medium
- **What this contributed:** Contemporary contestation of the "bicycle for the mind" metaphor — generative AI is increasingly framed as an "e-bike" (motor replaces effort) or "automobile" (skill never develops) rather than Jobs's original bicycle (effort preserved, capability amplified). This is the framing battle llm-tutor is entering. We can explicitly claim the original-bicycle framing and reject the e-bike drift.

### [Gradual Release of Responsibility (Pearson)](https://www.pearson.com/en-au/schools/insights-news/unlocking-student-potential-with-the-gradual-release-of-responsibility-model/)
- **Authors / Org:** Pearson (originally Fisher & Frey, 2008)
- **Type:** vendor educational publication
- **Published:** secondary article 2024
- **Accessed:** 2026-06-02
- **Relevance:** medium
- **What this contributed:** The "I do / We do / You do" pedagogical structure — formal architecture for a session that makes scaffolding explicitly temporary by design. The teacher's job in this model is *their own progressive irrelevance*. This is the structural language for how a tutoring session should be shaped, and it dovetails with the convivial-tool framing.

### Supporting bibliographies

For full per-angle bibliographies (including additional secondary sources used but not load-bearing for the synthesis), see:

- [`01-how-boots-actually-works.md`](./01-how-boots-actually-works.md) — Boots internal mechanics
- [`02-llm-tutor-landscape-2026.md`](./02-llm-tutor-landscape-2026.md) — commercial + research products
- [`03-pedagogy-and-curriculum-theory.md`](./03-pedagogy-and-curriculum-theory.md) — Bloom, ZPD, KST, productive failure
- [`04-gamification-evidence.md`](./04-gamification-evidence.md) — SDT, Bjork, Duolingo critiques
- [`05-anti-dependency-design.md`](./05-anti-dependency-design.md) — Illich, MIT EEG, convivial tools

## Synthesis

### What's now empirically backed (not just intuition)

| Design choice | Evidence |
|---|---|
| **The anti-dependency thesis** | MIT EEG study (2025) shows AI-first usage produces *cognitive debt* — measurable neural under-encoding. Bavli et al. 2025 (PNAS): ChatGPT-with-answers users scored 17% worse on later unsupported tasks; Socratic users didn't degrade. "Tool that makes itself unnecessary" is a measurable cognitive intervention, not a stylistic preference. |
| **The salmon cost** | Bjork & Bjork's generation effect — requiring an attempt before assistance is one of the most robustly replicated conditions for durable learning. The salmon cost punishes *skipping the struggle*, which is pedagogically defensible. Different from Duolingo's Hearts (punishes failure — predatory). |
| **Hint layers (ours: 5; Boots: 0)** | Boots's primary failure mode reported by users (Trustpilot): when stuck, Boots "just repeats the task and calls you 'cub'." It has no escalation path. Our 5-rung hint ladder directly addresses this. |
| **Pre-/post-completion behavior split** | Boots branches its system prompt on `lesson_completed` (boot.dev/blog/news/bootdev-beat-2025-06). Our personas already implement this ("in a lesson vs. between lessons"). |

### Sharpest design changes (what the research reversed or revised)

**1. Don't ASK what the user knows. PROBE with graduated prompts.**
The earlier design decision ("yes, probe existing knowledge first") was framed as a calibration *question*. The ZPD framework (Vygotsky + structural-learning summaries) says this is wrong. Direct knowledge questions are unreliable — learners are humble or overconfident, and you can't tell which. Instead: apply prompts of increasing specificity (general cue → directed cue → partial model → full model) and **observe the minimum level the learner succeeds at**. That minimum IS the calibration.

**2. Productive Failure: problem BEFORE explanation (for non-novices)**
Manu Kapur's work: posing the target problem before the canonical explanation produces significantly better conceptual transfer — *for learners with prerequisites in place*. For true novices, worked examples first (Kirschner-Sweller). This means `/tutor-start` needs a novice-vs-intermediate bifurcation:
- **Novice path:** worked example → guided practice → independent attempt ("I do / We do / You do")
- **Intermediate path:** challenge → struggle → connect to canonical explanation after attempt

**3. Concept "acquired" needs TWO distinct applications, not one**
Knowledge Space Theory (Doignon-Falmagne, ALEKS). A single right answer doesn't mark mastery. This changes `/tutor-done` semantics: the user claims a topic done, but the system tracks per-concept-application coverage and can flag "you've seen X used once but never applied it yourself" as a hidden gap.

**4. The Knowledge Space DAG as the foundation of `/tutor-start`**
For a given topic, the LLM generates a directed acyclic graph of 5–8 prerequisite concepts on session start. That's the curriculum. Teaching proceeds forward through the DAG, one node at a time. The DAG is internal control (per our earlier decision) but surfaceable on user request ("show me the path you've planned"). The LLM can generate the DAG even for highly specific cases like "auth in this codebase."

**5. XP tied to first-attempt quality, not bare completion**
Self-determination theory + gamification research: extrinsic rewards tied to *completion* slide into rewarded-presence territory and crowd out intrinsic motivation. XP tied to *first-attempt success* (sharpshooter-style) preserves the competence-feedback signal. Track per-concept "first-attempt success" vs "needed hint" vs "needed reveal" — XP awarded accordingly, not for finishing the topic.

**6. Build structured feedback collection from day one**
Boots's improvement loop is informal (Discord + thumbs-down). Lane Wagner: "Giving the right context to the LLM is like all the work." Their best like rates are ~0.22% — humbling. Any LLM tutor will fail often. Build feedback into MVP, not bolt it on.

### What stays the same

- **Three personas (Echo / Cipher / Vex)** — differentiation along voice + pedagogy + framing is good
- **Salmon currency model** — backed by Bjork's generation effect
- **Hint layers (5 rungs)** — directly addresses Boots's documented failure mode
- **Persistence across sessions** — confirmed against Khanmigo / Duolingo pattern
- **Plugin shape** (output styles + skills + hooks) — still right

### Two surprises worth flagging

1. **Boots's actual like rate is ~0.22%** — across both GPT-4o and Claude 3.5 Sonnet (Lane Wagner interview). Even the best-tuned commercial LLM tutor has low absolute user satisfaction. Design for graceful failure, not 100% accuracy.

2. **The unclaimed market is "teach me this codebase"** — ChatGPT Study Mode and TutorAI handle dynamic generic topics. *Nobody* handles "tutor me through how auth works in this specific repo." That's our distinctive design space. `/tutor-codebase <path>` should be a first-class command, not a sub-feature.

### Frameworks to adopt as language

- **"Convivial tool"** (Illich, 1973) — theoretical name for what we're building. Use in docs.
- **Original bicycle metaphor** (Jobs, reclaimed) — position against the "e-bike AI" drift where the motor replaces effort.
- **"Gradual Release of Responsibility — I do / We do / You do"** (Fisher & Frey, via Pearson) — pedagogical architecture for sessions.

### Design decisions still open after this synthesis

1. **Calibration depth** — How many graduated prompts before committing to novice/intermediate? Two? Three? Five? Balance accuracy vs. user patience.
2. **DAG surfacing UX** — When the user asks "show me the path," what does it look like? Concept names? Concept names + dependencies? Visual?
3. **Per-attempt tracking schema** — what does `state.json` look like at per-concept-per-attempt level? Could get heavy.
4. **Feedback collection format** — quick 👍/👎? Optional text? Per-session or per-concept?

## Downstream uses

- **Persona files** (`output-styles/echo.md`, `cipher.md`, `vex.md`) — "Why you exist" section in each persona was written before this catalog landed; the anti-dependency framing is what these sources empirically back. Cross-link to be added when personas are next revised.
- **Project README** — convivial-tool framing, "teach me this codebase" positioning, anti-dependency mission statement all trace to these sources.
- **Forthcoming `/tutor-start` skill** — graduated prompts (ZPD), Knowledge Space DAG (Doignon-Falmagne), Productive Failure bifurcation (Kapur), two-application acquisition rule (KST).
- **Forthcoming `state.json` schema** — per-concept first-attempt tracking (SDT/competence feedback), structured feedback collection (Boots learning).
- **Forthcoming `/tutor-codebase <path>` skill** — positioned as the distinctive value vs ChatGPT Study Mode + TutorAI.
