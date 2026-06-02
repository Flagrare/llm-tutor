# Gamification Evidence Base

> Research compiled: 2026-06-02
> Scope: Evidence base for the llm-tutor salmon-economy and XP mechanics

---

## What Duolingo Actually Does and Why

Duolingo's gamification stack is: **XP** (points per lesson), **Streaks** (daily continuity chains), **Hearts** (lives lost on mistakes, free users only), **Gems/Lingots** (virtual currency for cosmetics), and **Leagues** (weekly XP leaderboards). These layers are heavily A/B tested — Duolingo ran 200+ tests on Android alone in 2024 — and they are optimized for **daily active users and retention**, not language acquisition.

### The retention vs. learning split

This is the critical distinction. Duolingo's own data shows streaks drive a 25% increase in lesson completions and push churn from ~47% (2020) to ~28% (2023). But independent observers note that after six months of Duolingo, most users cannot hold a basic conversation, and textbook/immersion learners outperform Duolingo users on speaking tests despite fewer total hours. Duolingo's 2024 conversational AI ("Lilly") improved measured learning outcomes by 30% — suggesting the core game loop was not optimized for them.

### Mechanics breakdown by purpose

| Mechanic | Primary driver | Effect on learning |
|---|---|---|
| XP | Engagement / volume | Neutral to negative (rewards quantity) |
| Streaks | Retention / habit | Mixed — see dedicated section |
| Hearts | Monetization | **Negative**: punishes failure, discourages experimentation |
| Leagues (leaderboards) | Social competition | ~15% more completions; no learning evidence |
| Gems | Cosmetics / monetization | Decorative; low impact either way |

### The Hearts problem is a case study in what not to do

Hearts penalize errors with loss of session progress. Critics from pedagogical and UX communities argue this directly contradicts the evidence that mistakes are necessary for durable learning. Duolingo Plus subscribers have unlimited hearts, making it a monetization mechanism disguised as learning design. This is the clearest example of a mechanic that **serves the business model at the expense of the educational mission**.

---

## Intrinsic vs. Extrinsic Motivation Research

### Self-Determination Theory (Deci & Ryan, 1985–2020)

SDT is the most robust framework for understanding motivation in educational contexts. Three psychological needs are foundational:

- **Autonomy**: A sense of ownership and volition over one's actions. Undermined by controlling rewards and punishments.
- **Competence**: The feeling of mastery and capability. Enhanced by challenge calibrated to skill level.
- **Relatedness**: Belonging and connection. Relevant to community and social features.

Both intrinsic motivation and **well-internalized** extrinsic motivation predict positive educational outcomes. The key word is "internalized": extrinsic motivation that feels autonomous (e.g., "I want to learn this because I value it") is healthy. Extrinsic motivation that feels controlling (e.g., "I need this to avoid losing my streak") is not.

### Cognitive Evaluation Theory (CET): the contingency problem

CET, a sub-theory of SDT, explains when rewards backfire. The mechanism:

1. Expected, contingent rewards (given *because* you did the task) signal external control.
2. This shifts the learner's perceived locus of causality from internal to external.
3. Intrinsic motivation declines as a result.

**What doesn't undermine motivation:**
- Unexpected rewards (the overjustification effect depends on expectation)
- Verbal praise and competence feedback (informational, not controlling)
- Task-noncontingent rewards (not tied to doing the specific task)

**Practical implication**: Tangible rewards for completing specific tasks are the highest-risk category. XP for clicking through lessons is exactly this pattern. XP for *demonstrating mastery* (getting it right on first attempt, passing a test) is closer to competence feedback.

### The Overjustification Effect (Lepper, Greene & Nisbett, 1973)

The landmark study: children who enjoyed drawing were told they'd receive a "Good Player Award" for doing so. After the reward, their spontaneous interest in drawing declined significantly versus control groups who received unexpected rewards or none.

**The mechanism**: When a salient external reason exists for doing something, people attribute their behavior to the reward rather than intrinsic interest, and their sense of intrinsic motivation diminishes accordingly.

**Critical nuance from meta-analyses** (Deci, Koestner & Ryan, 2001): The undermining effect is real but specific. Task-contingent tangible rewards are the danger zone. Competence-affirming verbal rewards actually *enhance* intrinsic motivation. The design question is: does this reward feel like recognition of skill, or payment for compliance?

---

## Desirable Difficulties / Productive Friction

Robert Bjork named this paradox in 1994: conditions that **slow down acquisition often accelerate long-term retention**. The core insight is the distinction between two memory systems:

- **Storage strength**: How deeply encoded in long-term memory.
- **Retrieval strength**: How easily accessible right now.

