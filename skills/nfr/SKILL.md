---
name: nfr
disable-model-invocation: true
description: >-
  Capture a system's non-functional requirements (NFRs) — the measurable quality attributes it must
  satisfy: security, reliability/availability, performance, usability, scalability, compatibility,
  maintainability, compliance — as a stable-ID'd `design/nfr.md` kept next to the code. Use this
  whenever the user wants to write/record non-functional requirements or quality attributes, set a
  "quality bar", define SLAs/SLOs, answer "how fast / secure / reliable / available must this be",
  pin acceptance criteria for performance or security, or turn a pile of "must" rules, invariants, and
  constraints into testable requirements — and proactively when a doc labelled a "spec" is really
  non-functional constraints in disguise (latency budgets, secret-handling rules, fault tolerance,
  rate limits, funding floors). This is the fourth companion in the system-design family: the [`c4`]
  skill is *what* the system is, [`adr`] is *why* it became that way, behaviour/API specs are *what it
  does*, and NFR is *how well* it must do it. Prefer a stable-ID'd NFR doc over burying quality goals in
  prose, because IDs let ADRs, specs, code, and tests cite each requirement durably — and because an
  NFR you can't write a pass/fail check for is an aspiration, not a requirement.
---

# Non-Functional Requirements (NFRs) as quality attributes

## Why this approach

A **functional** requirement says *what* the system does ("the user can place an order"). A
**non-functional** requirement says *how well* it must do it ("an order is acknowledged within 200 ms
at the 99th percentile", "the session secret is never persisted"). NFRs are the **quality attributes** —
security, performance, reliability, and the rest — that decide whether a correct-on-paper system is
actually fit for use.

The whole value of writing them down is **measurability**. A requirement you can hand to a test, a
monitor, or a reviewer as a pass/fail check is real; "must be fast", "must be secure", "must be
user-friendly" are wishes. So every NFR here is one short *must* plus a **testable acceptance
criterion** — a number, a threshold, or an observable behaviour someone can verify.

Give each requirement a **stable ID** (`SEC-1`, `REL-2`, `PERF-3`). IDs are the point: they let an ADR
say "decided REL-2", a contract say "throws when CAP-1 is violated", a code comment cite the rule it
upholds, and a test name the requirement it guards. IDs are append-only and durable — you supersede a
requirement, you don't renumber the list out from under everyone who cites it.

NFRs are the *how well*; the other system-design genres are siblings under one `design/` folder, and you
**cross-link** rather than duplicate:

- [`c4`] model (`design/c4`) — *what* the system is (structure). When an NFR refers to a flow or
  component, point at C4; don't redraw it here.
- [`adr`] log (`design/adr`) — *why* a quality bar was set where it is. Most NFRs are *decided by* an
  ADR; link each requirement to the ADR that justifies it.
- behaviour/API specs next to the code — *what it does*, step by step. Keep functional behaviour there,
  not here.

## When to reach for an NFR doc

Write or extend `design/nfr.md` when the conversation is about **how well**, not **what**:

- a quality bar or budget: latency/throughput targets, uptime/availability, error budgets, SLAs/SLOs;
- a security or privacy constraint: what must never be persisted/transmitted, authz scope, key handling;
- a reliability/robustness rule: fault tolerance, idempotency, "funds/data never stranded", recovery;
- a capacity/scaling limit: max load, storage growth, rate limits, funding floors;
- compatibility, portability, accessibility, observability, or compliance obligations.

A strong trigger that's easy to miss: **you're reading a "spec" that is mostly `must`/`never`/invariant
rules and constraints** — those are NFRs wearing a spec's clothes. Lift them into `design/nfr.md` with
IDs and criteria (see *Reframing an existing spec* below).

Don't write an NFR for something with no measurable bar and no real constraint — that's noise. A good
prompt: *"could I write a test or a monitor that fails when this is violated?"* If not, either sharpen
it until you can, or it isn't an NFR.

## The workflow

Keep NFRs in a single `design/nfr.md` next to the [`c4`] and [`adr`] folders. It's plain markdown —
git is its history, so you usually don't version individual files (see *Versioning* in the reference if
you want ADR-style immutable snapshots).

1. **Place the doc.** `design/nfr.md` at the same level as `design/c4` and `design/adr` (in a monorepo,
   next to the package it constrains). Start from `assets/template.md` — it carries the genre-framing
   header and a worked category so you're not staring at a blank file.

2. **Pick the categories that actually constrain this system.** Use the catalog in
   `references/quality-attributes.md` (Security, Reliability/Availability, Performance, Usability,
   Capacity/Scalability, Compatibility, Maintainability, Compliance, Observability). Include only the
   ones with a real bar — an exhaustive ISO checklist nobody enforces is worse than five sharp
   requirements.

3. **Write each requirement as ID + must + criterion + source.** One requirement per ID so a test maps
   to exactly one rule:
   ```markdown
   - **SEC-1 — Secret stays in memory only.** The password/key is never persisted or transmitted; only
     non-secret config may be stored.
     *Testable:* a dump of persisted state contains no secret; a reload forces re-entry.
     *Decided by* [Keep the session secret in memory only](adr/2026…-keep-secret.md).
   ```
   Give IDs a category prefix (`SEC`, `REL`, `PERF`, `USA`, `CAP`, `CMP`, `MNT`, `OBS`, `CMPL`) and
   number within it. Make the criterion **objective** — a threshold, a count, an observable pass/fail.

