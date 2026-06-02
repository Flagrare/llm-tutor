# Anti-Dependency Design — Prior Art and Frameworks

> Research for llm-tutor: "an LLM that exists to make itself less necessary."
> Date: 2026-06-02

---

## Existing Design Language

### The Bicycle Metaphor and Its Corruption

Steve Jobs introduced the "bicycle for the mind" framing in a 1990 interview for the documentary *Memory & Imagination*, grounding it in a 1973 *Scientific American* study by S.S. Wilson showing that a human on a bicycle surpasses every other species in locomotion efficiency. Jobs' formulation was explicitly about **leverage and multiplication of capability** — the bicycle does not pedal for you. It makes your effort go further.

The tension today is precisely that AI has drifted from bicycle to **e-bike**, and some critics argue further toward **automobile**: the motor replaces the effort, and the skill of locomotion is never built. Josh Brake's 2024 Substack piece "An E-Bike for the Mind" names this distinction directly. A Fortune piece frames it more starkly: Steve Jobs thought devices would become a bicycle for the mind, but their effect "is similar to that of smoking and junk food." The bicycle metaphor is now a contested design target, not a self-evident description.

**Marshall McLuhan's amplification-amputation law** is the harder theoretical statement: every technology is simultaneously an extension of one faculty and an amputation of another. A telephone extends reach; it atrophies the skill of being present. The design question is always: which amputation are we willing to accept?

### Ivan Illich: Convivial Tools (1973)

Illich's *Tools for Conviviality* is the deepest prior art for anti-dependency design, though it predates digital tools. His definition of a **convivial tool**: one that "allows its user to exercise their human autonomy and creativity" in "responsibly limited" ways. Illich warned explicitly that "the more we outsource competence to professionals and technology, the more helpless and dependent we become." He contrasted convivial tools — bicycles, books, hand tools — against manipulative tools — cars, hospitals, schools — which engender dependency and transform liberating potential into control.

Illich's criterion for a good tool: it must be usable by anyone without special training, must not require a professional intermediary, and must not generate a new class of dependent non-users. llm-tutor is essentially a Illichian convivial tool by aspiration: it exists to make the professional intermediary (the AI) progressively unnecessary.

### Post-Growth Design

A 2024 arxiv paper "Beyond Efficiency and Convenience" articulates what it calls **post-growth design**: in contrast to mainstream HCI directed at efficiency and convenience (which leads to deskilling and dependency), post-growth design challenges building for users "willing to invest time and effort," aiming to "decrease technological dependence and thereby increase autonomy." This is the closest named design tradition to what llm-tutor is building, though it is an emerging academic stance rather than an established product category.

**The honest answer to Question 1**: "anti-dependency by design" does not yet have a single canonical name. The closest clusters are: convivial tools (Illich), post-growth design (academic), augmentation vs. automation (HCI/workforce), and pedagogical scaffolding (education). We are assembling existing parts into a coherent product stance.

---

## Research on Cognitive Offloading and Tool Reliance

### The Cognitive Debt Framework (MIT, 2025)

The most empirically grounded finding: a 2025 MIT Media Lab EEG study ("Your Brain on ChatGPT: Accumulation of Cognitive Debt when Using an AI Assistant for Essay Writing Task") tracked 54 students across four writing sessions, measuring brain activity via high-density EEG. Key results:

- Students using ChatGPT showed **lower brain activity, weaker memory recall, and reduced ownership of their writing**.
- Students who started unaided and then revised with AI showed the **strongest brain-wide connectivity** — the best outcome.
- Students who started with AI and later wrote independently **struggled to activate the same neural networks**, producing "linguistically bland" essays.
- The term **"cognitive debt"** describes how reliance on generative tools reduces the brain's ability to encode, retrieve, and synthesize information over time.

The sequence matters. AI-first, then independence = deficit. Independence-first, then AI-assisted revision = enhancement. This is a directly actionable design signal.

### Age Asymmetry

