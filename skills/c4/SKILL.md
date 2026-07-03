---
name: c4
description: >-
  Create and evolve interactive C4 software-architecture models as code using Structurizr DSL. Use this
  whenever the user wants to design or document system/software architecture, draw or update C4 diagrams
  (system context, container, component, or code level), "model a system", map how services/components
  fit together, set up architecture-as-code, or produce navigable/drill-down architecture diagrams — and
  even when they just say "diagram the architecture", "how is this system structured", or mention
  Structurizr or C4 without spelling out the level. Prefer this over ad-hoc Mermaid C4 diagrams, because
  Structurizr defines the model ONCE and generates linked views you can navigate, instead of separate
  unlinked pictures that drift apart.
---

# C4 architecture modeling with Structurizr

## Why this approach

**C4** describes a system at four zoom levels, each drilling into one box of the level above:

1. **Context** — the system as one box, its users, and external systems.
2. **Container** — the deployable/runnable units inside the system.
3. **Component** — the building blocks inside one container.
4. **Code** — classes/state inside one component (usually optional; drifts fast).

**Structurizr** is the right tool because you **define the model once** (people, systems, containers,
components, relationships) and it **generates every view from that one model**. The views stay
consistent and you can **navigate** between levels (click a container → its component view). Hand-drawn
Mermaid C4 can't do this — each diagram is a separate, unlinked picture that drifts. So reach for
Structurizr whenever the goal is a *model* you'll keep and explore, not a one-off picture.

## The workflow

Work top-down and keep everything in one `workspace.dsl`.

1. **Set up a `design/` folder** at a sensible location (repo root, or a `design/` next to the code).
   Copy the bundled starter so you don't hand-write boilerplate:
   - `assets/workspace.dsl` → `design/workspace.dsl`
   - `assets/Dockerfile` → `design/Dockerfile`
   - `assets/run.sh` → `design/run.sh` (then `chmod +x design/run.sh`)
   - `assets/code/` → `design/code/` (Mermaid sources for code-level image views)

2. **Model the system once** in the `model { }` block. Discover the real actors, containers, and
   external systems from the codebase first (read configs, entrypoints, deploy scripts) — accuracy of
   boundaries and edges is the whole point. Shape:
   ```
   person, softwareSystem { container { component } }, external softwareSystem (tags "External")
   a -> b "relationship" "tech"
   ```
   Use `!identifiers flat` so every element has a unique id you can reference from anywhere.
   Full syntax: **`references/structurizr-dsl.md`** — read it before writing non-trivial DSL.

3. **Define the views** in `views { }` — one per level you need, each with `include *` and `autolayout`:
   `systemContext`, `container`, `component <container>`, and `dynamic <container>` for an important
   flow. These are what render and what you navigate.

4. **Code level (L4) via image views.** Structurizr has no native code level, so embed Mermaid: keep
   `classDiagram` / `stateDiagram-v2` files in `design/code/*.mmd` and reference them from an
   `image <component> { mermaid code/foo.mmd  title "..." }` view. See the gotcha about the mermaid
   server below — it's the #1 thing people get wrong.

5. **Style** with tags (`element "External" { ... }`, `Database` shape, etc.) so the diagrams read well.

6. **View it interactively.** From `design/`, run `./run.sh` — it builds the bundled `Dockerfile` and
   runs `structurizr/structurizr local`, bind-mounting the folder, then opens
   http://localhost:8080. Edit `workspace.dsl`, refresh the browser to see changes. Stop with
   `./run.sh stop`.

## Critical gotchas

These are non-obvious and each one silently breaks the model — internalize them:

- **Use `structurizr/structurizr local`, NOT `structurizr/lite`.** The `structurizr/lite` Docker image
  is now an end-of-life **stub**: it prints a migration banner and exits 0 (no server). The consolidated
  `structurizr/structurizr` image with the `local` subcommand is the working interactive viewer.
- **`mermaid.url` / `mermaid.format` are *viewset* properties.** Put the `properties { }` block **inside
  `views { }`**, not at workspace level — otherwise the DSL fails to parse with
  *"Please define a view/viewset property named mermaid.url"*. Image views render by sending the Mermaid
  source to that server (`https://mermaid.ink` by default) → needs network and ships your diagram source
  to a third party. Self-host a Kroki/Mermaid server and point `mermaid.url` at it to stay private.
- **C4 is purely structural** ("who talks to whom"). Decisions (the [`adr`] log), non-functional
  requirements (the [`nfr`] doc), and behaviour/API specs are **not** C4 levels — keep them in their own
  genres and link to them; don't try to encode them in the DSL.
- **Layout is implicit.** Ordering of statements + `autolayout` controls layout; there are no manual
  layout directives. Keep each view readable by scoping `include`/`exclude` rather than dumping
  everything.
- **For live editing, bind-mount — don't bake.** The bundled `Dockerfile` copies the model in so the
  image runs standalone, but `run.sh` bind-mounts the `design/` dir over it so edits show on refresh.
- **Libraries aren't containers.** In strict C4 a shared library/package is a *component* inside the
  container that runs it (e.g. a browser app), not its own container. Model it where it executes.

## Forward references: the `[TARGET]` placeholder

When the model or its docs reference something that **doesn't exist yet** — a planned-but-unbuilt
system / container / component or relationship, or a link out to an [`adr`]/[`nfr`] not yet written —
mark it `[TARGET]` rather than inventing a real-looking reference. For a provisional element, put
`[TARGET]` in its name/description and tag it `TARGET` so it renders as visibly not-yet-real; for a doc
link, write `[TARGET]` until the sibling exists. Don't wire a relationship to a fabricated identifier —
Structurizr won't parse a dangling id, so model the placeholder element explicitly instead.

`[TARGET]` is a deliberate, greppable debt marker: it records what is *owed*, shows up loudly in review,
and is **repointed** the moment the target is built. The model isn't done while an unresolved `[TARGET]`
remains — `grep -rn "\[TARGET\]" design/` is the check — unless it's a *consciously deferred* placeholder
for a planned element, which stays visible as `[TARGET]`.

## Reference & assets

- `references/structurizr-dsl.md` — full DSL syntax (elements, boundaries, relationships, all view
  types, image views, styles, identifiers). Read it for anything beyond the basic shape above.
- `assets/workspace.dsl` — a complete, runnable starter model (all four view types + an image view +
  styles + the viewset mermaid properties). Adapt it; don't start from a blank file.
- `assets/Dockerfile`, `assets/run.sh`, `assets/code/example-class.mmd` — the viewer scaffolding.

## Definition of done

The user can run `./run.sh` in their `design/` folder, the browser opens to a parsing-clean workspace,
and they can drill Context → Container → Component (and open the Dynamic/code views) with the boxes and
edges accurately reflecting the real system. Any planned-but-unbuilt element, or a link out to a
not-yet-written ADR/NFR, is a visible `[TARGET]` (never a fabricated identifier), and **no unresolved
`[TARGET]` remains** when the model is called done.
