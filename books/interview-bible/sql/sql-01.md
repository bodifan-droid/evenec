# SQL Bible

# Sprint 1 — Foundations

## SELECT • WHERE • ORDER BY • LIMIT • DISTINCT

Welcome to the SQL Bible.

This book is designed for **Junior Data Analyst interviews in the UK**.

Instead of learning isolated syntax, you'll solve realistic business problems using one consistent dataset.

---

# Introducing the Evenec Retail Dataset

Throughout the SQL Bible we'll work with one fictional company.

> **Evenec Retail**

An online retail business selling products across the UK.

This makes interview practice much closer to real companies like Tesco, Amazon, Deliveroo or Wise.

## Database Structure

| Table       | Purpose                |
| ----------- | ---------------------- |
| customers   | Customer information   |
| orders      | Orders placed          |
| order_items | Products inside orders |
| products    | Product catalogue      |
| payments    | Payment information    |
| employees   | Internal staff         |

---

# Main Tables

## customers

| Column      | Type |
| ----------- | ---- |
| customer_id | INT  |
| first_name  | TEXT |
| last_name   | TEXT |
| city        | TEXT |
| signup_date | DATE |

---

## orders

| Column      | Type    |
| ----------- | ------- |
| order_id    | INT     |
| customer_id | INT     |
| order_date  | DATE    |
| amount      | DECIMAL |
| status      | TEXT    |

---

## products

| Column       | Type    |
| ------------ | ------- |
| product_id   | INT     |
| product_name | TEXT    |
| category     | TEXT    |
| price        | DECIMAL |

---

# Memory Map

Throughout this book remember:

Customer places an Order.

Order contains Items.

Items reference Products.

This simple relationship helps you understand joins later.

---

# Question 1 — Show Every Customer

## Recruiter Psychology

This tests whether you understand the most fundamental SQL operation.

## Business Task

The manager wants to see every customer.

## SQL Solution

```sql
SELECT *
FROM customers;
```

## Explain It (B2)

> This query selects every column from the customers table.

## Memory Hook

SELECT = Choose.

## Common Mistake

Using `SELECT ALL`.

`SELECT *` already returns all columns.

## Practice Challenge

Return only:

- first_name
- city

---

# Question 2 — Select Specific Columns

## Recruiter Psychology

Interviewers prefer selecting only necessary columns.

## Business Task

Display customer names and cities.

## SQL Solution

```sql
SELECT first_name,
       city
FROM customers;
```

## Explain It (B2)

> Instead of returning every column, I only select the information I need.

## Memory Hook

Only what matters.

## Common Mistake

Using `SELECT *` in every query.

---

# Question 3 — Filter London Customers

## Recruiter Psychology

This checks your ability to filter data.

## Business Task

Find customers living in London.

## SQL Solution

```sql
SELECT first_name,
       city
FROM customers
WHERE city = 'London';
```

## Explain It (B2)

> First I filter the rows where the city is London, then I return the required columns.

## Memory Hook

WHERE filters rows.

## Common Mistake

Using `=` incorrectly with text.

Always use quotes.

---

# Quick Drill

Without looking:

Write a query that finds customers from Manchester.

---

# Question 4 — Orders Above £100

## Recruiter Psychology

Numeric filtering appears constantly during interviews.

## Business Task

Show orders above £100.

## SQL Solution

```sql
SELECT order_id,
       amount
FROM orders
WHERE amount > 100;
```

## Explain It (B2)

> I filter orders where the amount is greater than one hundred.

## Memory Hook

Greater than means bigger money.

## Common Mistake

Using `>=` when the question says "above".

---

# Question 5 — Multiple Conditions

## Recruiter Psychology

Interviewers want to see logical operators.

## Business Task

Find completed orders above £200.

## SQL Solution

```sql
SELECT order_id,
       amount,
       status
FROM orders
WHERE amount > 200
  AND status = 'Completed';
```

## Explain It (B2)

> Both conditions must be true.

## Memory Hook

AND = Both.

OR = Either.

## Common Mistake

Forgetting quotes around text.

---

# Question 6 — OR Condition

## Business Task