Psychology Today (2026): adults over 46 showed higher critical thinking scores alongside lower AI reliance; participants 17-25 showed the inverse. More critically: **adults who offload thinking to AI lose capacity they built; children who offload may never build it at all.** This is the distinction between atrophy and arrested development — the design stakes are different depending on when in the learning arc the tool is introduced.

### Aviation and Automation

The aviation autopilot literature is the established prior case. Pilots with heavy autopilot experience show **measurable degradation in manual flying skills**. Air traffic controllers in automated environments show decreased situational awareness and slower problem-solving under system failure. The field term is **automation-induced complacency** — relevant because llm-tutor is in the same causal chain: any tool that reduces the frequency of a skill's exercise degrades that skill.

### The Performance Paradox

Mollick and colleagues (Penn/Wharton research): students given GPT-4 for homework showed **improved homework scores but scored 17% worse on their final exam** compared to students without AI access. AI can boost immediate task performance while simultaneously undermining durable learning. This is the "performance paradox" — the tool makes you look better while making you worse.

---

## Educational Pedagogy: Scaffolding as Temporary

### The ZPD and Gradual Release

Vygotsky's **Zone of Proximal Development** (ZPD) is the theoretical foundation: the space between what a learner can do independently and what they can do only with support. The ZPD is explicitly a **transitional zone** — the goal is always to shrink it by moving skills from "needs support" to "independent." Scaffolding (formalized by Bruner, Wood, and Ross, building on Vygotsky) is pedagogically defined as **temporary** structural support intended to be removed.

The **Gradual Release of Responsibility model** (Pearson & Gallagher, 1983) encodes this as "I do, we do, you do" — a formal three-phase architecture where responsibility transfers explicitly from teacher to learner. The teacher's goal is their own progressive irrelevance for each skill.

**This is the strongest clean precedent for llm-tutor's design philosophy**: the scaffold is not the building. A scaffold that becomes structural has failed.

### Desirable Difficulties (Bjork, 1994)

Robert Bjork coined "desirable difficulties" for conditions that slow immediate performance but accelerate long-term retention and transfer. The five empirically validated mechanisms: **spacing, interleaving, retrieval practice, generation, and varied practice**. All of them work by introducing friction that forces effortful processing.

The critical distinction: a difficulty is **desirable** when the learner can engage with it productively; it becomes **undesirable** when it exceeds the learner's current capacity. This means the anti-dependency tool must know where the learner is — calibrated friction, not uniform friction. The failure mode of poorly calibrated difficulty is not just inefficacy but discouragement.

### Productive Struggle

The Stanford SAIL lab, Bellwether Foundation (2025), and Edutopia have all named **productive struggle** as the pedagogical principle most threatened by AI tutors that give direct answers. The Bellwether report explicitly frames AI as changing "learning, effort, and youth development" and warns that without intentional governance, GenAI "displaces the productive struggle and authentic expression necessary for learning and identity formation."

---

## Examples of Products That Resist Becoming Necessary

### Khanmigo: The Socratic Constraint as Core Design

Khan Academy's Khanmigo is the clearest commercial implementation of anti-dependency design in the AI tutor space. Its founding constraint: **never give the direct answer**. Every interaction unfolds as hints and reflective pauses. The system is explicitly prompted: "You are a Socratic tutor. Don't give me answers but lead me to get to them myself." Khanmigo grew from 68,000 to 700,000 users in one year, suggesting the market does not reject this constraint.

A controlled comparison showed students using a "refuse to give answers" tutor-prompted version of ChatGPT achieved **nearly double the short-term gains** of those using vanilla ChatGPT. Restraint is not a product weakness — it is a pedagogical mechanism.

### Tutor CoPilot

A separate AI system designed to generate **scaffolding suggestions for human tutors**, not to replace tutors. It suggests guiding questions and hints, keeping the human tutor as the responsible agent and the student in productive struggle. The distinction from Khanmigo: the AI advises the human teacher rather than directly tutoring the student. This keeps an additional layer of human judgment in the loop.

