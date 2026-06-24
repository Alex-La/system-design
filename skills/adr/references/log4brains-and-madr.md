# log4brains + MADR — full reference

Everything beyond the basic workflow in `SKILL.md`. Read the section you need.

## Contents

1. [Install & scripts](#1-install--scripts)
2. [`.log4brains.yml` — every field](#2-log4brainsyml--every-field)
3. [Monorepo recipes](#3-monorepo-recipes)
4. [CLI commands](#4-cli-commands)
5. [MADR template anatomy](#5-madr-template-anatomy)
6. [ADR lifecycle & statuses](#6-adr-lifecycle--statuses)
7. [Folder layout conventions](#7-folder-layout-conventions)
8. [CI / publishing](#8-ci--publishing)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. Install & scripts

Install as a **dev dependency** so the version is pinned and reproducible (the global `npm i -g
log4brains` the docs show is fine for a quick try, but a project should depend on it explicitly):

```bash
pnpm add -D log4brains      # or npm i -D / yarn add -D
```

Add scripts so the workflow is discoverable and CI can call it:

```jsonc
"scripts": {
  "adr:new":     "log4brains adr new",
  "adr:preview": "log4brains preview",
  "adr:build":   "log4brains build"
}
```

Run everything from the directory that contains `.log4brains.yml`. With pnpm, `pnpm exec log4brains …`
invokes the local binary.

`log4brains init` exists and scaffolds config + first ADR interactively, but it installs globally and
prompts; for a controlled, scripted setup prefer hand-authoring `.log4brains.yml` and copying the
bundled `template.md` / `index.md` (that's what the `assets/` here are for).

## 2. `.log4brains.yml` — every field

```yaml
project:
  name: My Project          # REQUIRED. Display name in the UI.
  tz: Europe/Paris          # REQUIRED. IANA timezone for ADR dates.
  adrFolder: ./design/adr   # REQUIRED. Global ADR folder (relative to this file). Must exist + hold template.md.

  packages:                 # OPTIONAL. Monorepo per-package logs. See §3.
    - name: backend         # Unique label (UI + `adr list`).
      path: ./packages/backend          # Package location. MUST be an existing directory.
      adrFolder: ./packages/backend/design/adr   # That package's ADRs.

  repository:               # OPTIONAL. Enables source/commit links. Inferred from git if omitted.
    url: https://github.com/foo/bar
    provider: github        # github | gitlab | bitbucket | generic
    viewFileUriPattern: /blob/%branch/%path   # REQUIRED only when provider: generic
```

Notes:

- All paths are resolved **relative to the directory containing `.log4brains.yml`**.
- `tz` only affects how dates are displayed/ordered; pick the team's primary zone.
- Package `name`s must be unique or log4brains aborts ("Some package names are duplicated").

## 3. Monorepo recipes

log4brains treats a monorepo as **one global decision log + N per-package logs**. The global `adrFolder`
holds repo-wide decisions; each `packages[]` entry holds that package's decisions.

Directory shape (mirrors the log4brains docs' "multi-package" example, adapted to a `design/` home):

```
repo-root/
├── .log4brains.yml
├── design/
│   └── adr/                      # global log
│       ├── index.md
│       ├── template.md
│       └── 20240101-…my-first-global-adr.md
└── packages/
    └── backend/
        └── design/
            └── adr/              # backend's log
                ├── template.md
                └── 20240102-…backend-decision.md
```

Key rules:

- An ADR's **package is determined by which `adrFolder` contains it.** So put a package's `adrFolder`
  inside its `path`, next to the code it explains.
- Every `adrFolder` (global and per-package) needs its own `template.md`. `index.md` is only needed for
  the global homepage, but it's harmless to add per package.
- A package `path` that doesn't exist is a hard startup error — point it at the real package directory
  (e.g. if the code is under `src/`, use `./packages/foo/src/feature`, not a folder that was moved away).
- You can name the per-package label anything (`name: one-click`) independent of the npm package name —
  it's just the grouping shown in the UI.

## 4. CLI commands

| Command | What it does |
|---|---|
| `log4brains adr new [title]` | Scaffold a new ADR from `template.md`. `-q` skips the interactive prompt (title required). `--package <name>` targets a package's log. `--from <file>` seeds the body from a file. |
| `log4brains preview` | Start the local hot-reloading site (default port 4004). The primary authoring/reading workflow. |
| `log4brains build` | Generate the static site into `.log4brains/out` for publishing. |
| `log4brains adr list` | Print all ADRs with slug, status, package, title — a fast sanity check that parsing/config is correct. |
| `log4brains init` | Interactive first-time setup (global install). |

`adr new` writes a file named `YYYYMMDD-<slug>.md` and drops you into editing it. Equivalent to copying
`template.md` to that filename yourself.

## 5. MADR template anatomy

The bundled `assets/template.md` is the standard MADR template. Section by section:

- **Title** (`# …`) — phrase the decision as an action: "Use Postgres for the ledger", not "Database".
- **Status** — see §6.
- **Deciders / Date / Tags** — optional metadata. `Date` drives ordering (see gotchas).
- **Technical Story** — optional ticket/issue link.
- **Context and Problem Statement** — the forces and the question, 2-3 sentences. Often best as a
  question.
- **Decision Drivers** (optional) — the criteria that matter (performance, cost, team familiarity…).
- **Considered Options** — the genuine alternatives. Always include the rejected one; a single-option
  ADR is not a decision and adds no value.
- **Decision Outcome** — "Chosen option: X, because …". The *because* is the heart of the record.
- **Positive / Negative Consequences** — both. Recording the downsides you accepted is what makes the
  log honest and trustworthy later.
- **Pros and Cons of the Options** (optional) — deeper per-option analysis when the choice was close.
- **Links** — relationships to other ADRs (`Supersedes`, `Refined by`), the C4 view, the spec, the PR.

Keep ADRs short. One decision per record. If you're documenting "what the system is", that's a C4
model, not an ADR.

## 6. ADR lifecycle & statuses

```
proposed ──accept──▶ accepted ──time──▶ deprecated
   │                    │
 reject              superseded by 20240910-new-decision
   ▼
rejected
```

- New decisions already in effect can start at **accepted** (skip `proposed`).
- **Never edit a past decision to change its meaning.** Supersede it: create a new ADR, and set the old
  one's status to `superseded by [new title](20240910-new.md)`. Optionally link back `Supersedes …`.
- `deprecated` means "no longer the way we do it" without a single replacement.
- The immutability is the whole point: the log is an append-only history you can read in order.

## 7. Folder layout conventions

This plugin keeps architecture artifacts under a `design/` folder so the `c4` and `adr` skills compose:

```
design/
├── c4/          # the Structurizr model (the `c4` skill) — WHAT the system is
│   ├── workspace.dsl
│   └── code/…
└── adr/         # the decision log (this skill) — WHY it is that way
    ├── index.md
    ├── template.md
    └── YYYYMMDD-*.md
```

In a monorepo, the global `design/adr` lives at the root and each package gets its own
`packages/<pkg>/…/design/adr`. Cross-link ADRs to the C4 views they concern and vice-versa.

Heads-up: some repos `.gitignore` a top-level `docs/` (a common build-output convention). If you put the
ADR log under `docs/adr` it may silently not be committed — prefer `design/adr`, or confirm the path is
tracked (`git check-ignore <path>`).

## 8. CI / publishing

- `pnpm adr:build` emits a static site (`.log4brains/out`) you can deploy to any static host; wire it
  into CI on the default branch so the published log tracks `main`.
- The decision process is meant to ride on pull requests: a new ADR is `proposed` in a PR, discussed,
  then merged as `accepted`.

## 9. Troubleshooting

- **"Package ADR folder path does not exist" / "template.md does not exist".** The `adrFolder` must
  exist and contain `template.md` before `adr new` runs. Create the folder by writing the
  `template.md`/`index.md` into it — and note that an *empty* directory can be pruned by other tooling
  between commands, so never rely on an empty dir persisting.

- **`adr new` can't find the config.** Run it from the directory containing `.log4brains.yml`. In a
  monorepo that's the workspace root.

- **ADRs appear in the wrong order.** Ordering follows the `- Date:` metadata, then filename. Fix the
  `Date:` line rather than renaming files.

- **`log4brains build` fails with a webpack "Module parse failed: Unexpected token" / "Unexpected
  token (…) options;" on a dependency.** log4brains' static build bundles via an old Next.js/webpack
  that can't parse modern class-field syntax pulled in by a transitive dependency (a security-pinned
  `minimatch@10` is a known trigger). `preview`, `adr new`, and `adr list` are unaffected (preview
  serves a prebuilt UI). Options: rely on `preview` locally; scope a dependency override **for the
  build only**; or upgrade log4brains when a fix lands. Do **not** downgrade a security-pinned
  dependency repo-wide just to make the static build pass.

- **No source/commit links in the site.** Add a `project.repository` block, or ensure `.git` is
  discoverable from the workdir (in some monorepos the git root is above the folder log4brains runs in,
  so inference produces nothing — set `repository` explicitly).