Find customers from London or Birmingham.

## SQL Solution

```sql
SELECT first_name,
       city
FROM customers
WHERE city = 'London'
   OR city = 'Birmingham';
```

## Explain It (B2)

> Either city matches.

## Memory Hook

OR opens another door.

---

# Interview Tip

Many interviewers ask:

> "Can you explain your query?"

Always explain:

1. Filter.
2. Select.
3. Result.

---

# Question 7 — Sort Highest Revenue First

## Recruiter Psychology

Sorting is one of the most common interview tasks.

## Business Task

Show the largest orders first.

## SQL Solution

```sql
SELECT order_id,
       amount
FROM orders
ORDER BY amount DESC;
```

## Explain It (B2)

> I sort the amounts from highest to lowest.

## Memory Hook

DESC = Biggest first.

ASC = Smallest first.

## Common Mistake

Forgetting DESC.

Default sorting is ascending.

---

# Question 8 — Oldest Customers First

## Business Task

Sort customers by signup date.

## SQL Solution

```sql
SELECT first_name,
       signup_date
FROM customers
ORDER BY signup_date ASC;
```

## Explain It (B2)

> The earliest customers appear first.

---

# Question 9 — Top Five Orders

## Recruiter Psychology

LIMIT appears frequently.

## Business Task

Return only the five largest orders.

## SQL Solution

```sql
SELECT order_id,
       amount
FROM orders
ORDER BY amount DESC
LIMIT 5;
```

## Explain It (B2)

> First I sort the orders, then I return only the top five.

## Memory Hook

Sort.

Then limit.

---

# Practice Challenge

Return the top three customers alphabetically.

---

# Question 10 — Remove Duplicate Cities

## Recruiter Psychology

DISTINCT is simple but frequently tested.

## Business Task

List every city only once.

## SQL Solution

```sql
SELECT DISTINCT city
FROM customers;
```

## Explain It (B2)

> DISTINCT removes duplicate values.

## Memory Hook

DISTINCT means unique.

## Common Mistake

Using GROUP BY unnecessarily.

---

# Question 11 — Find Products in Electronics

## Business Task

Show products from the Electronics category.

## SQL Solution

```sql
SELECT product_name,
       price
FROM products
WHERE category = 'Electronics';
```

## Explain It (B2)

> I filter products by category.

---

# Question 12 — Sort Products by Price

## Business Task

Show the cheapest products first.

## SQL Solution

```sql
SELECT product_name,
       price
FROM products
ORDER BY price ASC;
```

## Explain It (B2)

> I sort products from the lowest price to the highest.

---

# SQL Interview Vocabulary

| Word   | Meaning              |
| ------ | -------------------- |
| Filter | Remove unwanted rows |
| Sort   | Change order         |
| Return | Show results         |
| Column | Vertical field       |
| Row    | Single record        |

Use these words during interviews.

---

# Mini Mock Interview

## Interviewer

> Show all customers.

Pause.

Answer.

---

## Interviewer

> Show completed orders above £200.

Pause.

Answer.

---

## Interviewer

> Return the five largest orders.

Pause.

Answer.

---

# Cheat Sheet

## SELECT

```sql
SELECT column
FROM table;
```

## WHERE

```sql
WHERE condition;
```

## ORDER BY

```sql
ORDER BY column DESC;
```

## LIMIT

```sql
LIMIT 5;
```

## DISTINCT

```sql
SELECT DISTINCT column;
```

---

# Memory Hooks Summary

| Concept  | Hook        |
| -------- | ----------- |
| SELECT   | Choose      |
| WHERE    | Filter rows |
| ORDER BY | Organise    |
| LIMIT    | Stop early  |
| DISTINCT | Unique      |

---

# End-of-Sprint Challenge

Without looking at previous examples, solve these tasks.

1. Show customers from London.
2. Show orders above £150.
3. Show completed orders.
4. Show the five largest orders.
5. List unique cities.
6. Show Electronics products sorted by price.

Target:

- under **8 minutes**
- explain every query aloud in English.

Congratulations.

You have completed **SQL Sprint 1**.
{{< include /templates/practice-callout.md >}}