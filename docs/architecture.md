# Evenec Architecture

Publishing System • Playground • Assets • Templates

Version: 1.0

This document explains how the entire Evenec ecosystem fits together.

The goal is simple.

> One publishing system.

> Unlimited books.

---

# The Big Picture

<svg viewBox="0 0 760 520" width="100%" height="520">
  <rect x="250" y="20" width="260" height="70" rx="16" fill="none" stroke="currentColor" stroke-width="2"/>
  <text x="380" y="55" text-anchor="middle" font-size="18">Evenec Repository</text>

  <rect x="40" y="140" width="150" height="70" rx="12" fill="none" stroke="currentColor"/>
  <text x="115" y="175" text-anchor="middle" font-size="15">Books</text>

  <rect x="220" y="140" width="150" height="70" rx="12" fill="none" stroke="currentColor"/>
  <text x="295" y="175" text-anchor="middle" font-size="15">Playground</text>

  <rect x="400" y="140" width="150" height="70" rx="12" fill="none" stroke="currentColor"/>
  <text x="475" y="175" text-anchor="middle" font-size="15">Templates</text>

  <rect x="580" y="140" width="140" height="70" rx="12" fill="none" stroke="currentColor"/>
  <text x="650" y="175" text-anchor="middle" font-size="15">Assets</text>

  <rect x="220" y="300" width="320" height="90" rx="14" fill="none" stroke="currentColor" stroke-width="2"/>
  <text x="380" y="335" text-anchor="middle" font-size="18">Quarto Publishing System</text>
  <text x="380" y="360" text-anchor="middle" font-size="14">HTML • PDF • GitHub Pages</text>

  <line x1="380" y1="90" x2="115" y2="140" stroke="currentColor" stroke-width="2"/>
  <line x1="380" y1="90" x2="295" y2="140" stroke="currentColor" stroke-width="2"/>
  <line x1="380" y1="90" x2="475" y2="140" stroke="currentColor" stroke-width="2"/>
  <line x1="380" y1="90" x2="650" y2="140" stroke="currentColor" stroke-width="2"/>

  <line x1="115" y1="210" x2="280" y2="300" stroke="currentColor" stroke-width="2"/>
  <line x1="295" y1="210" x2="330" y2="300" stroke="currentColor" stroke-width="2"/>
  <line x1="475" y1="210" x2="430" y2="300" stroke="currentColor" stroke-width="2"/>
  <line x1="650" y1="210" x2="480" y2="300" stroke="currentColor" stroke-width="2"/>
</svg>

Everything ultimately flows into one publishing pipeline.

---

# Repository Layout

```text
evenec/
├── books/
├── playground/
├── templates/
├── assets/
├── docs/
├── releases/
└── .github/
```

Every folder has a single responsibility.

No duplicates.

No confusion.

---

# Books

Purpose.

Learning content.

Current project.

```text
books/
└── interview-bible/
```

Contains.

- HR Bible
- SQL Bible
- Excel Bible
- Power BI Bible

Future books.

- Python Bible
- Statistics Bible
- Tableau Bible

The publishing system should work for all of them.

---

# Playground

Purpose.

Real practice.

Current project.

```text
playground/
└── evenec-retail/
```

Contains.

- SQLite database
- SQL scripts
- CSV datasets
- Excel Dashboard
- Power BI project
- Documentation

The Playground connects every book.

Memory Hook.

Learn.

Then practice.

---

# Templates

Purpose.

Reusable publishing components.

Examples.

- Practice Callout
- HR Callout
- Bogdan Notes
- Interview Tips
- Brand Theme

Write once.

Reuse everywhere.

---

# Assets

Purpose.

Shared visual resources.

Examples.

- QR codes
- Logos
- Icons
- Cover graphics

Assets should remain consistent across the entire brand.

---

# Documentation

Purpose.

Maintain the publishing system.

Current documents.

- README
- CONTRIBUTING
- Quarto Playbook
- Architecture

Think of this folder as the operating manual for Evenec.

---

# Releases

Purpose.

Final published artifacts.

Examples.

- PDF
- HTML
- Future EPUB

The release folder contains finished products.

Not working files.

---

# GitHub

Purpose.

Automation.

Contains.

- workflows
- future CI
- future automatic releases

Eventually.

Every push to `main` should be able to produce a publishable release.

---

# How One Chapter Becomes a Book

Example.

```text
hr-01.md
      │
      ▼
Quarto
      │
      ▼
HTML
      │
      ▼
PDF
      │
      ▼
Release
```

One source.

Multiple outputs.

---

# The Learning Pipeline

The reader experiences Evenec in this order.

<svg viewBox="0 0 760 120" width="100%" height="120">
  <rect x="20" y="30" width="120" height="50" rx="10" fill="none" stroke="currentColor"/>
  <rect x="170" y="30" width="120" height="50" rx="10" fill="none" stroke="currentColor"/>
  <rect x="320" y="30" width="120" height="50" rx="10" fill="none" stroke="currentColor"/>
  <rect x="470" y="30" width="120" height="50" rx="10" fill="none" stroke="currentColor"/>
  <rect x="620" y="30" width="120" height="50" rx="10" fill="none" stroke="currentColor"/>

  <text x="80" y="60" text-anchor="middle" font-size="14">Read</text>
  <text x="230" y="60" text-anchor="middle" font-size="14">Practice</text>
  <text x="380" y="60" text-anchor="middle" font-size="14">Build</text>
  <text x="530" y="60" text-anchor="middle" font-size="14">Present</text>
  <text x="680" y="60" text-anchor="middle" font-size="14">Interview</text>

  <line x1="140" y1="55" x2="170" y2="55" stroke="currentColor" stroke-width="2"/>
  <line x1="290" y1="55" x2="320" y2="55" stroke="currentColor" stroke-width="2"/>
  <line x1="440" y1="55" x2="470" y2="55" stroke="currentColor" stroke-width="2"/>
  <line x1="590" y1="55" x2="620" y2="55" stroke="currentColor" stroke-width="2"/>
</svg>

This pipeline is repeated across every Evenec book.

---

# Evenec Principles

Every decision should support these principles.

| Principle           | Meaning                                  |
| ------------------- | ---------------------------------------- |
| One Source          | Write once, publish everywhere.          |
| Reusable Components | Templates reduce duplication.            |
| Real Practice       | Every lesson connects to the Playground. |
| Business First      | Teach decisions, not buttons.            |
| Consistent Design   | Every book feels like Evenec.            |

These principles are more important than any individual technology.

---

# Future Expansion

The architecture is intentionally modular.

Future additions.

```text
books/
├── python-bible/
├── statistics-bible/
├── tableau-bible/
└── ai-for-analysts/
```

No structural changes should be required.

Only new content.

---

# Architecture Philosophy

Evenec is designed as a publishing platform rather than a single book.

The long-term goal is simple.

> Build once.

> Reuse everywhere.

Every new book should inherit the same design system, playground integration, publishing workflow and documentation instead of creating a new workflow from scratch.