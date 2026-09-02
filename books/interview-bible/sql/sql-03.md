# SQL Bible

# Sprint 3 — JOINs, CTEs & Subqueries

## The Language of Relationships

Welcome to the most important chapter for Junior Data Analyst interviews.

Most real business questions require combining information from multiple tables.

Instead of memorising JOIN syntax, you'll learn to think like an analyst.

---

# Relationship Map

Think of a typical retail business.

- Customers place orders.
- Orders contain items.
- Items reference products.
- Orders receive payments.

## Entity Relationship Overview

<svg viewBox="0 0 760 360" width="100%" height="360" xmlns="http://www.w3.org/2000/svg">
  <rect x="40" y="40" width="170" height="70" rx="10" fill="none" stroke="currentColor" stroke-width="2"/>
  <text x="125" y="80" text-anchor="middle" font-size="18">customers</text>

  <rect x="290" y="40" width="170" height="70" rx="10" fill="none" stroke="currentColor" stroke-width="2"/>
  <text x="375" y="80" text-anchor="middle" font-size="18">orders</text>

  <rect x="540" y="40" width="170" height="70" rx="10" fill="none" stroke="currentColor" stroke-width="2"/>
  <text x="625" y="80" text-anchor="middle" font-size="18">payments</text>

  <rect x="290" y="220" width="170" height="70" rx="10" fill="none" stroke="currentColor" stroke-width="2"/>
  <text x="375" y="260" text-anchor="middle" font-size="18">order_items</text>

  <rect x="540" y="220" width="170" height="70" rx="10" fill="none" stroke="currentColor" stroke-width="2"/>
  <text x="625" y="260" text-anchor="middle" font-size="18">products</text>

  <line x1="210" y1="75" x2="290" y2="75" stroke="currentColor" stroke-width="2"/>
  <line x1="460" y1="75" x2="540" y2="75" stroke="currentColor" stroke-width="2"/>
  <line x1="375" y1="110" x2="375" y2="220" stroke="currentColor" stroke-width="2"/>
  <line x1="460" y1="255" x2="540" y2="255" stroke="currentColor" stroke-width="2"/>

  <text x="250" y="60" font-size="14">customer_id</text>
  <text x="500" y="60" font-size="14">order_id</text>
  <text x="385" y="170" font-size="14">order_id</text>
  <text x="500" y="240" font-size="14">product_id</text>
</svg>

::: {.callout-note title="Memory Hook"}
**Customer → Order → Item → Product**
 
Follow the relationship one step at a time.
:::

---

# Why JOIN Exists

Imagine two separate tables.

**customers**

| customer_id | first_name |
| ----------- | ---------- |
| 1           | Alice      |
| 2           | Bob        |

**orders**

| order_id | customer_id | amount |
| -------- | ----------- | ------ |
| 101      | 1           | 120    |
| 102      | 2           | 60     |

A JOIN connects them.

Result.

| first_name | amount |
| ---------- | ------ |
| Alice      | 120    |
| Bob        | 60     |

---

# JOIN Mental Model

Instead of remembering syntax,

remember relationships.

> Keys connect stories.

Primary Key.

Foreign Key.

Bridge.

---

# Question 26 — INNER JOIN

## Recruiter Psychology

This is one of the most common interview questions.

## Business Task

Show every order together with the customer's name.

## SQL Solution

```sql
SELECT c.first_name,
       o.order_id,
       o.amount
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id;
```

## Explain It (B2)

> I connect customers and orders using customer_id and return customer names with their orders.

::: {.callout-note title="Memory Hook"}
INNER = Both must exist.
:::

---

# INNER JOIN Visual

<svg viewBox="0 0 420 170" width="100%" height="170" xmlns="http://www.w3.org/2000/svg">
  <circle cx="160" cy="85" r="55" fill="none" stroke="currentColor" stroke-width="3"/>
  <circle cx="260" cy="85" r="55" fill="none" stroke="currentColor" stroke-width="3"/>
  <path d="M205 40 A55 55 0 0 1 205 130 A55 55 0 0 1 205 40 Z" fill="currentColor" fill-opacity="0.18"/>
  <text x="120" y="85" text-anchor="middle" font-size="16">Customers</text>
  <text x="300" y="85" text-anchor="middle" font-size="16">Orders</text>
</svg>

Only the overlap remains.

---

# Question 27 — LEFT JOIN

## Business Task

Show every customer, even if they never ordered.

## SQL

```sql
SELECT c.first_name,
       o.order_id
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id;
```

## Explain It (B2)

> Every customer appears. Missing orders become NULL.

::: {.callout-note title="Memory Hook"}
**Left keeps everyone.**

This phrase will appear throughout the book.
:::


---

# LEFT JOIN Visual

<svg viewBox="0 0 420 170" width="100%" height="170" xmlns="http://www.w3.org/2000/svg">
  <circle cx="160" cy="85" r="55" fill="none" stroke="currentColor" stroke-width="3"/>
  <circle cx="260" cy="85" r="55" fill="none" stroke="currentColor" stroke-width="3"/>
  <path d="M105 85 A55 55 0 1 0 215 85 L205 85 A45 45 0 1 1 115 85 Z" fill="currentColor" fill-opacity="0.18"/>
  <path d="M205 40 A55 55 0 0 1 205 130 A55 55 0 0 1 205 40 Z" fill="currentColor" fill-opacity="0.18"/>
  <text x="120" y="85" text-anchor="middle" font-size="16">Customers</text>
  <text x="300" y="85" text-anchor="middle" font-size="16">Orders</text>
