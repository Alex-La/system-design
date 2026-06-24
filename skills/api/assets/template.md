# {MODULE_OR_SDK} — Public API Contract

> The exported surface of the `{module}` module — *what it does / how you call it*. The feature's
> *behaviour* (states, flows) is modelled with C4 in [`design/c4`]({path/to/design/c4}); its
> *non-functional requirements* are in [`design/nfr.md`](./design/nfr.md); the *why* behind the design
> lives in the [ADR decision log](./design/adr).
>
> The module root (`{module}/index.ts`) re-exports **only {what is public}** — the {contexts, hooks,
> functions, types} below. {Internal building blocks} are **not re-exported through the module root**;
> their types appear in the signatures here but are referenced, not public (see the final section).

<!-- A cross-link above to a sibling genre not yet written (design/nfr.md, a C4 view, the owning ADR) is
`[TARGET]` — a visible placeholder, repointed once that doc exists. No unresolved `[TARGET]` may remain
when the contract is done. -->

---

## 1. Export inventory

<!-- The whole surface at a glance, grouped by category. This table is the minimal-intentional-surface
check made visible: if it sprawls, the surface probably does too. -->

| Category | Exports |
|----------|---------|
| {Providers & contexts} | `{Export}`, `{Export}`, … |
| {Constants} | `{CONSTANT}`, … |
| {Functions / hooks} | `{export}`, … |
| {Types} | `{Type}`, … |

---

## 2. {Primary export, e.g. the Provider / the client}

<!-- The export a consumer reaches for first. Lead with how you construct/use it (Approachable), then
the parameter/prop table, then what it yields. -->

```tsx
{minimal usage example — the common case, with sensible defaults}
```

**{Props / parameters}**

| {Prop/Param} | Type | Required | Notes |
|--------------|------|----------|-------|
| `{name}` | `{Type}` | yes/no | {meaning; default if optional} |

**{What it returns / yields}** (exported) — what `{accessor}()` returns:

```ts
type {ReturnType} = {
  {field}: {Type}   // {meaning}
}
```

---

## 3. {Operations — functions / hooks}

<!-- For EACH export: signature, params table, what it RETURNS (lead with the logical entity the caller
wants 99% of the time), its PRECONDITIONS, and the ERRORS it can raise. Keep flows out — link the C4
dynamic view instead of retelling steps. -->

### `{exportName}(input) → {ReturnType}`
{One line: what it does and its precondition, e.g. "Requires status `X`."}

```ts
type {InputType} = {
  {field}: {Type}   // {meaning}
}
```
- **Resolves to / returns:** {the logical entity the caller wants}.
- **Preconditions:** {what must be true before the call — required state, ordering}.
- **Throws (recoverable):** `{ERROR_CODE}`, `{ERROR_CODE}` — {when, and what the caller should do}.

<!-- Repeat per export. -->

---

## 4. {Read / selector accessors}

| {Accessor} | Signature | Returns |
|------------|-----------|---------|
| `{name}` | `{() => T}` | {what it returns; when it's null/empty} |

---

## 5. Supporting types (referenced, not re-exported)

<!-- Types that appear in the signatures above but originate in internal modules the root does NOT
re-export. Naming them — and saying they're internal — is part of the contract (it marks the surface
edge). Don't promote internals into §1. -->

| Type | Origin | Shape / meaning |
|------|--------|-----------------|
| `{Type}` | `{internal/}` | {one line} |

---

## 6. Error catalog

<!-- The error model is part of the contract. Split RECOVERABLE (a caller may catch and surface) from
PRECONDITION / CALLER-BUG (the caller must prevent by gating, not catch). Make each error distinct and
named so a caller can react to WHICH failure occurred. -->

**Recoverable** — branded errors a caller may catch and surface to the user:

| Error code | Class / enum | Thrown by | When |
|------------|--------------|-----------|------|
| `{CODE}` | `{ErrorClass}` | `{export}` | {condition} |

**Precondition / caller-bug** — thrown when an export is called in the wrong state. These are *bugs to
prevent* (gate the call on the relevant status/state), not errors to catch:

| Error | Class | Meaning |
|-------|-------|---------|
| `{CODE}` | `{StateException}` | {which precondition was violated} |
