# SQL Bible

# Sprint 2 — Aggregations

## GROUP BY • HAVING • Aggregate Functions

Congratulations.

You already know how to retrieve data.

Now you'll learn how analysts **summarise business performance**, which is exactly what hiring managers expect from a Junior Data Analyst.

---

# Why Aggregations Matter

Most business questions are not:

> Show me every order.

Instead they sound like:

- Which city generates the most revenue?
- How many customers signed up last month?
- What is the average order value?
- Which category sells best?

All of these require aggregation.

---

# Memory Map

Think of the process like making piles.

Rows become groups.

Each group gets a calculation.

Example:

| City       | Orders |
| ---------- | ------ |
| London     | 25     |
| Manchester | 18     |
| Leeds      | 9      |

Rows disappear.

Groups remain.

---

# Aggregate Functions Overview

| Function | Purpose     |
| -------- | ----------- |
| COUNT()  | Count rows  |
| SUM()    | Total value |
| AVG()    | Average     |
| MIN()    | Smallest    |
| MAX()    | Largest     |

Memory Hook:

> **Count • Sum • Average • Minimum • Maximum**

---

# Question 13 — Count All Orders

## Recruiter Psychology

Interviewers often begin with COUNT() because it's simple but essential.

## Business Task

How many orders exist?

## SQL Solution

```sql
SELECT COUNT(*) AS total_orders
FROM orders;
```

## Explain It (B2)

> COUNT returns the number of rows.

## Memory Hook

COUNT counts records.

## Common Mistake

Using `COUNT(amount)` instead of `COUNT(*)`.

---

# Question 14 — Count London Customers

## Business Task

Count customers living in London.

## SQL Solution

```sql
SELECT COUNT(*) AS london_customers
FROM customers
WHERE city = 'London';
```

## Explain It (B2)

> First I filter London customers, then I count them.

---

# Question 15 — Total Revenue

## Recruiter Psychology

Revenue questions appear constantly.

## Business Task

Calculate total sales.

## SQL Solution

```sql
SELECT SUM(amount) AS total_revenue
FROM orders;
```

## Explain It (B2)

> SUM adds every order amount together.

## Memory Hook

SUM builds money.

---

# Question 16 — Average Order Value

## Business Task

Find the average order value.

## SQL Solution

```sql
SELECT AVG(amount) AS average_order
FROM orders;
```

## Explain It (B2)

> AVG calculates the typical order value.

## Common Mistake

Confusing average with total.

---

# Question 17 — Largest Order

## Business Task

Find the highest order.

## SQL Solution

```sql
SELECT MAX(amount) AS largest_order
FROM orders;
```

## Explain It (B2)

> MAX returns the highest value.

---

# Question 18 — Smallest Order

## SQL Solution

```sql
SELECT MIN(amount) AS smallest_order
FROM orders;
```

## Explain It (B2)

> MIN finds the lowest value.

---

# Understanding GROUP BY

Imagine these rows.

| Customer | Amount |
| -------- | ------ |
| Alice    | 120    |
| Alice    | 80     |
| Bob      | 60     |

GROUP BY creates:

| Customer | Revenue |
| -------- | ------- |
| Alice    | 200     |
| Bob      | 60      |

Rows become summaries.

Memory Hook:

> GROUP BY creates piles.

---

# Question 19 — Revenue by Customer

## Recruiter Psychology

This is one of the most common interview questions.

## Business Task

Calculate revenue for each customer.

## SQL Solution

```sql
SELECT customer_id,
       SUM(amount) AS revenue
FROM orders
GROUP BY customer_id;
```

## Explain It (B2)

> I group orders by customer and calculate total revenue.

## Common Mistake

Forgetting `GROUP BY`.

---

# Question 20 — Orders by Status

## Business Task

Count completed and cancelled orders.

## SQL Solution

```sql
SELECT status,
       COUNT(*) AS orders
FROM orders
GROUP BY status;
```

## Explain It (B2)

> Every status becomes one group.

---

# Question 21 — Customers by City