4. **Cross-link, don't duplicate.** Link each NFR to the ADR that decided it. Where a requirement leans
   on a flow or component, point at the [`c4`] view instead of describing the behaviour. If a quality
   bar represents a real tradeoff that was weighed, make sure the [`adr`] exists — an unmoored NFR with
   no decision behind it is a smell.

5. **Keep IDs stable.** When a requirement changes, edit its text/criterion in place if it's a
   clarification; if it's a genuine reversal, mark it superseded and add a new ID rather than silently
   re-pointing every citation. Never recycle a retired ID for a different rule.

## Reframing an existing "spec" into NFRs

A common and high-value case: a document called `*_SPEC.md` is really half functional behaviour and half
non-functional constraints. Split it cleanly:

1. **Sort the content.** Functional (states, flows, step-by-step behaviour) vs. non-functional (`must`
   rules, invariants, limits, security/reliability properties, non-goals).
2. **Extract the non-functional half into `design/nfr.md`** with IDs and testable criteria.
3. **Send the functional half to where it belongs** — usually the [`c4`] model already covers the state
   machine and flows, so the functional prose can be dropped; anything C4 doesn't cover stays in a
   behaviour spec next to the code. Confirm coverage *before* deleting, so nothing is silently lost.
4. **Repoint every reference.** Citations like `SPEC.md §8.2` in ADRs, contracts, and code comments must
   now point at the NFR ID (for the constraint) or the C4 view (for the flow). Grep for the old anchors
   afterwards — a successful reframe leaves **zero dangling references**.

## Critical gotchas

Each of these is what separates a useful NFR doc from decorative prose:

- **Untestable adjectives are not requirements.** "Fast", "secure", "scalable", "intuitive" pin nothing.
  Every entry needs a number, a threshold, or an observable pass/fail. If you can't write the check,
  you haven't written the requirement yet.
- **Don't smuggle functional behaviour in.** State machines, flows, and "the user clicks X then Y"
  belong in the [`c4`] model or a behaviour spec. NFRs constrain *how well* those behave; they don't
  re-describe them. Mixing the two makes both rot.
- **IDs are durable and append-only.** Other artifacts cite `REL-2` by name; renumbering or reusing IDs
  silently breaks those citations. Supersede, don't reshuffle.
- **One requirement per ID.** If an entry has two independently-testable claims, it should be two IDs —
  otherwise a test can't say which half failed.
- **Scope to what's real.** Only the quality attributes that actually bind *this* system. A padded list
  of generic ISO attributes nobody measures dilutes the ones that matter and erodes trust in the doc.
- **An NFR with no owning ADR is a smell.** A quality bar is usually a tradeoff someone chose
  (latency vs. cost, security vs. convenience). If the tradeoff was real, the [`adr`] should exist and
  the NFR should link to it; if there was genuinely no alternative, say so briefly.

## Forward references: the `[TARGET]` placeholder

When an NFR must point at something that **doesn't exist yet** — most often the deciding ADR — write
`[TARGET]` in place of the real link, never a fabricated path and never a silently-dropped citation. An
NFR whose ADR you'll write in a later pass reads `*Decided by* [TARGET]`, repointed to
`adr/yyyymmdd-slug.md` once that ADR lands (same for a [`c4`] view you cite before it's modelled).

`[TARGET]` is a deliberate, greppable debt marker: it records that the link is *owed*, shows up loudly in
review, and is **repointed** the moment the target exists. The doc is not done while an unresolved
`[TARGET]` remains — `grep -rn "\[TARGET\]" design/` is the check. The only legitimate use is a
*consciously deferred* forward reference (the target is planned for a later step); even then it stays
visible as `[TARGET]`, so nothing reads as resolved when it isn't. (This is the placeholder for a
not-yet-created target — distinct from a *dangling* link to something that should already exist.)

## Reference & assets

- `references/quality-attributes.md` — the full catalog of NFR categories with definitions and **example
  measurable criteria** for each, a recipe for turning vague goals into testable requirements, the
  detailed reframe-from-spec procedure, the genre-boundary table (NFR vs ADR vs C4 vs spec), and
  optional versioning approaches. Read it before writing a non-trivial NFR doc.
- `assets/template.md` — the `design/nfr.md` starter: genre-framing header, a Context section, and a
  worked category showing the ID + must + criterion + ADR-link shape. Adapt it; don't start blank.

## Definition of done

`design/nfr.md` sits next to the [`c4`] and [`adr`] folders; every requirement has a stable ID, a
one-line *must*, and an **objective pass/fail acceptance criterion**; each links to the ADR that decided
it; functional behaviour is *not* duplicated here (it lives in C4 / the behaviour spec); and any
citations elsewhere — ADRs, contracts, code comments, tests — reference the NFR IDs with **no dangling
anchors**. Every forward reference to a not-yet-written ADR/C4 view is a visible `[TARGET]`, and **no
unresolved `[TARGET]` remains** when the doc is called done.
