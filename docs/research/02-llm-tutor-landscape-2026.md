# LLM Tutor Landscape (2026)

> Research date: June 2026  
> Focus: How existing LLM-based tutoring products handle dynamic curriculum generation for user-specified topics

---

## Khanmigo (Khan Academy)

**How users specify what to learn:** Users are routed through Khan Academy's existing content library. There's an "Explore" mode where students can pick a topic from the library, but the interaction stays tethered to Khan's curated material.

**Internal curriculum or turn-by-turn?** Khanmigo does not construct a fresh curriculum for arbitrary topics. It enriches Khan Academy's fixed curriculum with Socratic dialogue. The architecture explicitly pulls context from pre-written exercises, hints, and solutions before responding. In 2025, it was updated so that Khanmigo "consistently takes the additional step to gather context from human-generated exercises, steps, hints, and solutions prior to responding."

**Knowledge calibration:** Calibration is course-position-based — Khanmigo knows where the student is in the Khan curriculum and what they've struggled with. There is no cold-start diagnostic for arbitrary topics.

**Progress / learning path visibility:** Users see their position within the existing Khan Academy skill tree, not an AI-generated path.

**What "completion" means:** Completion is defined by Khan Academy's pre-existing mastery system (exercise pass rates, skill badges), not by the AI.

**Key finding for llm-tutor:** Khanmigo is explicitly sandboxed. Per its documentation and independent reviews, it will not generate content for topics outside Khan Academy's content library. It is described as "curriculum-tethered" — the Socratic engine is impressive, but it won't go off-rails into "teach me anything." Users who need subjects outside Khan's core catalog are told to look elsewhere. As of 2025–2026, it has ~700,000 K-12 users, growing toward 1 million, but all within the fixed content envelope.

---

## Duolingo Max

**How users specify what to learn:** Duolingo's lesson tree (Birdbrain-sequenced) remains the primary path. Max adds two LLM-powered surfaces — **Video Call** (conversation with AI character "Lily") and **Roleplay** (scripted real-world scenario practice) — that sit on top of, but outside, the lesson tree.

**Internal curriculum or turn-by-turn?** A hybrid. The Video Call feature uses a structured four-part arc (opener → first question → free exchange → closer) defined by Learning Designers, with an LLM filling in the conversation dynamically. The system uses a "Conversation Prep" phase that pre-generates the first question at a specific CEFR level before the call begins. If the learner goes off-script, a mid-call evaluation checks "Does it seem like the learner wants to lead this conversation?" and if yes, abandons the plan.

**Knowledge calibration:** Birdbrain, Duolingo's ML system (built with Carnegie Mellon, running on PyTorch), continuously predicts per-concept correctness probability from millions of interaction signals. Every Roleplay prompt contains the learner's CEFR level to keep them in the Zone of Proximal Development. Birdbrain cut exercise delivery time from 750ms to 14ms with a Scala rewrite of the Session Generator.

**Progress / learning path visibility:** The existing lesson tree is the path. Max features don't generate new paths — they add conversational practice within the existing tree.

**What "completion" means:** Completion remains the Duolingo lesson tree completion, augmented by Birdbrain's spaced repetition.

**Post-session memory:** After each Video Call, the transcript is passed to an LLM with the prompt "What important information have we learned about the User?" The extracted facts are stored in a "List of Facts" injected into future session system prompts — a lightweight persistent learner model.

**Key finding for llm-tutor:** Duolingo's architecture cleanly separates the fixed curriculum (Birdbrain sequences the tree) from the open-ended conversational surface (LLM handles dialogue). The LLM does not generate the curriculum — it handles the expression layer. This is the most technically detailed published example of the "LLM as conversation surface, rules engine as curriculum" pattern.

**As of January 2026:** Video Call is free to all users. The platform now uses multiple LLMs (GPT-4, Claude, Gemini) behind the scenes with targeted prompts per role.

---

## OpenAI: ChatGPT Study Mode

**How users specify what to learn:** Any topic — completely open-ended. Study Mode (launched July 29, 2025, free on all tiers) activates via `/` → "Study and learn." Users provide context about their topic, level, and goals.

**Internal curriculum or turn-by-turn?** Study Mode generates a **high-level roadmap** of the topic — "a layered plan from foundational ideas to practical intuition" — at session start. It then works through the plan conversationally with Socratic questioning. Topics are broken into scaffolded sections, with the plan visible to the user. This is the closest commercial product to "teach me X → get a curriculum."