## Business Task

Count customers in each city.

## SQL Solution

```sql
SELECT city,
       COUNT(*) AS customers
FROM customers
GROUP BY city;
```

## Explain It (B2)

> Each city becomes one group.

---

# GROUP BY Rule

Every selected column must be either:

- grouped
- aggregated

Example.

Correct.

```sql
SELECT city,
       COUNT(*)
FROM customers
GROUP BY city;
```

Wrong.

```sql
SELECT city,
       first_name
FROM customers
GROUP BY city;
```

Memory Hook:

> Every passenger needs a seat.

---

# Question 22 — Average Revenue by City

## Business Task

Calculate average order value by city.

## SQL Solution

```sql
SELECT city,
       AVG(amount) AS average_revenue
FROM customers
JOIN orders USING(customer_id)
GROUP BY city;
```

## Explain It (B2)

> I join customers and orders, group by city and calculate the average.

Don't worry about JOIN syntax yet.

Sprint 3 explains it fully.

---

# HAVING

WHERE filters rows.

HAVING filters groups.

Memory Hook.

> WHERE before GROUP.

> HAVING after GROUP.

---

# Question 23 — Cities with More Than Five Customers

## Recruiter Psychology

WHERE vs HAVING is a classic interview trap.

## SQL Solution

```sql
SELECT city,
       COUNT(*) AS customers
FROM customers
GROUP BY city
HAVING COUNT(*) > 5;
```

## Explain It (B2)

> I first create city groups, then remove groups with five or fewer customers.

---

# Question 24 — Customers Spending Over £500

## Business Task

Find customers whose total spending exceeds £500.

## SQL Solution

```sql
SELECT customer_id,
       SUM(amount) AS revenue
FROM orders
GROUP BY customer_id
HAVING SUM(amount) > 500;
```

## Explain It (B2)

> HAVING filters the grouped results.

---

# WHERE vs HAVING

| WHERE           | HAVING         |
| --------------- | -------------- |
| Filters rows    | Filters groups |
| Before grouping | After grouping |

Interview Tip.

If you're calculating something like SUM or COUNT,

think HAVING.

---

# Question 25 — Top Revenue Cities

## Business Task

Show cities ranked by revenue.

## SQL Solution

```sql
SELECT city,
       SUM(amount) AS revenue
FROM customers
JOIN orders USING(customer_id)
GROUP BY city
ORDER BY revenue DESC;
```

## Explain It (B2)

> I calculate revenue for every city and sort from highest to lowest.

---

# Business Case

Imagine you're interviewing at Tesco.

The hiring manager asks.

> Which city performs best?

Your answer.

1. Join customers and orders.
2. Group by city.
3. Calculate revenue.
4. Sort descending.

Notice.

You're describing thinking.

Not just SQL.

---

# Mini Mock Interview

## Interviewer

How many customers do we have?

Pause.

Answer.

---

## Interviewer

Which city has the highest revenue?

Pause.

Answer.

---

## Interviewer

Which customers spent over £500?

Pause.

Answer.

---

# Cheat Sheet

## COUNT

```sql
COUNT(*)
```

## SUM

```sql
SUM(amount)
```

## AVG

```sql
AVG(amount)
```

## GROUP BY

```sql
GROUP BY customer_id
```

## HAVING

```sql
HAVING SUM(amount) > 500
```

---

# Memory Hooks

| Concept  | Hook          |
| -------- | ------------- |
| COUNT    | Count records |
| SUM      | Build money   |
| AVG      | Typical value |
| GROUP BY | Make piles    |
| HAVING   | Filter groups |

---

# End-of-Sprint Challenge

Complete these without looking.

1. Count all customers.
2. Count London customers.
3. Calculate total revenue.
4. Find average order value.
5. Find the largest order.
6. Revenue by customer.
7. Customers by city.
8. Cities with more than five customers.
9. Customers spending over £500.
10. Top revenue cities.

Target.

- **12 minutes**
- explain every query aloud in English.

Congratulations.

You have completed **SQL Sprint 2**.