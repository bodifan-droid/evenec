# SQL Bible

# Sprint 4 — Window Functions & Interview Finale

## ROW_NUMBER • RANK • DENSE_RANK • LAG • LEAD • OVER()

Welcome to the final SQL sprint.

By now you've learned:

- filtering;
- aggregation;
- joins;
- CTEs;
- subqueries.

Now you'll learn the functions that often separate a confident Junior Analyst from someone who only knows basic SQL.

---

# Why Window Functions Matter

Imagine this question.

> Who are the top three customers in every city?

GROUP BY cannot answer this alone.

Window functions calculate values **without destroying individual rows**.

Memory Hook.

> GROUP BY collapses.

> WINDOW looks through.

---

# The Window Mental Model

Think of standing inside a moving window.

The table stays.

The calculation changes.

Rows remain visible.

---

# OVER()

Every window function uses:

```sql
OVER(...)
```

Think of it as:

> Look through this window.

---

# Question 33 — ROW_NUMBER()

## Recruiter Psychology

This is one of the most common technical interview questions.

## Business Task

Number every order.

```sql
SELECT order_id,
       amount,
       ROW_NUMBER() OVER(ORDER BY amount DESC) AS row_num
FROM orders;
```

## Explain It (B2)

> I sort orders by amount and assign a unique number to each row.

Memory Hook.

ROW_NUMBER never repeats.

---

# Visual

| Amount | ROW_NUMBER |
| ------ | ---------: |
| 500    |          1 |
| 400    |          2 |
| 300    |          3 |

Unique numbering.

---

# Question 34 — RANK()

Business Task.

Rank customers by revenue.

```sql
SELECT customer_id,
       revenue,
       RANK() OVER(ORDER BY revenue DESC) AS customer_rank
FROM customer_revenue;
```

Result.

| Revenue | Rank |
| ------- | ---- |
| 500     | 1    |
| 400     | 2    |
| 400     | 2    |
| 300     | 4    |

Notice.

Rank skips numbers.

Memory Hook.

RANK leaves gaps.

---

# Question 35 — DENSE_RANK()

Same example.

```sql
SELECT customer_id,
       revenue,
       DENSE_RANK() OVER(ORDER BY revenue DESC) AS dense_rank
FROM customer_revenue;
```

Result.

| Revenue | Dense Rank |
| ------- | ---------: |
| 500     |          1 |
| 400     |          2 |
| 400     |          2 |
| 300     |          3 |

No gaps.

Memory Hook.

Dense fills gaps.

---

# Interview Trap

Question.

> When would you choose DENSE_RANK instead of RANK?

Good answer.

> When tied values shouldn't create gaps in the ranking.

---

# PARTITION BY

Window functions become much more powerful.

Example.

Rank customers **inside each city**.

```sql
SELECT customer_id,
       city,
       revenue,
       ROW_NUMBER()
       OVER(
           PARTITION BY city
           ORDER BY revenue DESC
       ) AS city_rank
FROM customer_revenue;
```

Memory Hook.

PARTITION creates mini competitions.

---

# Visual

London.

| Revenue | Rank |
| ------- | ---- |
| 500     | 1    |
| 300     | 2    |

Manchester.

| Revenue | Rank |
| ------- | ---- |
| 600     | 1    |
| 250     | 2    |

Separate rankings.

---

# Question 36 — Top Customer in Every City

Business Task.

Return only the best customer from each city.

```sql
WITH ranked AS
(
SELECT customer_id,
       city,
       revenue,
       ROW_NUMBER()
       OVER(
         PARTITION BY city
         ORDER BY revenue DESC
       ) AS rn
FROM customer_revenue
)

SELECT *
FROM ranked
WHERE rn=1;
```

Explain.

> First I rank customers inside each city, then I keep only rank one.

---

# LAG()

LAG compares with the previous row.

Business Task.

Compare today's revenue with yesterday's.

```sql
SELECT order_date,
       revenue,
       LAG(revenue)
       OVER(ORDER BY order_date) AS previous_day
FROM daily_sales;
```

Memory Hook.

LAG looks back.

---

# LEAD()

LEAD looks forward.

```sql
SELECT order_date,
       revenue,
       LEAD(revenue)
       OVER(ORDER BY order_date) AS next_day
FROM daily_sales;
```

Memory Hook.

LEAD looks ahead.

---

# Running Total

A classic interview question.

Business Task.

Calculate cumulative revenue.

```sql
SELECT order_date,
       amount,
       SUM(amount)
       OVER(
         ORDER BY order_date
       ) AS running_total
FROM orders;
```

Explain.

> The total grows after every row.

Memory Hook.

Running total keeps growing.

---

# Moving Average

Another popular interview task.

```sql
SELECT order_date,
       revenue,
       AVG(revenue)
       OVER(
         ORDER BY order_date
         ROWS BETWEEN 6 PRECEDING
         AND CURRENT ROW
       ) AS seven_day_average
FROM daily_sales;
```