### Woebot (Cautionary Tale)

Woebot was the most prominent attempt at a CBT-based mental health chatbot. It refused to substitute for professional care, positioning itself as supplementary. It shut down its consumer app on June 30, 2025. The lesson is ambiguous: it may have failed because anti-dependency is commercially unviable at scale (users who get better stop subscribing), or because it could not compete with generalist LLMs. The ethical design (decline to become a dependency) may have been commercially punished — this is a real risk to model for llm-tutor.

### Duolingo (Negative Example)

Duolingo represents the anti-pattern: gamification mechanics (streaks, XP, leagues) that optimize for **engagement over competence**. Users report declining quality as the platform prioritizes retention over learning outcomes. Research shows users complete the "Spanish tree" but cannot hold basic conversations. The streak anxiety and compulsive checking resemble addictive social media more than education. Duolingo is the clearest example of a learning tool captured by engagement metrics — a cautionary design attractor.

---

## Failure Modes of the Anti-Dependency Stance

### 1. Elitist Gatekeeping

The strongest critique: withholding answers and enforcing productive struggle presupposes the learner has the baseline capacity to struggle productively. A first-generation college student who needs to pass an exam to keep their scholarship does not have the luxury of deliberate practice philosophy. A learner without a strong support network who gets stuck with a Socratic AI is simply stuck.

The equity literature confirms this: the UK's A-level algorithm failures showed AI-mediated education systematically disadvantages students from under-resourced schools. Designing friction is a luxury available to learners who have slack. **Anti-dependency design must include an escape valve for genuine blocking moments**, or it reproduces class dynamics inside the tool.

### 2. Mistaken Difficulty

Bjork's distinction is sharp: undesirable difficulties (those beyond the learner's ZPD) produce discouragement, not growth. A tool that withholds help when the learner genuinely cannot proceed is not teaching productive struggle — it is teaching helplessness. The difference between these is calibration. Any anti-dependency design depends on accurate real-time assessment of where the learner is.

### 3. The Autonomy Paradox

Designing a tool to make itself unnecessary requires modeling the user's growth — which requires the user to trust the tool's judgment about when they no longer need it. This creates a subtle dependency on the tool's assessment of independence. If the tool misjudges, the user is either cut off too early (stuck) or too late (still dependent on the tool's approval before attempting independence).

### 4. Commercial Unsustainability

A tool that succeeds at its mission loses its users. Subscription models are directly misaligned with the goal of making users independent. This is not a design problem but a business model problem — and it killed Woebot's consumer product. llm-tutor needs to model this explicitly: what is the revenue model when success looks like churn?

### 5. Friction as Performance, Not Pedagogy

The risk of conspicuous refusal: a tool that prominently withholds answers signals virtue but may not improve outcomes if the friction is theatrical rather than calibrated. Users who feel patronized disengage. The anti-dependency stance can become moralizing rather than functional.

---

## Practical Design Patterns for Enforcing Non-Dependency

These are patterns with at least some empirical grounding or strong precedent:

**1. Answer Withholding + Hint Cascade**
Default: never give the full answer. Offer a hint, then a follow-up hint, then a leading question. Only provide the answer if the learner has genuinely exhausted capacity. Khanmigo/Tutor CoPilot implement this. The MIT EEG study shows the brain processes differently when the answer is earned vs. received.

**2. "Do it first, then check" Sequencing**
Require independent attempt before AI assistance is available. The MIT study shows AI-first leads to cognitive debt; independence-first followed by AI-assisted review leads to stronger encoding. The tool can enforce this by blocking the "help" affordance until a draft or attempt exists.

