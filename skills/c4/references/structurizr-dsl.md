# Structurizr DSL reference

Condensed from the official docs (https://docs.structurizr.com/dsl). Enough to author a real
`workspace.dsl`. Note: Structurizr's C4 support covers Context / Container / Component / Dynamic /
Deployment — there is **no native "code" diagram** (use an image view, see §6).

## Contents
1. Skeleton
2. Model elements
3. Boundaries & external elements
4. Relationships
5. Views (context / container / component / dynamic)
6. Image views (code level via Mermaid/PlantUML)
7. Styles & tags
8. Identifiers
9. Gotchas

---

## 1. Skeleton

```
workspace "Name" "Description" {
    model {
        # people, software systems, containers, components, relationships
    }
    views {
        # one block per view + styles + viewset properties
    }
}
```
`name`/`description` on `workspace` are optional. Exactly one `model`; `views` optional (a default set
is generated if omitted, but defining any explicit view removes the defaults).

## 2. Model elements

```
identifier = person "Name" "Description"
identifier = softwareSystem "Name" "Description" {
    identifier = container "Name" "Description" "Technology" {
        identifier = component "Name" "Description" "Technology"
    }
}
```
- Containers nest in software systems; components nest in containers (the C4 hierarchy).
- Arg order: person/softwareSystem = `(Name, Description)`; container/component =
  `(Name, Description, Technology)`.
- Every element auto-gets the tags `Element` and its type (`Person`, `Software System`, `Container`,
  `Component`).
- Databases/queues: `containerDb`, `containerQueue`, `componentDb`, `componentQueue` (or just add a
  `Database` tag and style its shape).

## 3. Boundaries & external elements

- Mark external dependencies by adding a tag and styling it:
  ```
  ext = softwareSystem "External Service" "..." {
      tags "External"
  }
  ```
- Extra grouping when needed: `Enterprise_Boundary`, `Group`, etc. (rarely required — the C4 hierarchy
  already provides boundaries).

## 4. Relationships

```
source -> destination "Description" "Technology"
```
- Uni-directional; `Description`/`Technology` optional. Auto-tagged `Relationship`.
- Inside an element you can use the implicit `this`:
  ```
  user {
      -> system "Uses"
  }
  ```
- Define relationships at the level you'll show them (container-to-container for the container view,
  component-to-component for the component view). A relationship between two components also implies one
  between their parent containers in higher views.

## 5. Views

Each view targets an element and usually does `include *` (everything in scope) + `autolayout`.

```
views {
    systemContext <softwareSystem> "key" "Optional title" {
        include *
        autolayout lr            # lr | rl | tb | bt
    }

    container <softwareSystem> "key" {
        include *
        autolayout lr
    }

    component <container> "key" {
        include *
        autolayout lr
    }

    dynamic <container|softwareSystem|*> "key" "Title" {
        # ordered interactions -> numbered steps. Reuse existing relationships.
        a -> b "step 1"
        b -> c "step 2"
        autolayout lr
    }
}
```
- `include`/`exclude` take element ids or `*`. Scope a view with these instead of overcrowding.
- **Dynamic views list relationships, not elements** — order matters (it becomes the step numbering).
  The relationships should already exist in the model (or be valid between those elements).
- Give every view an explicit `key` so manual tweaks/layout stay stable.

## 6. Image views (code level via Mermaid/PlantUML)

Structurizr has no code-level diagram; embed an image rendered from Mermaid or PlantUML:

```
views {
    properties {
        "mermaid.url" "https://mermaid.ink"   # the rendering server (REQUIRED for mermaid image views)
        "mermaid.format" "svg"
    }

    image <component> "key" {
        mermaid code/foo.mmd                   # path (relative to the workspace) or a URL
        title "Code: Foo classes"
    }
}
```
- `image` attaches to an element (typically a component). The Mermaid source can be a local file path
  or a URL.
- **The `properties { "mermaid.url" ... }` block MUST be inside `views { }` (viewset-level).** A
  workspace-level `properties` block fails to parse: *"Please define a view/viewset property named
  mermaid.url"*.
- Rendering calls the configured server (mermaid.ink by default → needs network and sends the source
  out). Self-host Kroki/Mermaid and point `mermaid.url` at it for private/offline use. PlantUML works
  analogously (`plantuml ...` + `plantuml.url`).

## 7. Styles & tags

```
views {
    styles {
        element "Element"        { color #ffffff }
        element "Person"         { shape Person background #4f46e5 }
        element "Software System" { background #2563eb }
        element "Container"      { background #3b82f6 }
        element "Component"      { background #60a5fa }
        element "Database"       { shape Cylinder }
        element "External"       { background #6b7280 }
        relationship "Relationship" { thickness 2 }
    }
}
```
Styles match by tag. Useful shapes: `Box`, `RoundedBox`, `Cylinder`, `Person`, `Pipe`, `Hexagon`.

## 8. Identifiers

```
!identifiers flat          # ids are global; must be unique across the model; reference from anywhere
!identifiers hierarchical  # (default) reference nested ids by path, e.g. system.container.component
```
`flat` is usually easier for hand-authored workspaces — pick unique ids and reference them directly in
relationships and views.

## 9. Gotchas (recap)

- `structurizr/lite` Docker image = EOL stub; use `structurizr/structurizr local`.
- `mermaid.url`/`mermaid.format` = viewset properties (inside `views{}`), never workspace-level.
- Layout = statement order + `autolayout`; no manual layout directives (`Lay_*` not supported).
- C4 stops at Component; code level is an image view, not a first-class diagram.
- Marking something external = a tag (`tags "External"`) + a matching `element "External"` style.
