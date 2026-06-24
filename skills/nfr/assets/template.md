# {SYSTEM_OR_FEATURE} — Non-Functional Requirements

> The quality attributes {SYSTEM_OR_FEATURE} must satisfy — *how well* it behaves, not *what* it does.
> Each requirement has a stable ID and a testable acceptance criterion. Companion to the other
> design genres:
>
> - **ADRs** (`design/adr`) record *why* each decision was made.
> - **C4** (`web/design/c4` or `design/c4`) models *what* the system is — functional behaviour (states,
>   flows) lives there, not here.
> - **Behaviour/API specs** next to the code document *what it does*, step by step.

---

## 1. Context

<!-- 2-4 sentences: what this system/feature is and the quality goals that matter for it. Keep it
short — this is orientation, not a functional spec. Point at the C4 model for the structure/flows. -->

{One paragraph of context, then a pointer like: "The functional behaviour is modelled in the C4
session/state view — see `design/c4`."}

---

## 2. Security

<!-- One entry per requirement. Shape: ID + one-line MUST + a *Testable:* pass/fail criterion +
*Decided by:* a link to the owning ADR — or `[TARGET]` when that ADR isn't written yet (repoint it once
it lands; no unresolved `[TARGET]` may remain when the doc is done). Use a category prefix and number. -->

- **SEC-1 — {short imperative title}.** {The single constraint, as one "must"/"never" sentence.}
  *Testable:* {an objective check — a threshold, a count, or an observable behaviour that fails when
  violated}.
  *Decided by* [{ADR title}](adr/{yyyymmdd-slug}.md).

---

## 3. Reliability & Availability

- **REL-1 — {title}.** {requirement}
  *Testable:* {criterion}.
  *Decided by* [{ADR title}](adr/{yyyymmdd-slug}.md).

---

## 4. Performance & Efficiency

- **PERF-1 — {title}.** {requirement, e.g. a latency budget at a named percentile, a throughput floor,
  a resource ceiling}
  *Testable:* {e.g. "p99 < 200 ms under N concurrent users in the load test"}.
  *Decided by* [TARGET]. <!-- placeholder until the ADR exists; repoint to adr/{yyyymmdd-slug}.md -->

---

<!-- Add only the categories that actually constrain this system. Common prefixes:
     SEC (security) · REL (reliability/availability) · PERF (performance) · USA (usability) ·
     CAP (capacity/scalability) · CMP (compatibility/portability) · MNT (maintainability) ·
     OBS (observability) · CMPL (compliance). Delete the ones you don't need — a padded list of
     unenforced attributes is worse than a few sharp ones. See references/quality-attributes.md. -->
