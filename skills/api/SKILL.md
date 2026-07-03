---
name: api
description: >-
  Document a module / SDK / library's public API as a stable, citable `design/api.md` **contract** —
  the exported surface and how you call it: an export inventory plus, per export, its signature,
  parameters, return value, preconditions, and error model. Use this whenever the user wants to
  write/record an API contract, document a package's public interface or exported surface, answer
  "what does this module export and how do I call it", produce an API reference for an SDK/library,
  pin a public surface so consumers, ADRs, NFRs, and tests can cite it by name, or reframe the API
  half of a behavioural `*_SPEC.md`/`*_CONTRACT.md` into its own doc — and proactively when you are
  about to bless a package's public exports as stable. This is the fourth companion in the
  system-design family: [`c4`] is *what the system is* (structure) and its step-by-step flows, [`adr`]
  is *why* it became that way, [`nfr`] is *how well* it must behave, and **`api` is *what it does /
  how you call it*** — the public contract. The notion of a "good" surface is anchored in Microsoft's
  SDK/library design guidance (Azure SDK Design Guidelines + the .NET Framework Design Guidelines),
  applied as a self-check while you write. Prefer one stable contract doc over scattering the surface
  across JSDoc and README prose, because consumers cite an API surface by name the way they cite an
  ABI — and a surface nobody pinned is a surface that breaks silently.
---

# Public API contract (what it does / how you call it)

## Why this approach

A **C4** model says *what the system is*; an **ADR** says *why*; an **NFR** says *how well*. The piece
left over — *what does this module actually expose, and how do I call it?* — is the **public API
contract**. It is the genre every sibling skill names but none of them owns: the exported names of a
module/SDK/library, their signatures, semantics, preconditions, and error model, written down in one
place a consumer can read top-to-bottom.

The whole value is that **the public surface *is* the contract.** Microsoft's .NET Framework Design
Guidelines make this concrete: the naming/type/member conventions apply *only to publicly exposed
types and members* — the surface is the thing under contract; everything behind it is free to change.
The Azure SDK guidelines add the consequence: *"breaking changes are more harmful to a user's
experience than most new features are beneficial"* (the **Dependable** pillar). So you pin the surface
in a doc that consumers, ADRs, NFRs, and tests **cite by name** — like an ABI — and you change it
deliberately, not by accident.

Why a dedicated doc rather than JSDoc/README prose:

- **JSDoc is per-symbol and scattered** — it never shows the *whole* surface at a glance, or what is
  deliberately *internal*. (It complements this doc; see the gotcha — `api.md` is the design-layer
  whole-surface contract, inline TSDoc documents symbols in code. Keep both; don't fold one into the
  other.)
- **READMEs drift** and mix tutorials with reference.
- **The contract doc states the surface once**: the inventory, each export's call contract, the types
  that are *referenced but not re-exported* (surface minimalism), and the error catalog. That single
  view is what makes review, citation, and "did this change break the surface?" possible.

## When to reach for an API contract doc

Write or extend `design/api.md` when the subject is **the public surface and how to call it**:

- documenting what a package/module *exports* — its providers, hooks, functions, types, constants;
- you need a stable reference that consumers, ADRs, NFRs, and tests can cite by name;
- you're about to declare a surface "public/stable" and want the contract on record before people
  depend on it;
- a behavioural `*_SPEC.md`/`*_CONTRACT.md` is half flow and half API — lift the API half here (see
  the reference's reframing recipe), leaving flows to [`c4`].

Don't write one for internal-only code with no consumers, or to re-describe *flows* (those are [`c4`]
dynamic views) — that's noise. A good prompt: *"would a consumer of this package cite this to know how
to call it?"* If not, it isn't an API contract.

## What goes in `design/api.md`

Start from `assets/template.md` — it carries the genre-framing header and the section shape so you're
not staring at a blank file. The proven structure (numbered, because other docs cite the sections):

1. **Header** — genre framing + cross-links to [`c4`]/[`adr`]/[`nfr`], and a one-line statement of
   **what the module root re-exports vs. what is internal**. The re-export boundary is the contract's
   edge.
2. **Export inventory** — the entire surface at a glance, grouped by category. This is the
   minimal-intentional-surface check made visible: if the table is sprawling, the surface probably is.
3. **Per-export contract** — for each export: **signature · parameters (a table) · returns (the
   *logical entity* the caller wants) · errors · preconditions · notes**. This is the bulk of the doc.
