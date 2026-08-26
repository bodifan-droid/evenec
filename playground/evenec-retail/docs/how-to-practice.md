# How to Practice

Welcome to the **Evenec Retail Playground**.

This companion dataset lets you practice every SQL exercise from the **Data Analyst Interview Bible (UK 2026)** using a real SQLite database.

---

# What You Need

- VS Code
- SQLite extension for VS Code
- `evenec_retail.db`

Estimated setup time: **3 minutes**

---

# Step 1 — Open the Playground

Open the project folder in VS Code.

You should see:

```text
playground/
└── evenec-retail/
    ├── evenec_retail.db
    ├── evenec_retail_schema.sql
    ├── evenec_retail_seed.sql
    └── csv/
```

---

# Step 2 — Install SQLite Extension

In VS Code:

1. Open **Extensions** (`Ctrl+Shift+X`)
2. Search:

   `SQLite`

3. Install the extension by **Alex Covizzi** (or another SQLite extension if already installed).

---

# Step 3 — Open the Database

Open:

`evenec_retail.db`

You should now see the database tables.

Expected tables:

- customers
- orders
- products
- order_items
- payments
- employees

---

# Step 4 — Run Your First Query

Create a new SQL file.

Example:

```sql
SELECT *
FROM customers
LIMIT 10;
```

You should see the first ten customers.

Congratulations.

Your environment is ready.

---

# Practice Roadmap

Follow the same order as the book.

| Sprint | Focus                   |
| ------ | ----------------------- |
| SQL-01 | SELECT, WHERE, ORDER BY |
| SQL-02 | GROUP BY, HAVING        |
| SQL-03 | JOIN, CTE, Subqueries   |
| SQL-04 | Window Functions        |

Don't skip chapters.

Every sprint builds on the previous one.

---

# Recommended Workflow

For every exercise:

1. Read the business question.
2. Think before writing SQL.
3. Write the query.
4. Run it.
5. Compare with the solution.
6. Explain the query aloud in English.

This mirrors real UK interviews.

---

# B2 Interview Practice

Instead of saying:

> "This SQL selects rows."

Say:

> "First I filter the data, then I group it and finally I sort the results."

Practising explanations is just as important as writing correct SQL.

---

# Challenge Mode

Complete each sprint without copying the answers.

Target times:

| Sprint | Target |
| ------ | ------ |
| SQL-01 | 8 min  |
| SQL-02 | 12 min |
| SQL-03 | 15 min |
| SQL-04 | 25 min |

Track your progress.

Speed comes naturally after understanding.

---

# Dataset Overview

| Table       | Purpose             |
| ----------- | ------------------- |
| customers   | Customer profiles   |
| orders      | Orders placed       |
| products    | Product catalogue   |
| order_items | Items inside orders |
| payments    | Payment information |
| employees   | Internal staff      |

Think of the database as one connected business story.

Customer → Order → Item → Product.

---

# Final Goal

By the end of the SQL Bible you should be able to:

- write SQL without copying;
- explain every query in English;
- solve business problems instead of memorising syntax.

Welcome to the Evenec Retail Playground.