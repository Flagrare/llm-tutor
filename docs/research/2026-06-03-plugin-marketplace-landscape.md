# Research: Claude Code Plugin Marketplace Landscape (mid-2026)

- **Slug:** `2026-06-03-plugin-marketplace-landscape`
- **Date:** 2026-06-03
- **Status:** complete
- **Triggered by:** Preparing to publish llm-tutor to a marketplace, needed to know what marketplaces actually exist (versus what feels like it should exist). "Publishing" a Claude Code plugin is just the GitHub repo URL — but discovery is the actual problem.
- **Informed:**
  - Forthcoming llm-tutor release plan — which channels to submit to and in what order
  - README distribution section — install instructions per channel
  - The `Topics` field on the llm-tutor GitHub repo — confirms `claude-code-plugin` is the de facto tag

## Question

For an independent author shipping a Claude Code plugin in mid-2026:

1. Does Anthropic run an official marketplace, and what's the submission process?
2. Is there a public community marketplace, also Anthropic-run, with a lower bar?
3. Which community-curated `awesome-*` lists are actually maintained, and what's the submission process for each?
4. Is the `claude-code-plugin` GitHub topic the de facto discovery surface, and how saturated is it?
5. Are there third-party hub sites (claudepluginhub, claudemarketplaces) that matter, or are they SEO-noise scrapers?
6. Anything else that ships meaningful traffic — Reddit, HN, Twitter?

## Sources

