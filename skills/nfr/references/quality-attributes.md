# NFR reference: quality attributes, measurability, and genre boundaries

Everything beyond the basic shape in `SKILL.md`. Read the section you need.

## Contents

1. [The category catalog](#1-the-category-catalog)
2. [Making a requirement measurable](#2-making-a-requirement-measurable)
3. [The ID scheme](#3-the-id-scheme)
4. [Reframing an existing spec into NFRs](#4-reframing-an-existing-spec-into-nfrs)
5. [Genre boundaries — NFR vs ADR vs C4 vs spec](#5-genre-boundaries)
6. [Versioning (optional)](#6-versioning-optional)

---

## 1. The category catalog

Quality attributes, drawn from the common NFR taxonomy (ISO/IEC 25010 and the usual industry lists).
Use the prefix as the ID stem. Pick the categories that genuinely constrain the system; skip the rest.

| Prefix | Category | What it constrains | Example measurable criteria |
|---|---|---|---|
| `SEC` | **Security** | confidentiality, integrity, authz scope, secret/key handling | "secret is never persisted or transmitted"; "delegate authority is trade-only and cannot move funds"; "all PII at rest is encrypted with AES-256" |
| `REL` | **Reliability / Availability** | fault tolerance, recovery, idempotency, uptime | "99.9% monthly availability"; "teardown is idempotent and never strands funds"; "a failed write is retried and never corrupts state" |
| `PERF` | **Performance / Efficiency** | latency, throughput, resource use | "p99 order-ack < 200 ms under 500 concurrent users"; "cold start < 2 s"; "steady-state memory < 512 MB" |
| `USA` | **Usability / Accessibility** | discoverability, effort, error prevention, a11y | "the feature surfaces without hunting through settings"; "the prompt never appears over a still-loading screen"; "meets WCAG 2.1 AA" |
| `CAP` | **Capacity / Scalability** | load ceilings, growth, rate limits, quotas | "handles 10k msgs/s before backpressure"; "every funding action leaves balance ≥ the floor"; "scales linearly to 50 nodes" |
| `CMP` | **Compatibility / Portability** | platforms, protocols, formats, interop | "fund/refund txs are EIP-1559 type-2 and satisfy the chain's mandatory priority fee"; "runs on the last two major browser versions" |
| `MNT` | **Maintainability / Testability** | modularity, coupling, analyzability | "session core is a pure reducer with no IO/React, unit-testable without mounting"; "no module exceeds N cyclomatic complexity" |
| `OBS` | **Observability** | logging, metrics, tracing, alerting | "every state transition emits a structured event"; "p99 latency is exported and alerts above budget" |
| `CMPL` | **Compliance / Legal** | regulatory, contractual, data-residency | "patient data handling is HIPAA-compliant"; "EU user data stays in EU regions" |

This list is a menu, not a checklist to complete. Five enforced requirements beat thirty aspirational
ones.

---

## 2. Making a requirement measurable

The defining test of an NFR: **could a test, a monitor, or a reviewer produce a pass/fail verdict?**
Turn vague goals into checkable ones by pinning the missing dimension:

| Vague goal | Sharpened NFR (testable) |
|---|---|
| "must be fast" | "p99 response < 200 ms at 500 RPS in the load test" |
| "must be secure" | "the session secret never appears in persisted state or logs (verified by a state/log dump)" |
| "must be reliable" | "a forced refund-tx failure leaves the session active and authority intact; no funds stranded" |
| "must scale" | "throughput stays linear to 10k msgs/s; beyond that, requests are shed with 429, not dropped" |
| "must be user-friendly" | "the enable prompt is withheld until the page is ready and is suppressed after one dismissal per session" |

A criterion is good when it names **what** is measured, the **threshold/condition**, and (for
performance/capacity) the **operating point** (percentile, load, environment). If you can't yet name a
number, write the most concrete observable behaviour you can — "leaves status `active` on failure" is
testable even without a metric.

---

## 3. The ID scheme

- Format: `PREFIX-N` — category stem + integer, numbered within the category (`SEC-1`, `SEC-2`, `REL-1`).
- **One requirement per ID.** If an entry bundles two independently-checkable claims, split it, so a
  failing test maps to exactly one ID.
- **Append-only and durable.** ADRs, contracts, code comments, and tests cite IDs by name. Never
  renumber and never recycle a retired ID for a different rule — both silently break citations.
- **Superseding.** To reverse a requirement, mark the old one (e.g. `~~REL-2 (superseded by REL-7)~~`)
  and add a new ID. Clarifying the wording or tightening a threshold can be an in-place edit.

---

## 4. Reframing an existing spec into NFRs

When a `*_SPEC.md` is really constraints in disguise, split it without losing anything:

1. **Sort every section** into *functional* (states, flows, step-by-step behaviour, surfacing) vs.
   *non-functional* (`must`/`never` rules, invariants, limits, security/reliability/perf properties,
   non-goals).
2. **Confirm the functional half is covered elsewhere before deleting it.** Usually the [`c4`] model's
   state/dynamic views already capture the state machine and flows; diff the spec's functional sections
   against the model. Anything C4 doesn't cover stays in a behaviour spec next to the code — don't drop
   it silently.
3. **Extract the non-functional half into `design/nfr.md`**, one ID per constraint, each with a testable
   criterion and a link to the deciding ADR.
4. **Repoint every reference.** Old anchors (`SPEC.md §8.2`) in ADRs, contracts, and code comments must
   now cite the NFR ID (for a constraint) or the C4 view (for a flow). Map them explicitly:
   - invariants / rules / limits / non-goals → the NFR ID;
   - states / flows / surfacing → the C4 view.
5. **Verify zero dangling references.** Grep for the old filename and the old `§`-anchors; a clean
   reframe leaves none. Run the project's typecheck/lint if the edits touched code comments.

---

## 5. Genre boundaries

Four genres, one `design/` family. Keep each in its lane and cross-link:

| Genre | Question | Lives in | Cite from NFR when… |
|---|---|---|---|
| **NFR** (this skill) | *how well?* (quality attributes) | `design/nfr.md` | — |
| **ADR** ([`adr`]) | *why?* (decisions/tradeoffs) | `design/adr` | every NFR links to the ADR that set its bar |
| **C4** ([`c4`]) | *what is it?* (structure) | `design/c4` | an NFR refers to a flow/component — point, don't redraw |
| **Spec / contract** | *what does it do?* (behaviour/API) | next to the code | an NFR constrains a documented behaviour |

The smell to avoid: a single document that mixes "the user clicks enable, then funds gas, then trades"
(functional → C4/spec) with "the secret is never persisted" (non-functional → NFR) with "we chose
in-memory storage because…" (rationale → ADR). Three genres, three homes, linked.

---

## 6. Versioning (optional)

`design/nfr.md` is plain markdown and **git is its history** — the default is a single living file, no
per-file versioning. Two alternatives if a project wants more:

- **ADR-style immutable snapshots.** If NFRs must be frozen at points in time (audits, releases), keep
  dated snapshots (`nfr/YYYYMMDD-nfr.md`) and supersede rather than edit — borrowing the [`adr`]
  immutability model. Costs whole-doc copies; only worth it when a frozen record is a real requirement.
- **Per-release NFR sets.** Tag requirements with the release/version they apply from, when the bar
  changes across versions and old bars still matter.

For most projects the single living `design/nfr.md` plus stable IDs is enough — the IDs give durable
citation, and git gives the timeline.
