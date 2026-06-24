<!-- This file is the homepage of your Log4brains knowledge base. Edit it freely.
     Replace {PROJECT_NAME} below. -->

# Architecture knowledge base

Welcome 👋 to the architecture knowledge base of {PROJECT_NAME}.
You will find here all the Architecture Decision Records (ADR) of the project.

## Definition and purpose

> An Architectural Decision (AD) is a software design choice that addresses a functional or
> non-functional requirement that is architecturally significant.
> An Architectural Decision Record (ADR) captures a single AD; the collection of ADRs created and
> maintained in a project constitutes its decision log.

An ADR is immutable: only its status can change (it may become deprecated or superseded). That way you
can understand the whole project history by reading the decision log in order. Maintaining it aims to:

- 🚀 speed up onboarding of new team members,
- 🔭 avoid blindly accepting or reversing a past decision,
- 🤝 formalize the team's decision process.

## How this knowledge base is organized

- **Global ADRs** (this folder) record cross-cutting, repo-wide decisions.
- **Package ADRs** (in a monorepo) live next to the code they describe, configured under
  `project.packages` in `.log4brains.yml`.

Structural architecture (the C4 model — context, containers, components) is **not** kept here; it lives
as a Structurizr model alongside this log. ADRs capture _why_ a decision was made; the C4 model
captures _what_ the system looks like.

## More information

- [Log4brains documentation](https://github.com/thomvaill/log4brains)
- [MADR — Markdown Any Decision Records](https://adr.github.io/madr/)
- [What is an ADR and why use them](https://adr.github.io/)