### [Anthropic — "Discover and install plugins" docs page](https://code.claude.com/docs/en/discover-plugins)
- **Authors / Org:** Anthropic (Claude Code docs)
- **Type:** vendor docs
- **Published:** evergreen, updated through 2026
- **Accessed:** 2026-06-03
- **Relevance:** high (primary)
- **What this contributed:** The authoritative explanation of the marketplace model. Establishes that Anthropic runs TWO marketplaces — `claude-plugins-official` (curated, auto-loaded in every install, browsable at [claude.com/plugins](https://claude.com/plugins)) and `claude-plugins-community` (third-party, opt-in via `/plugin marketplace add anthropics/claude-plugins-community`). Quote that resolves the central question: "The official marketplace is curated by Anthropic, and inclusion is at Anthropic's discretion. The in-app submission forms add plugins to the community marketplace, not the official one." Translation: independent authors target the community marketplace; Anthropic decides which plugins get promoted to official.

### [Anthropic — "Create plugins" docs page, "Submit your plugin to the community marketplace" section](https://code.claude.com/docs/en/plugins)
- **Authors / Org:** Anthropic (Claude Code docs)
- **Type:** vendor docs
- **Published:** evergreen
- **Accessed:** 2026-06-03
- **Relevance:** high (primary)
- **What this contributed:** The exact submission mechanism. Two in-app forms: [claude.ai/settings/plugins/submit](https://claude.ai/settings/plugins/submit) and [platform.claude.com/plugins/submit](https://platform.claude.com/plugins/submit). Approved plugins are pinned to a specific commit SHA in the catalog and "CI bumps the pin automatically as you push new commits." The catalog syncs nightly. Critical pre-submission step: run `claude plugin validate` locally — the review pipeline runs the same check on every submission alongside automated safety screening. Important constraint: "PRs opened directly against [`anthropics/claude-plugins-community`] are closed automatically" — the form is the only entrance.

### [`anthropics/claude-plugins-official` GitHub repo](https://github.com/anthropics/claude-plugins-official)
- **Authors / Org:** Anthropic
- **Type:** open-source repo (read-only mirror of internal catalog)
- **Published:** ongoing
- **Accessed:** 2026-06-03
- **Relevance:** high
- **What this contributed:** Concrete evidence of the official catalog's contents and submission shape. ~546 commits on main, actively maintained. README points external authors to the [plugin directory submission form](https://clau.de/plugin-directory-submission) (a short URL alias). No PR-based submission accepted. Includes internal plugins (Anthropic-maintained, e.g., `commit-commands`, `pr-review-toolkit`, `agent-sdk-dev`, `plugin-dev`, `security-guidance`, the LSP family, the integrations family) and approved third-party plugins.

### [`anthropics/claude-plugins-community` GitHub repo](https://github.com/anthropics/claude-plugins-community)
- **Authors / Org:** Anthropic
- **Type:** open-source repo (read-only nightly sync of community catalog)
- **Published:** ongoing
- **Accessed:** 2026-06-03
- **Relevance:** high
- **What this contributed:** Confirms the community catalog exists as a real, browsable artifact. 157 stars, 37 forks, 31 commits, no releases (the marketplace.json is updated in place, not released). Each plugin entry pins to a specific commit SHA. Direct PRs are auto-closed; the only entrance is the in-app submission form. This is the realistic primary submission target for llm-tutor.

### [GitHub topic: `claude-code-plugin`](https://github.com/topics/claude-code-plugin)
- **Authors / Org:** GitHub (topic mechanism); individual plugin authors apply the tag
- **Type:** GitHub topic page
- **Published:** ongoing
- **Accessed:** 2026-06-03
- **Relevance:** high
- **What this contributed:** The de facto passive-discovery surface. ~2,856 public repos carry the tag as of 2026-06-03, with recent updates concentrated in May–June 2026 (active ecosystem, not abandoned). Top repos hit tens of thousands of stars (e.g., `claude-mem` at ~80k). This is "free" discovery — adding the topic to the llm-tutor repo costs nothing but makes it appear here, in GitHub search, and in the data feeds that the hub sites scrape.

### [`hesreallyhim/awesome-claude-code` repo](https://github.com/hesreallyhim/awesome-claude-code)
- **Authors / Org:** hesreallyhim (community)
- **Type:** community curated list
- **Published:** active
- **Accessed:** 2026-06-03
- **Relevance:** high
- **What this contributed:** The most-starred community list by a wide margin — 45.6k stars, 4k forks, 1,157 commits, 383 open issues, currently undergoing a structural revamp ("Update in progress"). Covers skills, hooks, slash-commands, agent orchestrators, applications, AND plugins. Submission is PR-based; the README emphasizes "code quality, security, and originality" as gates. High signal — but also high competition for placement, since every active plugin author wants in.

### [`ComposioHQ/awesome-claude-plugins` repo](https://github.com/ComposioHQ/awesome-claude-plugins)
- **Authors / Org:** Composio (commercial; LLM-tooling vendor)
- **Type:** community curated list (vendor-published)
- **Published:** active
- **Accessed:** 2026-06-03
- **Relevance:** medium
- **What this contributed:** Second-tier curated list — 1.7k stars, 410 forks, 165 open PRs, 41 commits. PR-based submission with clear requirements documented in the README: "Addresses a real use case / Doesn't duplicate existing functionality / Follows the template structure / Has been tested." Worth submitting to as secondary surface; the high open-PR count suggests slow review but a lower placement bar than `hesreallyhim`.

### [`hekmon8/awesome-claude-code-plugins` repo](https://github.com/hekmon8/awesome-claude-code-plugins)
- **Authors / Org:** hekmon8 (community)
- **Type:** community curated list
- **Published:** last updated October 2025
- **Accessed:** 2026-06-03
- **Relevance:** low
- **What this contributed:** Negative evidence — listed on first-page search results but only 3 stars, 5 forks, 5 commits, no releases, last updated October 2025. Despite ranking highly in Google, the list is effectively dead. Useful for the report only as the "don't waste a PR here" finding. Many of the other `awesome-claude-code-*` repos in search results sit in the same condition.

### [`claudemarketplaces.com`](https://claudemarketplaces.com/)
- **Authors / Org:** [@mertduzgun](https://x.com/mertduzgun) (independent; "not affiliated with Anthropic")
- **Type:** third-party hub site
- **Published:** updated daily; current as of 2026-06-03
- **Accessed:** 2026-06-03
- **Relevance:** medium
- **What this contributed:** The most active independent aggregator. Claims ~2,500 marketplaces, ~20,400 skills, ~11,000 MCP servers indexed. Self-describes as "curated by install count, GitHub stars, and community votes" — algorithmic ranking over the public GitHub corpus, not a submission queue. Implication: there is no form to submit to; presence is automatic from the `claude-code-plugin` topic + repo metadata. Effort = zero, but ranking improves with stars and the visible install signal.

### [`claudepluginhub.com`](https://www.claudepluginhub.com/)
- **Authors / Org:** third-party (returned HTTP 429 during direct fetch; site behavior consistent with auto-scraping)
- **Type:** third-party hub site
- **Published:** updated daily per search snippets
- **Accessed:** 2026-06-03 (indirect, via search results)
- **Relevance:** low
- **What this contributed:** Second independent aggregator. Self-describes as rating "every plugin for quality, freshness, and safety" — also algorithmic scrape, not submission form. Functionally similar to claudemarketplaces but smaller. Same zero-effort presence pattern: tagging the repo gets you indexed.

### [Knightli — "Claude Code has a plugin marketplace now"](https://knightli.com/en/2026/05/23/claude-plugins-official-claude-code-plugin-directory/)
- **Authors / Org:** knightli.com (independent blog)
- **Type:** engineering blog
- **Published:** 2026-05-23
- **Accessed:** 2026-06-03
- **Relevance:** medium
- **What this contributed:** Independent walk-through of the marketplace shape from a user's perspective in mid-2026. Confirms the docs description matches the lived behavior: the official marketplace auto-loads, the community marketplace is opt-in, and the in-app form is the real submission path. Used as triangulation that nothing in the docs is aspirational.

### Reddit / Hacker News / Twitter
- **Authors / Org:** N/A
- **Type:** absence of evidence
- **Accessed:** 2026-06-03
- **Relevance:** low (negative finding)
- **What this contributed:** A targeted search for Reddit r/ClaudeAI plugin recommendation threads in 2026 returned no indexed discoverable threads. No "curated by [X] on Twitter" account surfaced in adjacent searches. Plugin discovery on social platforms appears to be incidental (someone tweets about a plugin they like) rather than channel-shaped (a maintained list). Treating these as non-channels is the right read.

## Synthesis

### The shape of the ecosystem in mid-2026

The plugin ecosystem is no longer "too new." Anthropic shipped a real two-tier marketplace model (official + community) sometime in late 2025 to early 2026 and it's now load-bearing — the official catalog auto-loads in every Claude Code installation, the community catalog is one command away. This is a meaningful change from the earlier "the repo URL IS the install endpoint" world; the URL is still the install endpoint, but discovery has consolidated.

The realistic channels for an independent author are:

| Channel | Submission process | Effort | Reach signal |
|---|---|---|---|
| **`claude-plugins-community`** (Anthropic, in-app form) | Form at [claude.ai/settings/plugins/submit](https://claude.ai/settings/plugins/submit) — pass `claude plugin validate` + automated safety scan, then Anthropic review. Pinned to commit SHA; CI auto-bumps. | Medium: validate locally, fill form, wait for review (timeline unstated) | High — installable via `@claude-community`, syncs nightly into the catalog visible at the GitHub mirror |
| **`claude-plugins-official`** (Anthropic, no application) | No process. "Inclusion is at Anthropic's discretion." Submitting to community is a prerequisite for ever being noticed for official. | N/A directly | Highest — auto-loaded in every install — but not a channel you "submit to" |
| **GitHub topic: `claude-code-plugin`** | Add the tag to the repo's `Topics` field | Trivial (one click in GitHub UI) | Medium-high — feeds both GitHub-native discovery and downstream hub-site scrapers |
| **`hesreallyhim/awesome-claude-code`** | PR to add a row in the curated list; README emphasizes quality/security/originality bar | Medium — write a clean PR with metadata row, possibly long review | High — 45.6k stars is real distribution, but undergoing a "Update in progress" restructure as of access date |
| **`ComposioHQ/awesome-claude-plugins`** | PR with template-conforming entry per CONTRIBUTING-in-README | Medium — open PR with structured metadata | Medium — 1.7k stars, 165 open PRs (slow review queue but lower bar) |
| **`claudemarketplaces.com` + `claudepluginhub.com`** | No submission. Algorithmic scrape of public GitHub. | Zero — happens automatically once the topic tag is applied | Low–medium — secondary SEO surface, ranks by stars/installs |

The non-channels:
- **Reddit r/ClaudeAI**: no curated plugin list thread surfaced; one-off mentions only
- **HN**: same — incidental, not channel-shaped
- **Twitter curator accounts**: no dedicated curator account surfaced
- **Most `awesome-claude-code-*` clone repos**: dead/abandoned by October 2025 (`hekmon8` is the clearest example; several others in the search results have similar low-commit profiles)

### The actionable picture for llm-tutor

The submission priority order, ranked by realistic reach-per-effort:

1. **Add the `claude-code-plugin` topic** to the llm-tutor GitHub repo. Zero effort, gets the plugin into the public corpus that `claudemarketplaces.com`, `claudepluginhub.com`, and GitHub's own topic page index from. This is the floor — there is no reason not to do this.

2. **Submit to `claude-plugins-community`** via [claude.ai/settings/plugins/submit](https://claude.ai/settings/plugins/submit). This is the real distribution channel — installable directly via `/plugin install llm-tutor@claude-community` once approved. Prerequisite: run `claude plugin validate` locally; passing it is the same gate the review pipeline applies. The review timeline is undocumented but the nightly catalog sync means once approved, listing is fast.

3. **Submit a PR to `hesreallyhim/awesome-claude-code`** for the additional 45.6k-star surface, AFTER the community-marketplace listing lands (so the PR can cite the official listing as a quality signal). Watch for the "Update in progress" structural change before committing PR shape.

4. **Submit a PR to `ComposioHQ/awesome-claude-plugins`** as a secondary surface. Lower bar than `hesreallyhim`; faster acceptance likely. Worth doing in parallel with the `hesreallyhim` PR.

5. **The third-party hub sites are not channels.** Once the topic tag and the community-marketplace listing are in place, indexing on `claudemarketplaces.com` and `claudepluginhub.com` happens automatically. No submission action is meaningful.

### Honest gaps

- **The community-marketplace review timeline is not documented.** "Synced nightly" tells us about catalog publishing, not approval latency. Build the release sequence assuming weeks not days; do not gate the public release on it.
- **The "official" marketplace is not addressable.** There is no application. Submitting to community is the only way the plugin enters the surface Anthropic looks at when picking promotions. Treat official-marketplace inclusion as a possible future outcome, never a planned step.
- **No social-graph discovery channel exists yet.** If llm-tutor wants concentrated reach beyond the catalogs, it has to make its own moment (HN post, X thread, Reddit post in r/ClaudeAI). The channels won't carry it.

## Downstream uses

- **llm-tutor release plan** — the four-step submission order (topic tag → community marketplace → `hesreallyhim` PR → `Composio` PR) is the canonical release sequence
- **llm-tutor README** — install instructions will document both `/plugin install llm-tutor@claude-community` (preferred, once approved) and the direct `/plugin marketplace add Flagrare/llm-tutor` (fallback, always works)
- **GitHub repo `Topics` field** — add `claude-code-plugin` as step zero of the release