Interview Tip.

Don't memorise.

Understand.

The window moves.

---

# Window Function Cheat Sheet

| Function   | Purpose              |
| ---------- | -------------------- |
| ROW_NUMBER | Unique numbering     |
| RANK       | Ranking with gaps    |
| DENSE_RANK | Ranking without gaps |
| LAG        | Previous row         |
| LEAD       | Next row             |
| SUM OVER   | Running total        |

---

# Business Case 1 — Tesco

Question.

Which city generated the most revenue?

Expected Thinking.

- Join customers.
- Group by city.
- Sum revenue.
- Sort descending.

---

# Business Case 2 — Amazon

Question.

Find the highest-spending customer in every city.

Expected Solution.

Use:

- CTE
- ROW_NUMBER
- PARTITION BY

---

# Business Case 3 — Deliveroo

Question.

Find customers who haven't ordered recently.

Expected Thinking.

- Latest order.
- Compare dates.
- Filter inactive customers.

---

# Business Case 4 — NHS

Question.

Calculate average appointments per patient.

Same SQL principle.

Business changes.

Logic stays.

---

# Business Case 5 — Wise

Question.

Which payment method processes the most money?

Expected Thinking.

- Join payments.
- Group by payment method.
- SUM(amount).

---

# Business Case 6 — Monzo

Question.

Find unusually large transactions.

Expected Thinking.

Use:

- AVG
- Subquery
- WHERE.

---

# Business Case 7 — Retail Dashboard

Question.

Create KPIs.

Required.

- Total revenue
- Average order
- Largest order
- Customer count

---

# Business Case 8 — Customer Retention

Question.

Who made repeat purchases?

Expected Thinking.

Count orders.

HAVING COUNT()>1.

---

# Business Case 9 — Product Performance

Question.

Top-selling category.

Expected Thinking.

Join.

Group.

Sort.

---

# Business Case 10 — Executive Report

Imagine presenting to a CEO.

Don't say.

> GROUP BY...

Instead say.

> London generated the highest revenue, while Birmingham showed the fastest growth.

Analysts communicate business impact.

---

# Full Mock SQL Interview (45 Minutes)

This simulates a real UK Junior Data Analyst interview.

## Part 1 — Warm-up (10 min)

**Interviewer**

Show London customers.

Pause.

Answer.

---

Find completed orders.

Pause.

Answer.

---

Top five orders.

Pause.

Answer.

---

## Part 2 — Aggregations (10 min)

Revenue by city.

Pause.

Answer.

---

Customers spending over £500.

Pause.

Answer.

---

Explain HAVING.

Pause.

Answer.

---

## Part 3 — JOINs (10 min)

Connect customers and orders.

Pause.

Answer.

---

Find customers without orders.

Pause.

Answer.

---

Explain LEFT JOIN.

Pause.

Answer.

---

## Part 4 — Advanced SQL (15 min)

Rank customers.

Pause.

Answer.

---

Above-average orders.

Pause.

Answer.

---

Top customer in every city.

Pause.

Answer.

---

Running total.

Pause.

Answer.

---

# Interview English Cheat Sheet

Useful phrases.

Instead of:

> "SQL does this..."

Say:

> First I filter...

> Then I group...

> After that I calculate...

> Finally I sort...

This sounds much more natural in interviews.

---

# Common Interview Mistakes

❌ Writing before thinking.

✔ Explain your approach first.

---

❌ Memorising syntax only.

✔ Explain business reasoning.

---

❌ Panicking during joins.

✔ Draw relationships mentally.

---

# 5-Minute Emergency Revision

Remember these.

## SELECT

Choose columns.

## WHERE

Filter rows.

## GROUP BY

Create groups.

## HAVING

Filter groups.

## JOIN

Connect stories.

## CTE

Temporary workspace.

## ROW_NUMBER

Unique numbering.

## RANK

Leaves gaps.

## DENSE_RANK

No gaps.

## LAG

Looks back.

## LEAD

Looks ahead.

---

# Final SQL Challenge

Complete these ten tasks without looking.

1. London customers.
2. Revenue by city.
3. Top five orders.
4. Customers over £500.
5. Join customers and orders.
6. Customers without orders.
7. Above-average orders.
8. Top customer per city.
9. Running total.
10. Rank customers.

Target.

- **25 minutes**
- explain every query aloud in English.

---

# SQL Bible Complete

Congratulations.

You have completed all four SQL sprints.

Before moving to Excel and Power BI, make sure you can:

- write queries without copying;
- explain every query in English;
- recognise business questions behind SQL tasks.

Remember.

Companies don't hire analysts because they know SQL.

They hire analysts because they solve business problems with SQL.
{{< include ../templates/practice-callout.md >}}