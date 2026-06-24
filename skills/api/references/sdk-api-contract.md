# API-contract reference: the Microsoft self-check, the genre boundaries, reframing

Everything beyond the basic shape in `SKILL.md`. The heart of this file is the **self-check** (§2): a
`DO/AVOID` pass you run over the surface *while you write the contract*, anchored in Microsoft's
SDK/library design guidance. Read the section you need.

## Contents

1. [The five pillars — the lens for a contract](#1-the-five-pillars)
2. [The Microsoft DO/AVOID self-check](#2-the-microsoft-doavoid-self-check)
3. [What to document — pillars → sections](#3-what-to-document)
4. [Genre boundaries — api vs c4 vs adr vs nfr vs inline TSDoc](#4-genre-boundaries)
5. [Reframing a behavioural spec's API half](#5-reframing-a-spec)
6. [Sources](#6-sources)

---

## 1. The five pillars

The Azure SDK Design Guidelines organize *every* rule under five principles. They are the right lens
for an API contract because a contract is judged by how it reads to a consumer, not by how it's
implemented. Use them as the questions the finished surface must answer.

| Pillar | The guideline's words | What it asks of *your contract* |
|---|---|---|
| **Idiomatic** | "follow the general design guidelines and conventions for the target language" | Do the signatures look native to the language (TS hooks/types, Rust traits, .NET async)? Don't document a foreign-feeling shape as if it were fine. |
| **Consistent** | "consistent within the language, with the service, and between languages" | Do like operations use like names/shapes across the surface (same verb for the same intent, same options-bag pattern)? Inconsistency is a contract defect. |
| **Approachable** | "sensible defaults, progressive disclosure, easy acquisition" | Can a newcomer call the common case from the inventory + one entry? Are the advanced/escape-hatch exports clearly marked as such? |
| **Diagnosable** | "the developer should be able to understand what is going on … errors should be actionable" | Does every export document *what it throws* and *what comes back*? Are errors named and catchable, not anonymous `Error`s? |
| **Dependable** | "breaking changes are more harmful than most new features are beneficial" | Is the surface minimal and intentional, so you don't have to break it later? Are names + section numbers stable and cited like an ABI? |

---

## 2. The Microsoft DO/AVOID self-check

The .NET Framework Design Guidelines are written as recommendations prefixed `DO / CONSIDER / AVOID /
DO NOT`, and they apply **only to the publicly exposed surface** — which is exactly the contract. Walk
the surface through each group below before calling `api.md` done. A failed check is usually a *contract*
problem you can still fix cheaply, not just a documentation gap.

### Naming
- **DO** name an export so its purpose is obvious from the name alone — clarity over brevity; no
  cryptic abbreviations. A reader should infer intent without opening the entry.
- **DO** use a consistent verb for a consistent intent across the surface (Azure SDK standardizes
  `create`/`get`/`list`/`delete`/`upsert`/`<noun>Exists`). If two exports do the same kind of thing,
  they should *read* the same.
- **DO** suffix option/parameter-bag types predictably (e.g. `…Options`, `…Input`) so consumers
  recognize them on sight.
- **AVOID** names that leak the implementation ("…ViaWebSocket", "RawTransportClient"). The name is part
  of the abstraction.

### Surface & types
- **DO** keep the public surface **minimal and intentional** — export only what consumers need. The
  inventory table is the test: if it sprawls, the surface is too big to keep stable (**Dependable**).
- **DO** state the **re-export boundary** explicitly: what the module root surfaces vs. what is an
  internal building block. Types that appear in signatures but aren't re-exported go in the
  "referenced, not re-exported" section — documented as internal, not paraded as public.
- **DO NOT** leak transport/implementation types into the public surface (Azure SDK: *don't leak the
  underlying protocol transport implementation details to the consumer*).
- **CONSIDER** whether each public type is one a consumer constructs/consumes, or an internal that
  escaped — demote the latter.

### Members & parameters
- **DO** document, per export, every parameter (type, required, meaning) and the **return value**.
- **DO** lead the return with the **logical entity** the caller wants in the 99% case; mention the
  full/raw response as the secondary path, if any (Azure SDK: *optimize for returning the logical
  entity*, but *allow access to the complete response*).
- **DO** document **preconditions** as part of the call contract (required status/state, ordering,
  what must be true before the call) — preconditions are how the caller avoids the caller-bug errors.
- **CONSIDER** an options bag over a long positional parameter list for approachability/extensibility.

### Errors
- **DO** treat the error model as part of the contract. For each export, list what it can throw.
- **DO** split errors into **recoverable** (the caller may catch and surface to a user) vs.
  **precondition / caller-bug** (an internal-error class the caller must *prevent* by gating, not
  catch). This split is the single most useful thing a contract can state about failure.
- **DO** make errors **distinct and catchable** (named/branded classes or codes), so a caller can
  react to *which* failure occurred (Azure SDK: *throw a distinct error* for distinct conditions;
  **Diagnosable**).
- **AVOID** documenting "throws Error" — an anonymous throw tells the caller nothing actionable.

### Versioning & dependability
- **DO** treat export names and the numbered sections as a stable ABI — other docs, code, and tests
  cite them. **Add** and **supersede**; never silently rename or renumber.
- **CONSIDER** marking advanced/escape-hatch exports as such, so the stable-core vs. may-change
  distinction is visible.
- **DO NOT** let the contract drift from the code: if the module root's exports change, the inventory
  changes in the same edit.

---

## 3. What to document

A recipe mapping the pillars onto the five sections of `api.md`, so "be approachable/dependable/…"
becomes concrete authoring steps:

| `api.md` section | Serves pillar | The check |
|---|---|---|
| **Header + re-export boundary** | Dependable | The contract's edge is explicit: public vs. internal is unambiguous. |
| **Export inventory** | Approachable, Dependable | Whole surface at a glance; minimal and grouped so the common case is findable. |
| **Per-export contract** | Idiomatic, Consistent, Approachable | Signature reads native; like things look alike; common-case return leads. |
| **Supporting types (not re-exported)** | Dependable | Internals named as internals; no transport leak into the public surface. |
| **Error catalog** | Diagnosable | Distinct, named errors; recoverable vs. caller-bug split. |

---

## 4. Genre boundaries

Four design genres, one `design/` family, plus inline docs in the code. Keep each in its lane and
cross-link:

| Genre | Question | Lives in | Belongs to `api` when… |
|---|---|---|---|
| **API contract** (this skill) | *what does it do / how do I call it?* | `design/api.md` | — |
| **C4** ([`c4`]) | *what is it?* (structure) + step-by-step flows | `design/c4` | the contract refers to a flow — link the dynamic view, don't retell it |
| **ADR** ([`adr`]) | *why?* (decisions/tradeoffs) | `design/adr` | a surface choice was a real tradeoff — link the ADR, don't re-argue it |
| **NFR** ([`nfr`]) | *how well?* (quality attributes) | `design/nfr.md` | an error/limit enforces an NFR — cite the NFR ID, don't restate the bar |
| **Inline TSDoc/JSDoc** | *what is this one symbol?* | doc comments in the code | per-symbol detail; `api.md` is the whole-surface contract — complementary, not a substitute |

The smell to avoid: one document that mixes "the user clicks enable, then funds gas, then trades"
(flow → C4), "we chose in-memory storage because…" (rationale → ADR), "the secret is never persisted"
(quality bar → NFR), and "`useEnableOneClickSession(options?) → UseMutationResult<…>`, throws
`AMOUNT_NOT_POSITIVE`" (surface → **api**). Four genres, four homes, linked.

---

## 5. Reframing a spec

A common, high-value case: a `*_SPEC.md` / `*_CONTRACT.md` is half behaviour and half public surface.
Split it without losing anything:

1. **Sort every section** into *surface* (exports, signatures, params, returns, errors, preconditions,
   the re-export boundary) vs. *flow* (states, step-by-step behaviour) vs. *rationale/quality*.
2. **Extract the surface half into `design/api.md`** with the inventory + per-export + error-catalog
   shape. Lead returns with the logical entity; split the errors recoverable-vs-caller-bug.
3. **Send the rest to its genre.** Flows → confirm the [`c4`] dynamic view already covers them before
   dropping the prose; rationale → an [`adr`]; quality bars → an [`nfr`] ID.
4. **Repoint every reference.** Citations to the old filename/anchors (`OLD_CONTRACT.md §7`) in ADRs,
   NFRs, code comments, and tests must now point at `design/api.md` and its section — **preserve the
   section numbers** during the move so existing `§`-anchors stay valid, then grep for the old name and
   confirm **zero dangling references**.

---

## 6. Sources

- **Azure SDK Design Guidelines** — General Design Principles and Introduction (the five pillars,
  client/surface, naming, return shape, error, transport-leak rules):
  <https://azure.github.io/azure-sdk/general_design.html>,
  <https://azure.github.io/azure-sdk/general_introduction.html>.
- **.NET Framework Design Guidelines** (Cwalina & Abrams) — the `DO/CONSIDER/AVOID/DO NOT` convention,
  "conventions apply to the publicly exposed surface", and the Naming / Type / Member / Extensibility /
  Exceptions / Usage sections: <https://learn.microsoft.com/dotnet/standard/design-guidelines/>.
