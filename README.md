# system-design

A Claude Code plugin for software architecture & system design — a family of skills that capture a
system across complementary genres and keep them linked under one `design/` folder, plus a `workflow`
that drives a feature from idea to implemented-and-documented in one disciplined pass.

## Prerequisite

The **[`superpowers`](https://github.com/obra/superpowers)** plugin must be installed and enabled. The
`workflow` leans on `superpowers:brainstorming` for the thinking at step 1 and at every step of the
implementation loop.

## Skills

- **`workflow`** — the plugin's **methodology / manifest**. Run `/workflow` to drive the full flow:
  brainstorm a spec → `prd` → `nfr` → implement step-by-step (logging each decision with `adr` and
  filling NFR targets as you go) → `api` → `c4`. The order and the feedback loop are the point.
- **`prd`** — turn the current conversation into a **Product Requirements Document**: a problem→solution
  brief with an extensive numbered list of user stories plus implementation and testing decisions, saved
  as a design doc at `design/prd/<feature-slug>.md`. No interview — it synthesizes what you've already
  discussed and explored. Captures *what to build and why* (product intent), upstream of the other four.
- **`c4`** — model a system in C4 using **Structurizr DSL** (define the model once → navigable
  Context / Container / Component / Dynamic views), with code-level diagrams via Mermaid image views,
  viewed interactively with `structurizr/structurizr local`. Bundles a starter `workspace.dsl`,
  `Dockerfile`, and `run.sh`. Captures *what* the system is.
- **`adr`** — record architecturally significant decisions as **Architecture Decision Records** in
  **MADR** format, managed with **log4brains** (a browsable, searchable decision log with monorepo
  support). Bundles the MADR `template.md`, a commented `.log4brains.yml`, and a homepage. Captures
  *why* the system is that way.
- **`nfr`** — capture **non-functional requirements** (quality attributes — security, reliability,
  performance, usability, scalability, …) as a stable-ID'd `design/nfr.md` where every requirement has
  a testable acceptance criterion and links to the ADR that decided it. Bundles an NFR `template.md`
  and a quality-attributes reference. Captures *how well* the system must behave.
- **`api`** — document a module/SDK/library's **public API contract** as a stable, citable
  `design/api.md`: an export inventory plus, per export, its signature, parameters, return value,
  preconditions, and error model. Bundles an API-contract `template.md` and a reference anchored in
  Microsoft's SDK/library design guidance (Azure SDK Design Guidelines + the .NET Framework Design
  Guidelines), used as a `DO/AVOID` self-check while you write. Captures *what it does / how you call it*.

The five are companions: **PRD = what to build & why · C4 = what · ADR = why · NFR = how well · API =
what it does / how you call it**. PRD is upstream product intent; the other four refine it. C4 owns
step-by-step *flows* (dynamic views); the `api` skill owns the public *surface*. Inline TSDoc/JSDoc in
the code is a complementary per-symbol genre — `api.md` is the whole-surface contract.

A convention runs across all five: when a doc must reference something **not written yet** — the ADR an
NFR is *decided by*, a sibling/superseding ADR, a planned C4 element, a cross-linked sibling doc — it
uses **`[TARGET]`** as a visible, greppable placeholder, repointed once the target exists. A genre isn't
done while an unresolved `[TARGET]` remains (`grep -rn "\[TARGET\]" design/`).

## Workflow

The intended way to use this plugin is the `/workflow` flow — small, deliberate steps where **the rate
of feedback is your speed limit**:

1. **Brainstorm the feature and define a spec** — `superpowers:brainstorming`.
2. **Convert the spec to a PRD** — `/prd`.
3. **Define the NFRs from the spec** — `/nfr` (leave targets as `[TARGET]` for now).
4. **Implement the spec, step by step — the critical path.** For each step: `superpowers:brainstorming`
   to decide → `/adr` to log the decision → fill the matching `[TARGET]` in the NFR doc.
5. **Fill in the API contract** — `/api`.
6. **Fill in the C4 model** — `/c4`.

**C4 is the house of resilience.** It describes the app and its relations, so it is where you see whether
a new commitment will break something elsewhere. Keep it in sync — every feature declares its relations —
and derive the **e2e tests** from it: the relations C4 records are exactly the integrations the e2e suite
must exercise.

## Install

```
/plugin marketplace add Alex-La/system-design
/plugin install system-design@alex-la
```

Local development (editing this repo in place):

```
/plugin marketplace add ~/.claude/local-plugins
/plugin install system-design@local-dev
```

Then restart the session (or reload plugins). These skills are **invoked explicitly** — each carries
`disable-model-invocation: true`, so the model won't auto-trigger them; you run them as slash commands
(`/workflow`, `/prd`, `/c4`, `/adr`, `/nfr`, `/api`) when you decide the work calls for it. Use
`/workflow` to drive the whole methodology end-to-end; `/prd` to turn the conversation into a
requirements doc; `/c4` to design or document system architecture, draw C4 diagrams,
or model a system; `/adr` to record an architecture or design decision, start a decision log, or settle
"why did we choose X" / "should this be an ADR"; `/nfr` to write non-functional requirements or quality
attributes, set a quality bar / SLAs, or turn a pile of "must" rules into testable requirements; and
`/api` to document a public API/SDK surface, write an API contract, or reframe the API half of a
behavioural spec into its own doc.
