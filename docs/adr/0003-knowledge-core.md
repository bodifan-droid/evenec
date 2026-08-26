# ADR-0003 — Knowledge Core

**Status:** Accepted

**Date:** 2026-08-26

---

## Context

Multiple books will eventually cover overlapping concepts.

Examples:

- STAR
- KPI
- Stakeholder
- Salary Negotiation

Duplicating content creates maintenance problems.

## Decision

Reusable knowledge objects live inside:

knowledge/

Books consume knowledge.

Knowledge does not belong to individual books.

## Consequences

One update improves every publication.

Future products can reuse the same knowledge:

- books
- website
- flashcards
- SaaS
- AI tutor