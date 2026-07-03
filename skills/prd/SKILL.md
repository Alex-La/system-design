---
name: prd
description: >-
  Turn the current conversation into a Product Requirements Document (PRD) — a problem→solution brief
  with an extensive numbered list of user stories plus implementation and testing decisions — saved as a
  design doc next to the code. No interview: it synthesizes what you've already discussed and explored,
  not a fresh questionnaire. Use this whenever the user wants to "write a PRD", "spec out this feature",
  capture what we're about to build, turn a brainstorm or design discussion into a requirements doc, or
  produce a hand-off brief an engineer (or agent) can implement from. This is the upstream member of the
  system-design family: PRD captures *what to build and why* (product intent), which the others then
  refine — [`c4`] into *what the system is* (structure), [`adr`] into *why* a path was chosen, [`nfr`]
  into *how well* it must behave, and [`api`] into *what it does / how you call it*. Prefer a written PRD
  over an ephemeral chat thread, because the user-story list and the implementation/testing decisions are
  what keep scope and acceptance criteria stable once code starts.
---

This skill takes the current conversation context and codebase understanding and produces a PRD. Do NOT interview the user — just synthesize what you already know.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain vocabulary throughout the PRD, and respect any ADRs in the area you're touching (see the [`adr`] skill).

2. Sketch out the seams at which you're going to test the feature. Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better — the ideal number is one.

   Check with the user that these seams match their expectations.

3. Write the PRD using the template below and save it as a design doc at `design/prd/<feature-slug>.md` (create the `design/prd/` directory if it does not exist). Use a short, descriptive kebab-case slug for the feature.

<prd-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this PRD.

## Further Notes

Any further notes about the feature.

</prd-template>
