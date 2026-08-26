# ADR-0001 — Framework Freeze

**Status:** Accepted

**Date:** 2026-08-26

---

## Context

During the development of the first Evenec book, significant time was spent configuring Git, Quarto, VS Code and the publishing workflow.

Changing infrastructure while writing content slowed development.

## Decision

The publishing framework becomes stable.

Future books will use the existing framework instead of rebuilding it.

Infrastructure changes should only happen when they benefit every publication.

## Consequences

Benefits:

- consistent workflow
- faster content creation
- predictable releases
- reusable publishing system

The project now separates:

- Framework
- Theme
- Content
- Knowledge Core