</svg>

Everything from the left table survives.

---

# Interview Trap

Question.

> Why is LEFT JOIN useful?

Good answer.

> It allows me to keep every customer even when related records don't exist.

Avoid saying.

> Because it joins left.

Explain the business value.

---

# Question 28 — Find Customers Without Orders

## SQL

```sql
SELECT c.first_name
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

## Explain It (B2)

> I keep every customer and filter those without matching orders.

::: {.callout-note title="Memory Hook"}
NULL means "missing".
:::

---

# Question 29 — Join Three Tables

Business questions often need multiple joins.

Example.

Customers.

Orders.

Payments.

```sql
SELECT c.first_name,
       o.order_id,
       p.payment_method
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN payments p
ON o.order_id = p.order_id;
```

Explain.

> First I connect customers to orders, then orders to payments.

Think.

Step by step.

---

# JOIN Order

Always ask yourself.

What is my starting table?

Then walk through relationships.

Customer
   ↓
Order
   ↓
Payment

Never jump randomly.

---

# CTE — Common Table Expression

Interviewers love CTEs because they improve readability.

::: {.callout-note title="Memory Hook"}
> CTE = Temporary workspace.

Instead of writing one giant query,

build it in steps.
:::

---

# Question 30 — First CTE

Business Task.

Find high-value customers.

```sql
WITH customer_revenue AS (
    SELECT customer_id,
           SUM(amount) AS revenue
    FROM orders
    GROUP BY customer_id
)
SELECT *
FROM customer_revenue
WHERE revenue > 500;
```

## Explain It (B2)

> First I create a temporary table, then I filter it.

::: {.callout-note title="Memory Hook"}
WITH creates a temporary workspace.
:::

---

# Why CTE Is Better

Instead of.

```sql
SELECT ...
```

inside another huge query,

split the problem.

Cleaner.

Easier to explain.

Interviewers appreciate readability.

---

# Subqueries

A subquery is simply

> a query inside another query.

::: {.callout-note title="Memory Hook"}
Box inside a box.
:::

---

# Question 31 — Above Average Orders

Business Task.

Find orders larger than the average.

```sql
SELECT order_id,
       amount
FROM orders
WHERE amount >
(
    SELECT AVG(amount)
    FROM orders
);
```

## Explain It (B2)

> First SQL calculates the average, then it compares every order against it.

---

# Subquery Visual

<svg viewBox="0 0 520 170" width="100%" height="170" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="30" width="460" height="110" rx="10" fill="none" stroke="currentColor" stroke-width="2"/>
  <text x="260" y="60" text-anchor="middle" font-size="18">Main Query</text>

  <rect x="150" y="75" width="220" height="45" rx="8" fill="none" stroke="currentColor" stroke-width="2"/>
  <text x="260" y="103" text-anchor="middle" font-size="16">AVG(amount)</text>
</svg>

One query feeds another.

---

# Question 32 — Products Above Average Price

```sql
SELECT product_name,
       price
FROM products
WHERE price >
(
    SELECT AVG(price)
    FROM products
);
```

Explain.

> Products become filtered using the average price.

---

# CTE vs Subquery

| CTE                   | Subquery              |
| --------------------- | --------------------- |
| Easier to read        | Shorter               |
| Reusable              | Quick calculations    |
| Better for interviews | Fine for simple tasks |

Interview Tip.

If readability matters,

choose a CTE.

---

# Business Case

Imagine this question.

> Find customers whose spending is above the company average.

Think aloud.

1. Calculate customer revenue.
2. Calculate average revenue.
3. Compare.

Interviewers score your reasoning,

not just the final SQL.

---

# Mini Mock Interview

Interviewer.

> Explain LEFT JOIN.

Pause.

Answer.

---

Interviewer.

> Why use a CTE?

Pause.

Answer.

---

Interviewer.

> Find orders above average.

Pause.

Answer.

---

# Cheat Sheet

## INNER JOIN

```sql
INNER JOIN table
ON key = key;
```

## LEFT JOIN

```sql
LEFT JOIN table
ON key = key;
```

## CTE

```sql
WITH temp AS (...)
SELECT ...
```

## Subquery

```sql
WHERE value >
(
SELECT AVG(...)
)
```

---

::: {.callout-note title="Memory Hooks Summary"}

| Concept  | Hook                |
| -------- | ------------------- |
| INNER    | Both exist          |
| LEFT     | Left keeps everyone |
| NULL     | Missing             |
| CTE      | Temporary workspace |
| Subquery | Box inside a box    |
:::

---

# End-of-Sprint Challenge

Complete these without looking.

1. Join customers and orders.
2. Show every customer using LEFT JOIN.
3. Find customers without orders.
4. Join customers, orders and payments.
5. Build a CTE.
6. Find orders above average.
7. Find products above average price.
8. Explain INNER JOIN in English.
9. Explain LEFT JOIN in English.
10. Explain why CTE improves readability.

Target.

- **15 minutes**
- explain every solution aloud in English.

Congratulations.

You have completed **SQL Sprint 3**.
{{< include ../templates/practice-callout.md >}}
