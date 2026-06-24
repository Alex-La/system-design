---
name: adr
disable-model-invocation: true
description: >-
  Record architecturally significant decisions as Architecture Decision Records (ADRs) in MADR format,
  managed with log4brains (a browsable, searchable decision log + monorepo support). Use this whenever
  the user wants to write/record/capture an architecture or design decision, start or maintain a
  decision log / ADR log, asks "should this be an ADR?", "why did we choose X over Y", "document why we
  did this", "set up ADRs", or mentions MADR or log4brains — and proactively when the user is making a
  hard-to-reverse or cross-cutting choice (a library, a boundary, a protocol, a data model, a security
  tradeoff) that future maintainers will wonder about. This is the companion to the `c4` skill: C4
  captures *what* the system is (structure); ADRs capture *why* it became that way (decisions). Prefer a
  real ADR log over scattering rationale in commit messages, wikis, or code comments, because those
  drift and can't be browsed as an immutable, ordered history.
---

# Architecture Decision Records (ADRs) with MADR + log4brains

## Why this approach

An **ADR** records one architecturally significant decision: the context, the options considered, the
choice, and its consequences. The log is **immutable** — you never rewrite a past decision; you
*supersede* it with a new one. That way the decision log reads like project history in order, and a new
teammate can see not just what the architecture is but why it got that way, and avoid blindly reversing
a choice whose tradeoffs were already weighed.

**MADR** (Markdown Any Decision Records) is the format — a small, well-known markdown template with
Context / Considered Options / Decision Outcome / Consequences. **log4brains** is the tooling: a CLI
that scaffolds ADRs from the template and a static-site generator that turns the markdown into a
browsable, searchable knowledge base, with **first-class monorepo support** (a global log plus
per-package logs).

ADRs are the *why*; the [`c4`] skill is the *what*. Keep them as siblings under a `design/` folder
(`design/c4` for the model, `design/adr` for the decision log) and cross-link them. Two more genres round out
the family: **non-functional requirements** (the [`nfr`] skill — *how well* the system must behave) and
behaviour/API specs (*what it does*, next to the code). Link out to those; don't fold them into ADRs.

## When something deserves an ADR

Write one when a decision is **architecturally significant** — it shapes structure or is costly to
reverse:

- choosing a library/framework/protocol/datastore, or deliberately *not* choosing one;
- a module boundary, dependency direction, or public interface;
- a cross-cutting rule (error model, auth model, persistence/identity scheme, gas/fee strategy);
- a security or correctness tradeoff where you weighed alternatives.

Don't write one for routine implementation detail, formatting, or anything with no real alternative —
that's noise in the log. A good prompt: *"if someone tried to undo this in a year, would they need to
know why we did it?"* If yes, it's an ADR.

## The workflow

Run all commands from the project root that holds `.log4brains.yml` (in a monorepo, that's usually the
workspace root, not the package).

1. **Install log4brains as a dev dependency**, not globally — so the toolchain is pinned and the same
   for everyone and in CI. Add scripts so the commands are discoverable:
   ```jsonc
   // package.json
   "devDependencies": { "log4brains": "^1.1.0" },
   "scripts": {
     "adr:new":     "log4brains adr new",
     "adr:preview": "log4brains preview",
     "adr:build":   "log4brains build"
   }
   ```

2. **Create `.log4brains.yml`.** Copy `assets/log4brains.yml` and edit it. Minimum is `project.name`,
   `project.tz`, and `project.adrFolder`. For a monorepo, add a `project.packages` entry per package
   (see the Monorepo section). Full field reference: **`references/log4brains-and-madr.md`**.

3. **Scaffold each ADR folder.** Every `adrFolder` must exist and contain a `template.md`, or
   `log4brains adr new` errors out. Copy the bundled starters:
   - `assets/template.md` → `<adrFolder>/template.md` (the MADR template log4brains fills in)
   - `assets/index.md` → `<adrFolder>/index.md` (the knowledge-base homepage; edit the project name)
   - write a first **meta-ADR** recording the adoption of ADRs themselves (good convention; gives the
     log a non-empty start and documents the process).

4. **Write ADRs.** Prefer `pnpm adr:new "Short imperative title"` (add `-q` to skip the prompt, and
   `--package <name>` in a monorepo) — it stamps the right filename and copies the template. Then fill
   the sections (see below). You can also just copy `template.md` to `YYYYMMDD-slug.md` and edit; both
   are equivalent. Set `Status: accepted` for a decision already in effect.

5. **View it.** `pnpm adr:preview` opens a live, searchable site (hot-reloads on edits) — this is the
   primary local workflow. `pnpm adr:build` produces a static site for CI/publishing. `pnpm exec
   log4brains adr list` prints every ADR with its status and package (a fast sanity check).

## What goes in an ADR (MADR sections)

