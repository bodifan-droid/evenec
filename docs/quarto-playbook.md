# Evenec Quarto Playbook

Internal publishing guide for the Evenec ecosystem.

Version: 1.0

This document contains only **verified solutions** that were tested while building the Evenec Interview Bible.

---

# Project Structure

```text
evenec/
├── assets/
├── books/
│   └── interview-bible/
│       ├── _quarto.yml
│       ├── templates/
│       ├── assets/
│       ├── hr/
│       ├── sql/
│       ├── excel/
│       ├── powerbi/
│       └── _book/
├── playground/
├── templates/
└── docs/
```

Important.

The book keeps its own local `templates/` and `assets/` folders.

Typst cannot safely access files outside the project root.

---

# Terminal Navigation

Check current folder.

```powershell
pwd
```

List files.

```powershell
ls
```

Open the book.

```powershell
cd books/interview-bible
```

Go back.

```powershell
cd ..
```

Return to repository root.

```powershell
cd C:\Users\shevc\Documents\evenec
```

---

# Save Before Rendering

Always.

**Ctrl+K**

then

**S**

Unsaved files will not be included during rendering.

This caused an empty book during the first setup.

---

# Render Commands

HTML.

```powershell
quarto render
```

Live preview.

```powershell
quarto preview
```

Stop preview.

**Ctrl+C**

---

# Output Folder

Use.

```yaml
project:
  type: book
  output-dir: _book
```

Avoid rendering directly into `releases/`.

Publish later.

---

# Include Rules

Inside chapters.

Use.

```markdown
{{< include ../templates/practice-callout.md >}}
```

For HR.

```markdown
{{< include ../templates/hr-practice-callout.md >}}
```

Do not use absolute `/templates/...`.

Quarto includes are resolved differently from assets.

---

# Asset Rules

Inside local templates.

Use.

```markdown
![](../assets/qr/github-playground.svg)
```

Avoid.

```markdown
../../../assets/...
```

Typst blocks escaping the project root.

---

# SCSS Rules

Quarto themes require layer boundaries.

Correct.

```scss
/*-- scss:defaults --*/

$primary: #0F62FE;

/*-- scss:rules --*/

body {
  font-family: "Inter", sans-serif;
}
```

Wrong.

Plain CSS without SCSS sections.

Error.

> doesn't contain at least one layer boundary

---

# SVG Rules

Always use.

```svg
stroke="currentColor"
fill="none"
```

Benefits.

- Dark mode support
- Consistent styling
- Better PDF rendering

---

# Callout Standard

Use native Quarto callouts.

Correct.

```markdown
::: {.callout-tip title="Practice with Real Data"}

Practice using the Evenec Playground.

:::
```

Avoid GitHub Alerts inside included files.

---

# Typical Errors

## White Page

Cause.

Files were not saved.

Fix.

Save All.

Render again.

---

## Include Not Found

Cause.

Wrong relative path.

Fix.

Use.

```markdown
{{< include ../templates/... >}}
```

---

## Asset Outside Project Root

Cause.

Typst sandbox.

Fix.

Keep assets inside the book project.

---

## SCSS Layer Error

Cause.

Missing Quarto SCSS sections.

Fix.

Use.

```scss
/*-- scss:defaults --*/

/*-- scss:rules --*/
```

---

# Git Workflow

Daily checkpoint.

```powershell
git add .
git commit -m "Meaningful message"
git push
```

Examples.

- Framework v1.0
- Power BI Sprint 2
- Dashboard Update

Commit after every completed sprint.

---

# Publishing Checklist

Before every release.

- [ ] Save All
- [ ] `quarto render`
- [ ] HTML opens correctly
- [ ] PDF builds correctly
- [ ] QR works
- [ ] Dashboard links work
- [ ] Images render
- [ ] Git commit completed

---

# Evenec Principle

> Build once.

> Reuse everywhere.

Every new book should inherit this publishing system instead of reinventing the workflow.

# Local Asset Rule

Images and diagrams should live next to the chapter that uses them.

Example.

```text
powerbi/
├── powerbi-03.md
└── assets/
    └── diagrams/
        └── executive-dashboard-preview.svg
```

Reference it as.

```markdown
![](assets/diagrams/executive-dashboard-preview.svg){width=100%}
```

This behaviour has been verified with Quarto + Typst.