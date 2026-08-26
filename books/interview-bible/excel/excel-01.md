# Excel Interview Bible

# Sprint 1 — Excel Foundations

## Tables • Filters • Sorting • Essential Navigation

Welcome to the Excel Interview Bible.

Unlike traditional Excel courses, this chapter prepares you for **real Junior Data Analyst interviews in UK companies**.

We'll use the **Evenec Retail Playground** throughout every exercise.

---

# The Evenec Retail Dataset

Open:

`playground/evenec-retail/csv/customers.csv`

This is your first working dataset.

You are already familiar with it from SQL.

Now we'll analyse it in Excel.

---

# Why Companies Use Excel

SQL extracts data.

Excel explores it.

A typical workflow looks like this.

- SQL exports data.
- Excel cleans it.
- Pivot Tables summarise it.
- Charts communicate results.

Memory Hook.

> SQL finds data.

> Excel explains data.

---

# Interview Question 1

## Recruiter Psychology

Can you work confidently with raw spreadsheets?

## Task

Open `customers.csv`.

Convert it into an Excel Table.

## Steps

1. Select any cell.
2. Press **Ctrl + T**.
3. Tick "My table has headers."

## Why Tables Matter

Tables automatically expand.

Formulas become easier.

Filters appear automatically.

## Bogdan Notes

During interviews, creating a Table quickly signals confidence with Excel fundamentals.

---

# Interview Question 2

## Filters

Task.

Show only customers from London.

### Steps

- Click the filter arrow.
- Choose London.

### Interview English

> I filtered the customer list to display only London records.

Memory Hook.

Filter hides.

Delete removes.

Never confuse them.

---

# Interview Question 3

## Multi-Level Sorting

Task.

Sort customers by:

1. City (A-Z)
2. Signup Date (Oldest First)

### Steps

Data → Sort

Add another level.

### Why Recruiters Ask This

Real reports rarely use one sort.

---

# Freeze Panes

Imagine scrolling through 5,000 rows.

Headers disappear.

Solution.

View → Freeze Panes.

Memory Hook.

Freeze protects headers.

---

# Interview Question 4

Find the newest customer.

Hint.

Sort by Signup Date.

Descending.

---

# Essential Keyboard Shortcuts

| Shortcut     | Purpose           |
| ------------ | ----------------- |
| Ctrl+T       | Create Table      |
| Ctrl+Shift+L | Toggle Filters    |
| Ctrl+Arrow   | Jump through data |
| Ctrl+Home    | Top of sheet      |
| Ctrl+End     | Last used cell    |

Practice until these become automatic.

---

# Structured References

Instead of

```excel
=A2+B2
```

Tables allow

```excel
=[@Revenue]+[@Tax]
```

Interview Tip.

Recruiters often prefer structured references because they're easier to maintain.

---

# Interview Question 5

Count customers using the status bar.

Don't write a formula.

Select the column.

Read the status bar.

This demonstrates practical Excel knowledge.

---

# Removing Duplicates

Task.

Find unique cities.

Data → Remove Duplicates.

Compare this with SQL.

SQL used:

```sql
SELECT DISTINCT city
FROM customers;
```

Notice.

Different tool.

Same business goal.

---

# Find & Replace

Useful for cleaning imported data.

Shortcut.

**Ctrl + H**

Interview Example.

Replace

`Ltd.`

with

`Limited`.

---

# Data Validation

Business Task.

Create a dropdown list for order status.

Possible values.

- Completed
- Pending
- Cancelled

Why it matters.

Prevents inconsistent data entry.

---

# Conditional Formatting

Task.

Highlight customers who joined this year.

Steps.

Home → Conditional Formatting.

Interview English.

> I used conditional formatting to highlight recent customers.

---

# Quick Quality Checks

Before analysing any spreadsheet, ask:

- Missing values?
- Duplicate rows?
- Correct dates?
- Correct currency?
- Consistent spelling?

Memory Hook.

> Clean before analysing.

---

# Mini Mock Interview

Interviewer.

> Convert this CSV into a Table.

Pause.

Answer.

---

Interviewer.

> Show only London customers.

Pause.

Answer.

---

Interviewer.

> Find duplicate cities.

Pause.

Answer.

---

# Practice Challenge

Using `customers.csv`.

Complete these tasks.

1. Convert to Table.
2. Filter London.
3. Sort by city and date.
4. Freeze headers.
5. Find newest customer.
6. Remove duplicate cities.
7. Create a dropdown list.
8. Highlight recent customers.

Target.

**10 minutes**

Explain every action aloud in English.

---

# Memory Hooks

| Concept    | Hook              |
| ---------- | ----------------- |
| Table      | Smart spreadsheet |
| Filter     | Hide rows         |
| Sort       | Change order      |
| Freeze     | Keep headers      |
| Validation | Prevent mistakes  |

Congratulations.

You completed **Excel Sprint 1**.
{{< include ../../../templates/practice-callout.md >}}