Most training optimizes retrieval strength (feels fast, smooth, fluent) at the expense of storage strength (durable encoding). The conditions that build storage strength require effortful processing — which feels slower and harder during practice.

### The five evidence-backed desirable difficulties

| Difficulty | Evidence | Application |
|---|---|---|
| **Spaced practice** | +80% retention vs. massed practice | Spaced repetition scheduling |
| **Interleaving** | Mixed practice > blocked practice on transfer | Vary topics within a session |
| **Retrieval practice** | Testing > re-reading for retention | Quizzes over re-watching |
| **Generation** | Attempting before seeing answer > studying first | Attempt the problem before hints |
| **Varied practice** | Variation > repetition for generalization | Different problem types |

### Application to AI tutoring specifically

AI tutors present a specific risk here: they make retrieval *too easy*. Asking an AI for the answer eliminates retrieval practice, removes generation effort, and gives the learner the feeling of understanding without the encoding benefit. The research on this is now direct:

- 2025 PNAS study (high school math): Students using standard ChatGPT scored **17% lower** on subsequent unsupported tasks than no-AI control groups.
- Students using a *tutoring-style* AI (guiding questions rather than answers) did not show this deficit.

The generation principle specifically supports a cost friction model: requiring effort before assistance maintains the generation effect.

---

## Failure Modes of Gamified Learning

### 1. Rewarding the wrong behavior
Point systems that reward completion (clicks, lessons opened, time-in-app) rather than mastery create incentives to optimize for points, not understanding. Users learn to game the gamification.

### 2. Leaderboard anxiety and dropout
Leaderboards consistently benefit the top performers while demotivating the majority. Research shows ~65% of users in competitive leaderboard systems receive no recognition, and the visible ranking of lower performers increases dropout, not effort.

### 3. Streak anxiety / sunk cost spiral
Streaks exploit the sunk cost fallacy productively at first (making users more likely to continue) but create anxiety as the streak grows. A long streak becomes something to protect rather than evidence of learning. The research on sunk cost in education shows that when students feel locked into a path by prior investment, they exhibit "passive involution" — compulsive non-productive engagement — which correlates with elevated anxiety.

### 4. Novelty decay
A 2023 systematic review found that gamification's motivational boost is partly a novelty effect: engagement increases in short-term studies but declines in longitudinal ones as the novelty of mechanics fades. This argues for mechanics that remain meaningful even when no longer new.

### 5. Shallow implementation ("PBL shell" problem)
Yu-kai Chou's critique: "PBL [points/badges/leaderboards] is the outer shell of game design. Bolt points, badges, and a leaderboard onto a boring product, and you get a boring product with scoring." Mechanics must serve psychological core drives (autonomy, mastery, meaning) — not substitute for them.

### 6. The Duolingo trap specifically
The Duolingo trap is designing for the wrong metric: daily active use instead of language acquisition. The two can come apart dramatically. A learner can maintain a 365-day streak and still be functionally unable to speak the language. This is the central risk of any gamified learning product — optimizing engagement when the actual goal is competence.

---

## Specifically for Our Salmon-Economy: Is It Justified?

### The mechanic
- **Boots (AI tutor)**: Costs 1 baked salmon per session. Without payment: 50% XP penalty.
- **XP**: Earned for completing topics independently.
- The design goal: discourage AI dependency, preserve productive struggle.

### What the evidence supports

**The salmon cost is well-grounded in the research.** Here is why:

**1. Generation effect (Bjork)**: Requiring learners to attempt problems before assistance is one of the most robustly evidence-backed conditions for durable learning. The cost friction forces a prior attempt. This is not arbitrary.

**2. The "GPT Tutor" vs "ChatGPT" distinction (2025 PNAS)**: The research distinguishes AI that answers from AI that guides. Boots uses the Socratic method by design. The cost adds a behavioral layer on top of that architectural choice — it filters for genuine stuck-ness rather than first-pass laziness.

**3. XP for independent completion is informational feedback, not just payment**: If XP maps to "I did this myself and got it right," it functions closer to competence feedback (which SDT says enhances intrinsic motivation) than to task-contingent tangible reward (which undermines it). The key is whether the XP feels like recognition of mastery or just logging presence.

**4. The salmon cost avoids the "expected tangible reward" failure mode**: The reward for working independently (XP) is expected and contingent, which is the risk zone. But the mechanic is better read as: *avoiding a penalty* (lost XP from using Boots without cost). Loss aversion framing can be more motivating than reward framing, and the penalty for Boots is a lesser penalty than viewing the full solution — which appropriately tiered the scaffolding.

### Where the evidence suggests caution