**Knowledge calibration:** Initial questions calibrate to the user's objective and skill level. Memory (if enabled) personalizes across sessions using past chat history. The current version runs on special system prompts tuned with input from educators and learning-science researchers; OpenAI plans to eventually bake these behaviors into the base model.

**Progress / learning path visibility:** A timeline/checklist shows concepts covered, which need review, and what comes next.

**What "completion" means:** No hard completion gate — the roadmap runs until the user is satisfied. The model adds knowledge checks (open-ended prompts) to confirm retention at each stage.

**Key finding for llm-tutor:** ChatGPT Study Mode is the most direct commercial analogue to llm-tutor's vision. It handles any topic, generates an explicit plan, and works Socratically through it. The critical difference from what we're building: Study Mode is ephemeral (one session, no persistent cross-topic learner model) and generalist (no specialization for codebases, repos, or novel technical domains). It does not understand "teach me this codebase" or "teach me this open-source project."

---

## Anthropic: Claude for Education (Learning Mode)

**How users specify what to learn:** Any topic. Learning Mode is a mode flag on Claude (available via university Claude for Education licenses), not a separate product. It works across all subjects.

**Internal curriculum or turn-by-turn?** Primarily turn-by-turn Socratic, not curriculum-generative. Instead of answering "how do I solve this calculus problem?", Claude asks "what do you think happens to the function as x approaches this value?" The mode inhibits direct-answer generation; it doesn't generate a learning path.

**Knowledge calibration:** No explicit diagnostic — calibration is implicit through the Socratic exchange itself.

**Progress / learning path visibility:** None surfaced to the user.

**What "completion" means:** Not defined — the session ends when the user decides.

**Key finding for llm-tutor:** Claude Learning Mode is the Socratic method as a mode flag — elegant in its simplicity, but it does not scaffold a path through material. It makes the LLM a better tutor (question-asker) but not a curriculum designer. Canvas LMS integration (2025) means students can use it inside course platforms without switching tools.

---

## Quizlet: Q-Chat

**Status:** Discontinued as of mid-2025. Q-Chat was the first fully-adaptive AI tutor built on the ChatGPT API alongside Quizlet's content library. It offered conversational tutoring within the context of a user's existing Quizlet study sets (flashcard decks).

**Architecture while live:** Fully turn-by-turn, grounded in the user's flashcard content. The LLM could Socratically drill the user on their set. It did not construct a curriculum — it used the deck as the knowledge boundary.

**Key finding for llm-tutor:** Q-Chat's discontinuation is a data point. Quizlet found that a pure content-anchored conversational tutor (no broader curriculum generation) did not sustain product differentiation. The user still had to build the study set first.

---

## Google: Socratic

**How users specify what to learn:** Photo/text/voice of a specific problem. Subject-agnostic but question-anchored — users bring a concrete question, not a topic they want to learn from scratch.

**Internal curriculum or turn-by-turn?** Entirely reactive/turn-by-turn. Socratic matches the question to visual explainers and educational resources from Google's index. No curriculum is constructed.

**Knowledge calibration:** None — each query is stateless.

**Progress / learning path visibility:** None.

**What "completion" means:** The question is answered. No continuity model.

**Key finding for llm-tutor:** Socratic is a homework assistant, not a tutor. It solves the "I have a specific problem in front of me right now" use case. The gap it leaves is the entire "I want to learn X from scratch" use case.

---

## Replit Learn

**How users specify what to learn:** Replit Learn (launched December 2025) is fixed-curriculum vibe coding education — structured video lessons + interactive exercises for building apps with AI assistance. Not user-specified topic generation.

