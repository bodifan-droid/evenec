# Evenec Troubleshooting Guide

Verified fixes discovered during real project development.

---

# Rule #1 — Save Before Render

## Symptoms

- `quarto render` finishes successfully.
- The book does not update.
- Old content appears after rendering.

## Cause

Quarto only reads files that are already saved on disk.

Open tabs with a ● contain unsaved changes.

## Fix

1. Save the file (`Ctrl+S`).
2. Or use **File → Save All** (`Ctrl+K S`).
3. Confirm there is no ● on open tabs.
4. Run:

```powershell
quarto render
```

## Lesson Learned

Always save before rendering.

This became the first verified troubleshooting rule of the Evenec Publishing Framework.

---

# Rule #2 — Check Your Current Folder

## Symptoms

`cd books/interview-bible` returns:

```
Cannot find path ...
```

## Cause

You are already inside `books/interview-bible`.

## Fix

Check the PowerShell prompt.

If it already shows:

```
PS ...\books\interview-bible>
```

Run:

```powershell
quarto render
```

instead of changing directories again.