**1. XP as a pure completion counter is weak.** If XP is given for completing a topic regardless of first-attempt quality, it rewards volume over mastery. Consider: XP tied to first-attempt success (sharpshooter-style) versus XP given for any completion are meaningfully different mechanics. Boot.dev's sharpshooter system does this — first-attempt XP is higher. This distinction matters.

**2. Streaks need careful design or omission.** The evidence on streaks is genuinely mixed:
   - *For*: Builds the "I am a daily learner" identity; sunk cost as a feature; habit formation via consistency.
   - *Against*: Anxiety as streak grows; fear-based retention is "black hat" gamification; if the learner is traveling or ill, a broken streak becomes a disproportionate punishment; optimizing for daily cadence can conflict with spaced repetition (which benefits from variable-length gaps).
   - **Recommendation**: If streaks are implemented, provide streak freezes, frame them as "sessions this week" rather than "days without missing," and decouple them from any reward that makes breaking the streak feel catastrophic.

**3. Celebrate gains, but carefully.** Gains should be celebrated in a way that feels like competence recognition ("you solved that without help") rather than Skinnerian reward delivery ("here are your points"). The distinction is about information vs. control. Visual celebrations that reinforce mastery identity ("you're getting it") are better than point-counter animations that emphasize the transactional exchange.

**4. Cost visibility: yes, show it.** Making the salmon cost visible to users is correct. Transparency about the trade-off (spend resource → get help → lose XP advantage) supports autonomy (one of SDT's three needs). Hidden costs feel manipulative; visible costs feel like meaningful choice. The learner who consciously chooses to spend salmon and accept the XP penalty is exercising agency. That is healthy.

**5. The anti-dependency goal and the mechanics need to be explicitly connected.** SDT research shows that when the *rationale* for an external constraint is explained and internalized, it shifts from "controlling" to "autonomous." If learners understand *why* Boots costs something (struggle builds learning; fluency comes from working through problems), the cost feels less like an arbitrary penalty and more like a design principle they can adopt as their own. Explain the why.

---

## Sources

- Deci, E. L., Koestner, R., & Ryan, R. M. (2001). Extrinsic rewards and intrinsic motivation in education: Reconsidered once again. *Review of Educational Research*. https://journals.sagepub.com/doi/10.3102/00346543071001001
- Ryan, R. M., & Deci, E. L. (2020). Intrinsic and extrinsic motivation from a self-determination theory perspective. *Contemporary Educational Psychology*. https://selfdeterminationtheory.org/wp-content/uploads/2020/04/2020_RyanDeci_CEP_PrePrint.pdf
- Bjork, R. A., & Bjork, E. L. (2011). Creating desirable difficulties to enhance learning. https://bjorklab.psych.ucla.edu/wp-content/uploads/sites/13/2016/04/EBjork_RBjork_2011.pdf
- Lepper, M. R., Greene, D., & Nisbett, R. E. (1973). Undermining children's intrinsic interest with extrinsic reward. *Journal of Personality and Social Psychology*. (Overjustification effect landmark study)
- 2025 PNAS study on GenAI in high school math: https://www.pnas.org/doi/10.1073/pnas.2422633122
- Systematic review on gamified learning motivation (PMC, 2023): https://pmc.ncbi.nlm.nih.gov/articles/PMC10448467/
- Gamification misuse in language learning (arXiv, 2022): https://arxiv.org/pdf/2203.16175
- Boot.dev Boots wiki: https://www.boot.dev/blog/wiki/boots/
- Yu-kai Chou on PBL fallacy: https://yukaichou.com/gamification-study/points-badges-and-leaderboards-the-gamification-fallacy/
- Duolingo gamification case study (Trophy.so, 2026): https://trophy.so/blog/duolingo-gamification-case-study
- Duolingo hearts criticism (Duoplanet): https://duoplanet.com/its-time-for-duolingo-to-ditch-the-heart-system/
- Duolingo as Trojan horse critique (Divinations): https://divinations.substack.com/p/why-duolingos-gamification-is-a-trojan-horse
- Streaks design analysis (Medium/Bootcamp): https://medium.com/design-bootcamp/streaks-the-gamification-feature-everyone-gets-wrong-6506e46fa9ca
- Gamification failure modes (Growth Engineering): https://www.growthengineering.co.uk/dark-side-of-gamification/
- Neural basis of extrinsic reward undermining (PMC): https://pmc.ncbi.nlm.nih.gov/articles/PMC3000299/
- Stanford on sunk cost neuroscience (2026): https://news.stanford.edu/stories/2026/01/sunk-cost-effect-study-science-neuroscience
- Providing extrinsic reward for test performance (PMC): https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4740952/
- Kids who use ChatGPT as study assistant do worse on tests (Hechinger Report): https://hechingerreport.org/kids-chatgpt-worse-on-tests/