**Architecture:** Fixed lesson tree (similar to boot.dev's model), not dynamic. Replit Agent assists with code within lessons, but the course structure is pre-authored.

**Key finding for llm-tutor:** Replit Learn is the closest competitor to boot.dev in the "learn to build with AI" space, but like boot.dev, it is fixed-curriculum. The "teach me this specific codebase" use case is entirely absent.

---

## Other Commercial Products

### TutorAI (tutorai.me)

The most direct "teach me anything" commercial product. Users specify any topic, and TutorAI generates a structured course with lessons, modules, and quizzes in seconds. The four-step flow: Choose Topic → AI Creates Course → Learn at Pace → Master Subject.

**Architecture:** Appears to be single-shot curriculum generation (topic → flat course outline) with static generated content, not adaptive. The marketing claims knowledge-level input influences course content, but the generated curriculum does not dynamically adapt as the user progresses. No published technical depth on prerequisites, knowledge tracing, or persistent learner modeling.

**Key finding for llm-tutor:** TutorAI ships the MVP of "teach me anything" but appears shallow: curriculum is generated once and static, not adaptive. Completion is user-defined (no mastery gates). This is the clearest validation that the market exists, and the clearest gap to exceed.

### YouLearn (YC-backed)

Upload PDFs, YouTube videos, slides, recorded lectures → AI generates notes, quizzes, and a conversational tutor for that content. Primarily a "learn from material you already have" product, not a "teach me a topic from nothing" product.

**Architecture:** RAG over uploaded content + conversational tutor. Turn-by-turn, not curriculum-generative. Progress tracking and personalized exams are mentioned but not architecturally detailed publicly.

**Key finding for llm-tutor:** YouLearn solves "I have a specific resource I need to understand." It does not solve "I don't know what resources exist — teach me this domain."

### Studdy (YC S23)

Includes a "Do Anything" lens for open-ended tutoring help. Primarily a K-12 homework product. No published dynamic curriculum architecture.

---

## Research Papers / Academic Work

### RPKT: Recursive Prerequisite Knowledge Tracing (arXiv:2508.11892, September 2025)

**The most directly relevant academic work.** RPKT solves the "unknown unknowns" problem: a learner who says "teach me backpropagation" doesn't know what they need to know first. 

**Architecture:**
- Knowledge Tracer Engine (GPT-4o with structured JSON prompts) decomposes any concept into 2–4 critical prerequisites per level
- Binary assessment interface — user says "know / don't know" for each concept (minimizes cognitive load)
- Recursive expansion: marking a concept "unknown" immediately expands it to its own prerequisites
- Traces L0 (target) through L3 or deeper, finding cross-domain mathematical foundations the learner "would not anticipate"
- No pre-built knowledge graph required — LLM generates prerequisite relationships on-the-fly for any domain

**Session flow for "teach me X":**
1. System identifies 4 key Level 1 concepts
2. User binary-assesses each
3. Unknown concepts expand to Level 2 prerequisites (recursive)
4. Once the knowledge boundary is found, system generates a hierarchical learning sequence from foundations up
5. Explanation "explicitly acknowledges the learner's existing knowledge" and addresses gaps

**Key finding for llm-tutor:** RPKT is the closest academic prototype to what we need. The prerequisite graph is built dynamically by the LLM, the depth of tracing is personalized to the individual learner's knowledge boundary, and it works for any domain without pre-built curricula. The binary assessment UX is a strong pattern worth adopting.

### IntelliCode: Multi-Agent LLM Tutoring (arXiv:2512.18669, December 2024)

Six specialized agents orchestrated through a StateGraph: skill assessment, learner profiling, graduated hinting, curriculum selection, spaced repetition, engagement monitoring. All agents share a centralized, versioned learner state with mastery estimates, misconceptions, review schedules, and engagement signals. Each agent is "a pure transformation over shared state under a single-writer policy" — auditable and reliable. Demonstrated on DSA problems; the architecture is domain-agnostic.

**Key finding for llm-tutor:** The multi-agent architecture with a centralized learner state is the pattern to beat for persistent, long-session tutoring. The curriculum selection agent enables "dependency-aware curriculum adaptation" — adjusting the path based on prerequisite mastery dynamically.

### EduPlanner: Multi-Agent Instructional Design (arXiv:2504.05370, April 2025)

Three agents in adversarial collaboration: evaluator, optimizer, question analyst. Introduces a Skill-Tree structure to model student background knowledge, and CIDDP (Clarity, Integrity, Depth, Practicality, Pertinence) as a 5-dimensional evaluation module. Generates lesson plans that iterate toward quality rather than accepting the first LLM output.

**Key finding for llm-tutor:** The adversarial refinement loop (generate → evaluate with CIDDP → optimize → repeat) is more reliable than single-shot curriculum generation. Directly applicable to our lesson plan generation step.

### SP-TeachLLM (MDPI Information, December 2025)

LLM tutoring framework for computer science education with four collaborative modules:
- **Curriculum Decomposition Module (CDM):** Uses Bloom's Taxonomy to structure learning objectives across cognitive levels (recall → understanding → application → creation)
- **Multi-Strategy Generation Module (MGM):** Applies Cognitive Load Theory to regulate informational complexity
- **Strategy Selection Module (SSM):** Selects explanations matching learner's estimated proficiency
- **Memory Augmentation:** Maintains session context

**Key finding for llm-tutor:** The CDM is the most directly applicable module — decomposing any topic against Bloom's Taxonomy gives a principled scaffold rather than a free-form outline.

### MALPP: Multi-Agent Learning Path Planning (arXiv:2601.17346, January 2026)

Three agents (Learner Analytics, Path Planning, Reflection) collaborate to generate personalized learning paths grounded in Cognitive Load Theory and Zone of Proximal Development. Tested on MOOCCubeX dataset with 7 LLMs, "significantly outperforms baseline models in path quality, knowledge sequence consistency, and cognitive load alignment."

**Key finding for llm-tutor:** The Reflection agent — which provides interpretable refinements to the generated path — is an underused pattern. A path that explains why it is sequenced the way it is builds user trust and allows correction.

### TutorLLM: Knowledge Tracing + RAG (arXiv:2502.15709, February 2025)

Fuses MLFBK (Multi-Features with Latent Relations BERT-based Knowledge Tracing) with a RAG scraper to predict individual learning states and personalize responses. +10% user satisfaction, +5% quiz scores vs. vanilla LLM.

**Key finding for llm-tutor:** Knowledge tracing (predicting per-concept mastery probability) is a stronger signal than conversation history alone. The MLFBK model is worth examining as a lightweight alternative to Bayesian Knowledge Tracing.

### GPTutor: Analogy-Driven Personalization (ACM L@S 2024, arXiv:2407.09484)

Generates personalized educational content anchored to the student's interests and career goals, using Chain-of-Thought prompting. Example: teaching recursion to a student who likes cooking via cooking analogies.

**Key finding for llm-tutor:** Interest-anchored analogies are a simple but high-leverage personalization vector that doesn't require a complex learner model — just asking "what do you care about?" at session start.

### Harvard Physics AI Tutor Study (Scientific Reports, June 2025)

RCT with 194 Harvard undergrads. AI-tutored students scored ~30% higher AND finished faster than active-learning classroom students. Students were more motivated and engaged. The AI tutor was fine-tuned with pedagogical best practices (Socratic, scaffolded, adaptive).

**Key finding for llm-tutor:** This is the strongest empirical validation that LLM tutoring outperforms traditional instruction when done correctly. The "done correctly" clause is load-bearing — the tutor was purpose-built, not a raw LLM.

---

## Open-Source LLM Tutors

### DeepTutor (HKUDS, ~24.5k GitHub stars)

The highest-starred open-source AI tutor. Key features:
- Five modes sharing one session: Chat, Solve, Quiz, Research, Visualize
- **Book Engine**: For any topic, decomposes into subtopics, dispatches a multi-agent pipeline that proposes outlines, retrieves sources, and compiles interactive pages with quizzes and concept graphs. Users can review proposals, reorder chapters, and chat alongside any page.
- Three-layer memory: L1 (append-only session traces), L2 (per-surface curated facts with citations), L3 (cross-surface synthesis)
- SKILL.md files define custom teaching personas (injected into system prompt)
- TutorBots: persistent autonomous tutors with their own workspace, deployable to Telegram/Discord/Slack

**Key finding for llm-tutor:** DeepTutor's Book Engine is the most sophisticated open-source implementation of "any topic → structured curriculum." The multi-agent outline-then-retrieve-then-compile pipeline is worth studying carefully. The SKILL.md persona system is directly relevant — we could use a similar mechanism for domain-specific tutoring personas (e.g., "teach this as a senior engineer reviewing a PR").

### tutor-gpt (Plastic Labs, ~142 stars as "Bloom")

Theory-of-Mind reasoning architecture that "dynamically reasons about your learning needs and updates its own prompts to best serve you." Uses Honcho for persistent user representations. Architecture adapts teaching strategy (not just content) based on inferred learner mental model. Turn-by-turn, not curriculum-generative.

**Key finding for llm-tutor:** The ToM-driven prompt self-modification is an interesting approach to calibration — instead of a separate learner model, the tutor's own system prompt is rewritten based on observed interaction patterns.

### OATutor / OATutor-LLM-Learner (UC Berkeley / CAHLR)

Open-source ITS using Bayesian Knowledge Tracing with LLM tutoring on top. Content is pre-authored (OpenStax problems with hints and scaffolds). Piloted in real classrooms as of Fall 2024.

**Key finding for llm-tutor:** The BKT + LLM combination gives a principled per-concept mastery probability, but requires pre-authored content — not suitable for arbitrary topics.

### OpenTutor (2024)

Block-based adaptive workspace: upload any material → AI generates notes, quizzes, flashcards, adaptive tutor. Self-hosted, 10+ LLM providers. Closest open-source equivalent to YouLearn.

---

## Specific Findings on Dynamic Curriculum Generation

### The Core Spectrum

Products and research fall along a single axis: **how much curriculum is pre-authored vs. generated on-demand.**

| Product | Curriculum Model |
|---|---|
| Khanmigo | Fully pre-authored (Khan Academy library) |
| Duolingo (Birdbrain) | Fully pre-authored tree, ML-sequenced |
| boot.dev | Fully pre-authored |
| Q-Chat (defunct) | Content-anchored (user's flashcard deck) |
| Socratic | Stateless (per-question) |
| Claude Learning Mode | No curriculum — Socratic only |
| ChatGPT Study Mode | Generates session roadmap on-demand |
| TutorAI | Generates full course outline on-demand (static) |
| DeepTutor Book Engine | Generates outline + retrieves content + compiles (multi-agent) |
| RPKT | Generates prerequisite graph recursively on-demand |
| IntelliCode | Multi-agent, dependency-aware, persistent learner state |

### The Dominant Pattern in Commercial Products (2026)

All major commercial products still anchor on pre-authored curriculum. The LLM is used to:
1. Generate conversational interaction over pre-authored content (Khanmigo, Duolingo Video Call, Q-Chat)
2. Produce supplementary explanations/analogies (Claude Learning Mode, ChatGPT Study Mode)
3. Adapt sequencing within a fixed set of content (Birdbrain)

Only ChatGPT Study Mode and TutorAI attempt fully on-demand curriculum generation at commercial scale. Study Mode is the higher-quality implementation but remains session-scoped with no persistence.

### The Dominant Pattern in Research (2025–2026)

Research is ahead of commercial products by roughly 18–24 months. The emerging consensus architecture:

1. **Dynamic prerequisite graph construction** (LLM generates relationships, no pre-built graph required) — RPKT
2. **Multi-agent pipeline** (separate agents for assessment, path planning, hinting, spaced repetition) — IntelliCode, MALPP
3. **Centralized versioned learner state** (mastery estimates + misconceptions + engagement signals, updated by each agent) — IntelliCode
4. **Adversarial refinement of generated curriculum** (generate → evaluate → optimize loop) — EduPlanner
5. **Bloom's Taxonomy decomposition** for structuring any topic into cognitive levels — SP-TeachLLM

### The Critical Gap (our opportunity)

No commercial or open-source product handles: "teach me **this specific codebase / repository / open-source project / private technical domain**" — where the knowledge doesn't exist in any training set and must be ingested from source artifacts (code, docs, PRs, commit history). YouLearn comes closest (ingest a document, tutor over it) but does not generate a curriculum for what's in the document; it just enables Q&A. DeepTutor's Book Engine gets close on arbitrary topics but doesn't handle live codebases or private knowledge domains as first-class inputs.

---

## Sources

- [Khanmigo 2026 Review — My Engineering Buddy](https://www.myengineeringbuddy.com/blog/khanmigo-reviews-alternatives-pricing-offerings/)
- [Khanmigo Math Computation and Tutoring Updates — Khan Academy Blog](https://blog.khanacademy.org/khanmigo-math-computation-and-tutoring-updates/)
- [Khanmigo Honest Review 2026 — AI Tools Bakery](https://aitoolsbakery.com/blog/khanmigo-review/)
- [Khanmigo AI Review 2025 — AI Flow Review](https://aiflowreview.com/khanmigo-ai-review-2025/)
- [What's New for 2025–26 — Khan Academy Blog](https://blog.khanacademy.org/whats-new-for-the-2025-26-school-year-big-updates-from-khan-academy-districts/)
- [Duolingo Max — Duolingo Blog](https://blog.duolingo.com/duolingo-max/)
- [AI Behind Every Video Call with Lily — Duolingo Blog](https://blog.duolingo.com/ai-and-video-call/)
- [Duolingo AI-Powered Lesson Generation — ZenML LLMOps Database](https://www.zenml.io/llmops-database/ai-powered-lesson-generation-system-for-language-learning)
- [Duolingo Structured LLM Conversations — ZenML LLMOps Database](https://www.zenml.io/llmops-database/structured-llm-conversations-for-language-learning-video-calls)
- [Birdbrain: Learning How to Help You Learn — Duolingo Blog](https://blog.duolingo.com/learning-how-to-help-you-learn-introducing-birdbrain/)
- [Duolingo AI Personalization: How Birdbrain Works — Build MVP Fast](https://www.buildmvpfast.com/blog/ai-learning-personalization-duolingo-ai-driven-lessons-2026)
- [Introducing Study Mode — OpenAI](https://openai.com/index/chatgpt-study-mode/)
- [ChatGPT Study Mode FAQ — OpenAI Help Center](https://help.openai.com/en/articles/11780217-chatgpt-study-mode-faq)
- [ChatGPT Study Mode Step-by-Step Guide — Ann Michaelsen](https://annmichaelsen.com/2025/07/31/chatgpts-new-study-mode-a-step-by-step-guide-for-teachers/)
- [ChatGPT Study Mode Guide — DataCamp](https://www.datacamp.com/tutorial/chatgpt-study-mode)
- [Introducing Claude for Education — Anthropic](https://www.anthropic.com/news/introducing-claude-for-education)
- [Claude Learning Mode — Northeastern University](https://learning.northeastern.edu/ai-student-guides-using-claude-learning-mode-to-study/)
- [Claude for Education — Educators Technology](https://www.educatorstechnology.com/2026/02/claude-for-education.html)
- [Introducing Q-Chat — Quizlet Blog](https://quizlet.com/blog/meet-q-chat)
- [Socratic by Google — Academic Help](https://academichelp.net/blog/edtech/socratic-by-google-an-innovative-ai-powered-learning-app.html)
- [Replit Learn — Replit](https://replit.com/learn)
- [TutorAI — tutorai.me](https://tutorai.me/)
- [YouLearn AI — youlearn.ai](https://www.youlearn.ai/)
- [YouLearn — YC](https://www.ycombinator.com/companies/youlearn)
- [Studdy — Product Hunt](https://www.producthunt.com/products/studdy)
- [DeepTutor — HKUDS GitHub](https://github.com/HKUDS/DeepTutor)
- [DeepTutor Website](https://deeptutor.info/)
- [tutor-gpt (Bloom) — Plastic Labs GitHub](https://github.com/plastic-labs/tutor-gpt)
- [OATutor-LLM-Learner — CAHLR GitHub](https://github.com/CAHLR/OATutor-LLM-Learner)
- [RPKT: Recursive Prerequisite Knowledge Tracing — arXiv:2508.11892](https://arxiv.org/abs/2508.11892)
- [IntelliCode: Multi-Agent LLM Tutoring — arXiv:2512.18669](https://arxiv.org/abs/2512.18669)
- [EduPlanner: LLM-Based Multi-Agent Instructional Design — arXiv:2504.05370](https://arxiv.org/abs/2504.05370)
- [SP-TeachLLM: Personalized Adaptive Programming Education — doi:10.3390/info16121045](https://doi.org/10.3390/info16121045)
- [MALPP: Multi-Agent Learning Path Planning — arXiv:2601.17346](https://arxiv.org/abs/2601.17346)
- [TutorLLM: Knowledge Tracing + RAG — arXiv:2502.15709](https://arxiv.org/abs/2502.15709)
- [GPTutor: Great Personalized Tutor — arXiv:2407.09484](https://arxiv.org/abs/2407.09484)
- [Harvard AI Tutoring RCT — Scientific Reports, June 2025](https://www.nature.com/articles/s41598-025-97652-6)
- [Review of Harvard AI Tutoring Study — Educational Technology and Change Journal](https://etcjournal.com/2025/11/10/review-of-kestin-et-al-s-june-2025-harvard-study-on-ai-tutoring/)
- [Open TutorAI — arXiv:2602.07176](https://arxiv.org/abs/2602.07176)
- [LLM Agents for Education: Advances and Applications — ACL Anthology EMNLP 2025](https://aclanthology.org/2025.findings-emnlp.743.pdf)
