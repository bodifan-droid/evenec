# Excel Interview Bible

# Sprint 2 — XLOOKUP, INDEX/MATCH & Text Functions

## Find • Clean • Combine • Validate

Welcome to Sprint 2.

This chapter teaches the Excel functions that recruiters most often expect Junior Data Analysts to know.

We'll continue using the **Evenec Retail Playground**.

Main files:

- `customers.csv`
- `orders.csv`
- `products.csv`

---

# Why Lookup Functions Matter

Imagine this business question.

> "Find the customer's city using only their Customer ID."

This is exactly what lookup functions solve.

Memory Hook.

> IDs connect stories.

Just like SQL JOIN.

---

# Interview Question 6

## XLOOKUP Basics

### Recruiter Psychology

This is currently one of the most valuable Excel functions.

### Business Task

Return the customer's city using `customer_id`.

### Formula

```excel
=XLOOKUP(A2,Customers[customer_id],Customers[city])
```

### Explain It (B2)

> XLOOKUP searches for the customer ID and returns the matching city.

### Memory Hook

Search.

Match.

Return.

### Common Mistake

Mixing lookup and return columns.

---

# Visual

| Customer ID | Result  |
| ----------- | ------- |
| 101         | London  |
| 205         | Leeds   |
| 412         | Bristol |

---

# Why XLOOKUP Replaced VLOOKUP

| VLOOKUP            | XLOOKUP       |
| ------------------ | ------------- |
| Left-to-right only | Any direction |
| Column numbers     | Column names  |
| Less flexible      | More flexible |

Interview Tip.

If asked which you prefer,

choose XLOOKUP.

---

# Interview Question 7

## Product Price Lookup

Business Task.

Find product prices from `products.csv`.

Formula.

```excel
=XLOOKUP(B2,Products[product_id],Products[price])
```

Explain.

> The product ID becomes the search key.

---

# Missing Matches

Business Task.

Display "Not Found" instead of an error.

Formula.

```excel
=XLOOKUP(A2,Customers[customer_id],Customers[city],"Not Found")
```

Memory Hook.

Friendly errors improve reports.

---

# INDEX + MATCH

Some companies still ask this.

Understand it.

Don't fear it.

Formula.

```excel
=INDEX(Customers[city],MATCH(A2,Customers[customer_id],0))
```

Explain.

> MATCH finds the row.

INDEX returns the value.

Memory Hook.

MATCH finds.

INDEX retrieves.

---

# XLOOKUP vs INDEX/MATCH

| XLOOKUP   | INDEX/MATCH    |
| --------- | -------------- |
| Modern    | Classic        |
| Simpler   | More technical |
| Preferred | Still common   |

Interview Advice.

Know both.

Use XLOOKUP when available.

---

# Interview Question 8

## LEFT()

Business Task.

Extract the first three letters.

Formula.

```excel
=LEFT(B2,3)
```

Example.

London

↓

Lon

---

# RIGHT()

Business Task.

Extract the last two characters.

Formula.

```excel
=RIGHT(B2,2)
```

Useful for codes.

---

# MID()

Business Task.

Extract characters from the middle.

Formula.

```excel
=MID(B2,4,5)
```

Memory Hook.

Start.

Length.

Extract.

---

# LEN()

Business Task.

Count characters.

Formula.

```excel
=LEN(B2)
```

Interview Example.

Find unusually short names.

---

# TRIM()

One of the most practical functions.

Business Task.

Remove extra spaces.

Formula.

```excel
=TRIM(B2)
```

Why Recruiters Like This

Imported data often contains hidden spaces.

---

# UPPER, LOWER, PROPER

Standardise text.

Upper.

```excel
=UPPER(B2)
```

Lower.

```excel
=LOWER(B2)
```

Proper.

```excel
=PROPER(B2)
```

Business Example.

Convert

john SMITH

into

John Smith.

---

# TEXT()

Business Task.

Format dates.

Formula.

```excel
=TEXT(A2,"dd mmm yyyy")
```

Example.

2025-01-15

↓

15 Jan 2025

Interview Tip.

Formatting with TEXT doesn't change the original value.

---

# CONCAT()

Business Task.

Build a full name.

Formula.

```excel
=CONCAT(B2," ",C2)
```

Alternative.

```excel
=B2&" "&C2
```

Memory Hook.

Join words.

---

# TEXTJOIN()

Business Task.

Combine multiple values.

Formula.

```excel
=TEXTJOIN(", ",TRUE,A2:A5)
```

Very useful for reports.

---

# Cleaning Imported Data

Real companies rarely receive perfect spreadsheets.

Check:

- Extra spaces
- Wrong capitalisation
- Duplicate IDs
- Blank cells

Always clean before analysing.

---

# Interview Question 9

Customer Full Name

Using `customers.csv`.

Create.

John Smith

from:

John

+

Smith

Expected Formula.

```excel
=CONCAT([@first_name]," ",[@last_name])
```

---

# Interview Question 10

Product Label

Create.

Electronics - £249.99

Formula.

```excel
=CONCAT([@category]," - £",[@price])
```

Business Purpose.

More readable reports.

---

# Error Handling

Instead of showing

`#N/A`

use

```excel
=IFERROR(formula,"Missing")
```

Interview English.

> IFERROR makes reports easier to understand.

Memory Hook.

Hide technical errors.

---

# Mini Business Case

Imagine you're working at Deliveroo.

The manager asks.

> Build a clean customer list.

Expected Workflow.

1. TRIM.
2. PROPER.
3. Remove duplicates.
4. Create Full Name.
5. Format dates.

Notice.

This is exactly how analysts think.

---

# Mini Mock Interview

Interviewer.

> Find a customer's city.

Pause.

Answer.

---

Interviewer.

> Clean imported names.

Pause.

Answer.

---

Interviewer.

> Explain XLOOKUP.

Pause.

Answer.

---

# Formula Cheat Sheet

| Task          | Formula     |
| ------------- | ----------- |
| Lookup        | XLOOKUP     |
| Alternative   | INDEX/MATCH |
| First letters | LEFT        |
| Last letters  | RIGHT       |
| Middle        | MID         |
| Length        | LEN         |
| Clean spaces  | TRIM        |
| Uppercase     | UPPER       |
| Lowercase     | LOWER       |
| Proper Case   | PROPER      |
| Format        | TEXT        |
| Join          | CONCAT      |
| Many values   | TEXTJOIN    |

---

# Memory Hooks

| Function | Hook          |
| -------- | ------------- |
| XLOOKUP  | Find & Return |
| MATCH    | Find Position |
| INDEX    | Bring Value   |
| LEFT     | Beginning     |
| RIGHT    | Ending        |
| MID      | Middle        |
| TRIM     | Clean Spaces  |
| TEXT     | Pretty Format |

---

# End-of-Sprint Challenge

Using the Evenec Retail CSV files, complete these tasks without copying the answers.

1. Lookup customer city.
2. Lookup product price.
3. Replace missing values with "Not Found".
4. Build a full name.
5. Extract the first three letters.
6. Clean extra spaces.
7. Convert names to Proper Case.
8. Format dates.
9. Build a product label.
10. Explain XLOOKUP in English.

Target.

**15 minutes**

Remember.

Companies don't hire people because they know formulas.

They hire people because they can quickly turn messy data into useful information.

Congratulations.

You completed **Excel Sprint 2**.
{{< include /templates/practice-callout.md >}}