---
name: workflow
disable-model-invocation: true
description: >-
  The system-design plugin's end-to-end methodology — the manifest that ties the whole family together.
  Run this when you are starting a feature and want the full disciplined flow: brainstorm a spec, turn it
  into a PRD, derive NFRs, implement step-by-step while logging decisions, then pin the API contract and
  the C4 model. Use this whenever the user asks "how do I use system-design", "what's the workflow / the
  process / the order", "walk me through building a feature with this plugin", or wants to drive a feature
  from idea to implemented-and-documented in one disciplined pass. It orchestrates the sibling skills in
  order — [`prd`] (what to build & why), [`nfr`] (how well), [`adr`] (why each step was chosen), [`api`]
  (the public surface), [`c4`] (structure & relations) — and leans on the `superpowers:brainstorming`
  skill for the thinking at every decision point. Prefer running this flow over reaching for the
  individual skills ad-hoc, because the value is in the order and the feedback loop, not any one document.
---

The methodology of the system-design plugin. This is the manifest: follow the steps in order, keep the documents in sync, and let the slowest-but-surest path win.

## Prerequisite

The **`superpowers`** plugin must be installed and enabled. This flow leans on `superpowers:brainstorming` for the thinking at step 1 and at every step of the implementation loop. If it is not available, install it first.

## The flow

Work the steps in order. Each produces an artifact the next step builds on.

1. **Brainstorm the feature and define a spec.** Use the `superpowers:brainstorming` skill. Explore intent, constraints, and success criteria until you have a spec you both agree on.

2. **Convert the spec to a PRD.** Use the [`prd`] skill (`/prd`). It synthesizes the conversation into a problem→solution brief with user stories and implementation/testing decisions — no second interview.

3. **Define the NFRs from the spec.** Use the [`nfr`] skill (`/nfr`). Capture the measurable quality attributes the feature must satisfy. Leave their target values as `[TARGET]` for now — you will fill them in as you build.

4. **Implement the spec — step by step. THIS IS THE MOST CRITICAL PATH.**

   Take small, deliberate steps. **The rate of feedback is your speed limit.** Never take on a task that's too big — if a step can't be verified quickly, it's too big; split it.

   For **each** step, run this loop in order:

   - **4.1 — Brainstorm the step.** Use `superpowers:brainstorming` to decide *how* to take the step.
   - **4.2 — Log the decision.** Use the [`adr`] skill (`/adr`) to convert that brainstorm into a logged decision — so the *why* is captured the moment it's fresh.
   - **4.3 — Implement test-first.** Implement the ADR under `superpowers:test-driven-development` — write the failing test (it *is* the measurable check for the NFR criterion) before the code, then make it pass.
   - **4.4 — Get it reviewed.** Use `superpowers:requesting-code-review`, then `superpowers:receiving-code-review` to process the feedback rigorously before moving on.
   - **4.5 — Measure.** Fill in the matching `[TARGET]` values in the NFR document with what the step actually achieved.

   Repeat until the spec is implemented. The discipline of this loop — decide, log, test, review, measure — is what keeps the system honest as it grows.

5. **Fill in the API contract.** Use the [`api`] skill (`/api`). Pin the public surface the feature now exposes so consumers, ADRs, NFRs, and tests can cite it by name.

6. **Fill in the C4 model.** Use the [`c4`] skill (`/c4`). Place the feature in the architecture and wire up its relations.

## C4 — the house of resilience

C4 describes the app and its relations. It is the main place where you can see whether a new commitment will break something elsewhere — so it is the house of the app's resilience.

Keeping it in sync is essential: every feature must declare its relations to the others, so that no feature is silently isolated and no change quietly breaks a dependent. Because C4 is the one place those relations are made explicit, **the e2e tests are derived from this document** — the relations it records are exactly the integrations the e2e suite must exercise.

Never let C4 drift behind the code. A relation that exists in the code but not in C4 is a break waiting to happen with no test to catch it.