4. **Supporting types** — types that appear in the signatures but are **referenced, not re-exported**.
   Naming them (and saying they're internal) is itself part of the contract.
5. **Error catalog** — the error model as a first-class table, split into **recoverable** (a caller may
   catch and surface) vs **caller-bug / precondition** (an internal-error class the caller should
   prevent by gating, not catch). The error model is part of the contract, not an afterthought.

## The workflow

Keep the doc in `design/api.md` next to the [`c4`], [`adr`], and [`nfr`] siblings (in a monorepo, in
the constrained package's own `design/`, beside its `nfr.md` and `adr/`).

1. **Place & seed.** Copy `assets/template.md` → `design/api.md`. Wire the header's cross-links to the
   sibling genres that exist.
2. **Inventory the *real* surface first.** Read the module root (`index.ts` / the package entry) and
   document **only what is actually exported**. The contract describes the surface as shipped, not as
   imagined — if the code and the doc disagree, the code is the truth (or the export is a bug).
3. **Write each export's call contract.** Signature, a parameter table (type, required, meaning),
   what it **returns** (lead with the logical entity the caller wants 99% of the time), its
   **preconditions**, and the **errors** it can raise. Keep behaviour *flows* out — link to the [`c4`]
   dynamic view instead of retelling the steps.
4. **Run the Microsoft self-check.** Before calling the doc done, walk the surface through the
   `DO/AVOID` checklist in `references/sdk-api-contract.md` — naming, surface minimalism, return shape,
   the error model, and dependability/versioning. The self-check often surfaces a contract problem
   (an inconsistent verb, a leaked internal type, an undocumented throw) *while you still control the
   surface*. Where the check exposes a genuine design flaw, note it — fixing the surface beats
   documenting a bad one.
5. **Cross-link, don't duplicate.** Point at [`c4`] for flows, [`adr`] for the *why*, [`nfr`] for the
   *how well*. The contract states *what you call and what you get back* — nothing else.
6. **Keep the surface (and the section numbers) stable.** Other artifacts cite `api.md §7` and export
   names by name. Treat both like an ABI: add and supersede, don't silently renumber or rename.

## Critical gotchas

Each of these is what separates a useful contract from decorative prose:

- **Document the surface, not the internals.** Per Azure SDK, *don't leak transport/implementation
  details to the consumer.* If a type only appears because it's an internal building block, it belongs
  in the "referenced, not re-exported" section — or nowhere — not in the public inventory.
- **The error model is part of the contract.** Split **recoverable** errors (the caller catches and
  surfaces them) from **precondition / caller-bug** errors (the caller must *prevent* by gating, and an
  internal-error class signals the bug). A doc that lists "throws Error" has documented nothing.
- **The contract is stable like an ABI.** Export names and the numbered sections are cited elsewhere.
  Renaming an export or renumbering a section silently breaks those citations — supersede and add,
  never reshuffle. This is the **Dependable** pillar made operational.
- **Don't duplicate the other genres.** Flows/states → [`c4`] dynamic views; rationale → [`adr`];
  quality bars/limits → [`nfr`]. A contract that re-tells the enable-flow steps, or re-argues why the
  secret stays in memory, will rot out of sync with the genre that owns it. Link across instead.
- **`api.md` is *not* inline TSDoc.** TSDoc/JSDoc documents a symbol *in the code*, per-symbol;
  `api.md` is the *whole-surface* contract at the design layer, cross-linked to c4/adr/nfr. They
  complement each other — write both where both exist; don't delete one because the other exists.
- **Scope to what's real and public.** A padded inventory of internals erodes trust the same way a
  padded NFR list does. The contract is exactly the surface a consumer depends on — no more.

## Forward references: the `[TARGET]` placeholder

When the contract must point at something that **doesn't exist yet** — a header cross-link to a sibling
genre (`design/nfr.md`, a [`c4`] view, the owning [`adr`]) not yet written, or a per-export "see …"
reference — write `[TARGET]` in place of the real link, never a fabricated path and never a dropped
citation. A pending cross-link reads `[TARGET]`, repointed once the sibling exists.

`[TARGET]` is a deliberate, greppable debt marker: it records that the link is *owed*, shows up loudly in
review, and is **repointed** the moment the target exists. The contract isn't done while an unresolved
`[TARGET]` remains — `grep -rn "\[TARGET\]" design/` is the check. The only legitimate use is a
*consciously deferred* forward reference (the target is planned for a later step); even then it stays
visible as `[TARGET]` — distinct from a *dangling* anchor to something that should already exist.

## Reference & assets

- `references/sdk-api-contract.md` — the Microsoft-anchored detail: the **Azure SDK five pillars**
  (Idiomatic · Consistent · Approachable · Diagnosable · Dependable) as a lens for a contract; the
  **.NET `DO/CONSIDER/AVOID/DO NOT`** self-check grouped by naming / surface & types / members &
  parameters / errors / versioning; the "what to document" recipe mapping each pillar to a section of
  `api.md`; the genre-boundary table (api vs c4 vs adr vs nfr vs inline TSDoc); the reframe-from-spec
  procedure; and source links. Read it before writing a non-trivial contract, and run the self-check
  against the finished surface.
- `assets/template.md` — the `design/api.md` starter: genre-framing header, export-inventory table, a
  worked per-export entry showing the signature + params + returns + errors + preconditions shape, the
  referenced-not-re-exported section, and the error catalog. Adapt it; don't start blank.

## Definition of done

`design/api.md` sits beside the [`c4`], [`adr`], and [`nfr`] siblings; its header states the re-export
boundary and links the other genres; the **export inventory matches what the module root actually
exports** (no internals smuggled in, nothing public omitted); every export has a **signature, a
parameter table, a documented return, its preconditions, and its errors**; the **error catalog splits
recoverable from caller-bug**; the surface passes the Microsoft `DO/AVOID` self-check (or the gaps are
noted as follow-ups); flows/rationale/quality-bars are **linked, not duplicated**; and any citations
elsewhere — ADRs, NFRs, code, tests — reference the export names and section numbers with **no dangling
anchors**. Any cross-link to a not-yet-written sibling genre is a visible `[TARGET]`, and **no unresolved
`[TARGET]` remains** when the contract is called done.