The template carries these; keep titles as a **decision phrased as an action** ("Use a pure reducer
core", "Scope identity to chain and owner"):

- **Status** — `proposed` → `accepted`; later `deprecated` or `superseded by […]`. Never delete.
- **Context and Problem Statement** — the forces and the question, in 2-3 sentences.
- **Considered Options** — the real alternatives, *including the one you rejected*. An ADR with one
  option isn't a decision.
- **Decision Outcome** — the chosen option and the *because*.
- **Consequences** — positive **and** negative. The honest downsides are what make the log trustworthy.
- **Links** — to superseded/related ADRs, to the C4 view it concerns, to the spec/code.

## Monorepo layout

log4brains models a monorepo as a **global log plus per-package logs**. Declare each package in
`.log4brains.yml`:

```yaml
project:
  name: My Platform
  tz: Europe/Paris
  adrFolder: ./design/adr            # repo-wide, cross-cutting decisions
  packages:
    - name: billing                  # the label shown in the UI and in `adr list`
      path: ./packages/billing       # MUST be an existing directory (the package's code)
      adrFolder: ./packages/billing/design/adr
```

- An ADR is attributed to a package by **which `adrFolder` contains it** — so a package's `adrFolder`
  should sit inside (or under) its `path`. Co-locate package ADRs with the code they explain.
- `path` must point to a directory that exists, or log4brains aborts at startup.
- `repository` is optional; omit it and log4brains tries to infer source links from git.

## Critical gotchas

Each of these has cost real time — internalize them:

- **`adrFolder` must exist and hold `template.md` before `adr new`.** A missing folder or template makes
  the CLI abort ("Package ADR folder path does not exist" / "template.md does not exist"). Also, an
  *empty* directory can get pruned by other tooling between commands — so create the folder by writing a
  file into it (the `template.md`/`index.md`), don't leave it empty.
- **Filenames are `YYYYMMDD-slug.md`, but ordering comes from the `- Date:` metadata**, not the filename
  or git history. Set `Date:` to control where an ADR sits in the timeline.
- **ADRs are immutable. To change a decision, add a new ADR** and set the old one's status to
  `superseded by [new-adr](new-slug.md)`. Editing history in place defeats the entire purpose.
- **`log4brains build` ships an old Next.js/webpack** that can choke on modern transitive dependencies
  (e.g. a security-pinned `minimatch@10` using class-field syntax breaks the bundler). `preview`,
  `adr new`, and `adr list` are unaffected because preview serves a prebuilt UI. If `build` dies on a
  *dependency parse error*, it's the toolchain — not your ADRs. Use `preview` locally, or scope a
  dependency override for the build; **don't weaken a security pin just to satisfy the static build.**
- **Run from the config's directory.** In a monorepo the workdir for every command is the folder
  containing `.log4brains.yml` (the workspace root). Paths in the config resolve relative to it.
- **ADR ≠ C4 ≠ NFR ≠ spec.** Rationale → ADR; structure → the [`c4`] model; quality attributes → the
  [`nfr`] doc; behaviour/API → specs next to the code. Mixing them makes them all rot. Link across
  instead.

## Forward references: the `[TARGET]` placeholder

When an ADR has to cite something that **doesn't exist yet** — a sibling or superseding ADR, the [`c4`]
view it concerns, an [`nfr`] ID it should link back to — write `[TARGET]` in place of the real reference,
never a fabricated slug and never a dropped link. A pending `Links` entry reads `Refined by [TARGET]` or
`Decided NFR [TARGET]`, repointed once the target is created.

`[TARGET]` is a deliberate, greppable debt marker: it records that the link is *owed*, shows up loudly in
review, and is **repointed** the moment the target exists. The ADR isn't finished while an unresolved
`[TARGET]` remains — `grep -rn "\[TARGET\]" design/` is the check. The only legitimate use is a
*consciously deferred* forward reference (the target is planned for a later step); even then it stays
visible as `[TARGET]` — distinct from a *dangling* link to something that should already exist.

## Reference & assets

- `references/log4brains-and-madr.md` — full reference: every `.log4brains.yml` field, the complete MADR
  template anatomy, all CLI commands, monorepo recipes, ADR statuses/lifecycle, and the install/CI
  notes. Read it for anything beyond the basic shape above.
- `assets/template.md` — the MADR template log4brains uses (required in every `adrFolder`).
- `assets/log4brains.yml` — a commented starter config covering single-project and monorepo setups.
- `assets/index.md` — the knowledge-base homepage shown in the generated site.

## Definition of done

`pnpm adr:new` scaffolds a correctly-formatted ADR; `pnpm exec log4brains adr list` shows it (in the
right package, status `accepted`); and `pnpm adr:preview` opens a browsable decision log where each ADR
renders with its MADR sections and links — capturing the *why* alongside the [`c4`] model's *what*. Any
link to a not-yet-written sibling/superseding ADR, C4 view, or NFR ID is a visible `[TARGET]`, and **no
unresolved `[TARGET]` remains** when the ADR is called done.