**3. Retrieval Practice Before Hint**
Before offering any hint, ask the learner to recall what they already know about the problem. "What have you tried? What do you know about this type of problem?" Forces retrieval, which is itself a learning event (Bjork's retrieval practice effect), before the scaffold is engaged.

**4. Progressive Disclosure with Explicit Fading Schedule**
Like ZPD scaffolding: track which types of problems the learner has solved without help and progressively remove scaffolding on those problem types. The tool explicitly models what it is no longer needed for and surfaces that to the learner.

**5. Calibrated Struggle Windows**
Set a time window (e.g., 5–10 minutes) before the tool intervenes. Research on productive struggle suggests this window is where learning happens. The tool can make this explicit: "I'll let you work on this for a few minutes before we look at it together."

**6. Metacognitive Prompts Over Answers**
Instead of answering "what is the answer?", answer "what is a good way to think about this type of problem?" — teaching the skill of approaching problems, not the solution to this instance. Shifts the locus of knowledge from the tool to the learner.

**7. Success Attribution to the Learner**
When the learner solves something, attribute the success explicitly to their reasoning, not the tool's hints. Conversely, when the tool helps heavily, make that visible: "I gave you a lot of hints on this one — try a similar problem on your own." Behavioral research on self-efficacy (Bandura) shows attribution matters for whether success generalizes.

**8. Explicit Offboarding / "You Don't Need Me For This Anymore"**
Surfaces the graduation moment. When a skill has been demonstrated independently across N instances, the tool explicitly tells the learner they no longer need the tool for that skill. This turns the product's goal (make itself unnecessary) into a feature rather than a bug.

**9. Deliberate Latency / Friction Before Help**
A small imposed delay (10–30 seconds) before the hint appears. Not punitive — framed as "think time." Forces the brain to attempt retrieval before receiving input. Low-cost to implement, meaningful cognitive effect.

**10. Process Transparency ("Here's What I'm Doing")**
When the tool does help, narrate the reasoning process rather than providing the answer. Models expert thinking rather than transferring a result. The learner internalizes the process, not the solution. Over time the tool's narration voice becomes internal.

---

## Sources

- [Steve Jobs "Bicycle for the Mind" (The Marginalian, 1990 interview)](https://www.themarginalian.org/2011/12/21/steve-jobs-bicycle-for-the-mind-1990/)
- [An E-Bike for the Mind — Josh Brake (Substack)](https://joshbrake.substack.com/p/an-e-bike-for-the-mind)
- [Generative AI is the e-bike of the mind — Future Campus](https://futurecampus.com.au/2025/02/14/generative-ai-is-the-e-bike-of-the-mind/)
- [Steve Jobs' tech effect on brains like smoking/junk food — Fortune](https://fortune.com/article/steve-jobs-tech-effect-brains-smoking-junk-food-bicycle-for-mind-royce-banning-apple/)
- [Desirable Difficulties in Theory and Practice — Bjork & Bjork (2020, PDF)](https://www.waddesdonschool.com/wp-content/uploads/2021/02/Desriable-Difficulties-in-theory-and-practice-Bjork-Bjork-2020.pdf)
- [Making things hard on yourself, but in a good way — Bjork (ResearchGate)](https://www.researchgate.net/publication/284097727_Making_things_hard_on_yourself_but_in_a_good_way_Creating_desirable_difficulties_to_enhance_learning)
- [Productive Struggle: The Future of Human Learning in the Age of AI — Stanford SAIL](https://ai.stanford.edu/blog/teaching/)
- [Productive Struggle: How AI Is Changing Learning, Effort, and Youth Development — Bellwether](https://bellwether.org/publications/productive-struggle/)
- [Using AI to Encourage Productive Struggle in Math — Edutopia](https://www.edutopia.org/article/using-ai-encourage-productive-struggle-math-chatgpt-wolfram-alpha/)
- [Cognitive Consequences of AI — Indian Journal of Behavioural Sciences (2025)](https://journals.lww.com/ijbs/fulltext/2025/07000/cognitive_consequences_of_artificial_intelligence_.8.aspx)
- [Your Brain on AI: Cognitive Offloading, Debt, and Atrophy — Psychology Today](https://www.psychologytoday.com/us/blog/psych-unseen/202605/your-brain-on-ai-cognitive-offloading-debt-and-atrophy)
- [Adults Lose Skills to AI. Children Never Build Them — Psychology Today](https://www.psychologytoday.com/us/blog/the-algorithmic-mind/202603/adults-lose-skills-to-ai-children-never-build-them)
- [MIT study: ChatGPT reshapes student brain function — EdTech Innovation Hub](https://www.edtechinnovationhub.com/news/mit-study-shows-chatgpt-reshapes-student-brain-function-and-reduces-creativity-when-used-from-the-start)
- [Cognitive debt: MIT paper on AI and brain atrophy — Medium/Bootcamp](https://medium.com/design-bootcamp/cognitive-debt-what-i-learned-from-mits-paper-on-ai-and-brain-atrophy-dbb54f7f064a)
- [MIT study suggests too much AI use increases cognitive decline — Nextgov](https://www.nextgov.com/artificial-intelligence/2025/07/new-mit-study-suggests-too-much-ai-use-could-increase-cognitive-decline/406521/)
- [The Paradox of Augmentation: AI-Induced Skill Atrophy — Wiley/Human Behavior and Emerging Technologies (2026)](https://onlinelibrary.wiley.com/doi/10.1155/hbe2/8303770)
- [Post-apocalyptic education — Ethan Mollick (One Useful Thing)](https://www.oneusefulthing.org/p/post-apocalyptic-education)
- [The future of education in a world of AI — Ethan Mollick](https://www.oneusefulthing.org/p/the-future-of-education-in-a-world)
- [Assigning AI: Seven Approaches for Students — Mollick & Mollick (SSRN)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4475995)
- [The Shallows: What the Internet Is Doing to Our Brains — Nicholas Carr](https://www.nicholascarr.com/?page_id=16)
- [AI's Cognitive Erosion — Hampton Global Business Review](https://hgbr.org/ais-cognitive-erosion/)
- [Vygotsky Scaffolding Theory and ZPD — CloudAssess](https://cloudassess.com/blog/vygotsky-scaffolding-theory/)
- [Gradual Release of Responsibility — Pearson Schools](https://www.pearson.com/en-au/schools/insights-news/unlocking-student-potential-with-the-gradual-release-of-responsibility-model/)
- [Tools for Conviviality — Ivan Illich (Wikipedia)](https://en.wikipedia.org/wiki/Tools_for_Conviviality)
- [Tools for Conviviality — Full text (Cornell/ARL PDF)](https://arl.human.cornell.edu/linked%20docs/Illich_Tools_for_Conviviality.pdf)
- [Hidden functions of sycophancy in AI: cognitive dependency — Springer/AI & Society](https://link.springer.com/article/10.1007/s00146-026-02993-z)
- [Khanmigo AI tutor — AI Competence, Socratic design](https://aicompetence.org/ai-socratic-tutors/)
- [Khanmigo: Khan Academy's GPT-4 AI Tutor Scaling Education](https://reruption.com/en/knowledge/industry-cases/khanmigo-khan-academys-gpt-4-ai-tutor-scaling-education)
- [From Problem-Solving to Teaching Problem-Solving: Aligning LLMs with Pedagogy using RL — arxiv](https://arxiv.org/pdf/2505.15607)
- [Woebot shuts down — STAT News](https://statnews.com/2025/07/02/woebot-therapy-chatbot-shuts-down-founder-says-ai-moving-faster-than-regulators/)
- [Duolingo gamification vs. learning — Paradox of Learning (Economy of Meaning)](https://theeconomyofmeaning.com/2025/08/25/a-critical-look-at-how-to-make-learning-as-addictive-as-social-media-a-ted-talk-about-duolingo/)
- [Beyond Efficiency and Convenience: Post-growth Design — arxiv (2024)](https://arxiv.org/pdf/2404.17264)
- [Calculator debate — The Conversation](https://theconversation.com/weapons-of-maths-destruction-are-calculators-killing-our-ability-to-work-it-out-in-our-head-44900)
- [Equity and AI in Education — arxiv](https://arxiv.org/pdf/2104.12920)
