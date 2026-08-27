# Power BI Interview Bible

# Sprint 1 — Power BI Foundations

## Import • Data Model • Power Query • First Visuals

Welcome to the Power BI Interview Bible.

This isn't a button-by-button tutorial.

This chapter prepares you for **real Junior Data Analyst interviews in the UK**.

We'll continue working with the **Evenec Retail Playground**.

Main files:

- customers.csv
- orders.csv
- products.csv
- payments.csv
- employees.csv

---

# Why Companies Use Power BI

Excel explains yesterday.

Power BI monitors today.

A typical workflow looks like this.

- SQL extracts data.
- Power Query cleans it.
- Power BI models it.
- Dashboards communicate decisions.

Memory Hook.

> SQL finds.

> Excel explores.

> Power BI monitors.

---

# Interview Question 1

## Why Power BI?

Recruiter Psychology.

They're checking whether you understand business value.

Good Answer (B2).

> Power BI allows companies to combine data from multiple sources and create interactive dashboards that update automatically.

Don't say.

> It's like Excel.

Power BI is much bigger than Excel.

---

# Step 1 — Create Your First Report

Open Power BI Desktop.

Choose.

**Get Data**

Select.

**Text/CSV**

Import.

- customers.csv
- orders.csv
- products.csv
- payments.csv
- employees.csv

Congratulations.

You've created your first report.

---

# Power Query Opens Automatically

Notice.

Power Query appears before the data reaches Power BI.

Think of it as:

> the kitchen before the restaurant.

Business data rarely arrives perfectly clean.

---

# Interview Question 2

## Power Query Basics

Task.

Open `customers.csv`.

Change.

- Date format
- Text format
- Remove unnecessary columns

Why?

Cleaning should happen before analysis.

Memory Hook.

Prepare.

Then analyse.

---

# Close & Apply

After cleaning.

Click.

**Close & Apply**

Now the model updates.

Interview English.

> I prefer cleaning data in Power Query because the process is repeatable.

Recruiters like repeatable workflows.

---

# Step 2 — Build the Data Model

Open.

Model View.

You'll see multiple tables.

Now create relationships.

| From               | To                    |
| ------------------ | --------------------- |
| orders.customer_id | customers.customer_id |
| payments.order_id  | orders.order_id       |

Think back to SQL.

These are JOIN relationships.

Memory Hook.

Power BI remembers relationships.

SQL recreates them every query.

---

# Star Schema

Most companies use a Star Schema.

<svg viewBox="0 0 640 320" width="100%" height="320" xmlns="http://www.w3.org/2000/svg">
  <rect x="250" y="120" width="140" height="70" rx="12" fill="none" stroke="currentColor" stroke-width="2"/>
  <text x="320" y="160" text-anchor="middle" font-size="16">Orders</text>

  <rect x="40" y="40" width="140" height="60" rx="10" fill="none" stroke="currentColor"/>
  <text x="110" y="75" text-anchor="middle" font-size="14">Customers</text>

  <rect x="460" y="40" width="140" height="60" rx="10" fill="none" stroke="currentColor"/>
  <text x="530" y="75" text-anchor="middle" font-size="14">Products</text>

  <rect x="40" y="220" width="140" height="60" rx="10" fill="none" stroke="currentColor"/>
  <text x="110" y="255" text-anchor="middle" font-size="14">Payments</text>

  <rect x="460" y="220" width="140" height="60" rx="10" fill="none" stroke="currentColor"/>
  <text x="530" y="255" text-anchor="middle" font-size="14">Employees</text>

  <line x1="180" y1="70" x2="250" y2="140" stroke="currentColor" stroke-width="2"/>
  <line x1="460" y1="70" x2="390" y2="140" stroke="currentColor" stroke-width="2"/>
  <line x1="180" y1="250" x2="250" y2="180" stroke="currentColor" stroke-width="2"/>
  <line x1="460" y1="250" x2="390" y2="180" stroke="currentColor" stroke-width="2"/>
</svg>

Notice.

One fact table.

Several dimensions.

Exactly like professional BI systems.

---

# Interview Question 3

Why is Star Schema useful?

Good Answer.

> It makes reports easier to build and improves performance.

---

# Step 3 — Create Your First Visual

Choose.

Bar Chart.

Fields.

- City
- Revenue

Immediately.

You have business insight.

---

# Visual Types

| Visual | Best For   |
| ------ | ---------- |
| Bar    | Comparison |
| Line   | Trends     |
| Card   | KPI        |
| Table  | Details    |
| Map    | Locations  |

Memory Hook.

One question.

One visual.

---

# Step 4 — Create KPI Cards

Build.

- Total Revenue
- Total Orders
- Average Order

These become executive cards.

Exactly like Excel.

---

# Dashboard Layout

<svg viewBox="0 0 700 150" width="100%" height="150" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="35" width="150" height="70" rx="10" fill="none" stroke="currentColor"/>
  <rect x="190" y="35" width="150" height="70" rx="10" fill="none" stroke="currentColor"/>
  <rect x="360" y="35" width="150" height="70" rx="10" fill="none" stroke="currentColor"/>
  <rect x="530" y="35" width="150" height="70" rx="10" fill="none" stroke="currentColor"/>

  <text x="95" y="62" text-anchor="middle" font-size="13">Revenue</text>
  <text x="265" y="62" text-anchor="middle" font-size="13">Orders</text>
  <text x="435" y="62" text-anchor="middle" font-size="13">Average</text>
  <text x="605" y="62" text-anchor="middle" font-size="13">Top City</text>
</svg>

Keep plenty of white space.

Professional dashboards breathe.

---

# Step 5 — Add Filters

Power BI calls them.

**Slicers**

Add.

- City
- Category
- Date

Now the report becomes interactive.

Exactly what hiring managers expect.

---

# Formatting Like a Professional

Use.

- white background
- dark text
- aligned visuals
- consistent spacing

Avoid.

- rainbow colours
- 3D effects
- unnecessary borders

Business before decoration.

---

# Mini Business Case

The Sales Director asks.

> Which city deserves more marketing budget?

Workflow.

1. Filter.
2. Compare.
3. Explain.

Good Answer.

> London generated the highest revenue, so I'd recommend prioritising additional marketing there.

Notice.

Recommendation.

Not just numbers.

---

# Mini Mock Interview

Interviewer.

> Why use Power Query?

Pause.

Answer.

---

Interviewer.

> Why create relationships?

Pause.

Answer.

---

Interviewer.

> Why choose a Card visual?

Pause.

Answer.

---

# Power BI Cheat Sheet

| Tool        | Purpose       |
| ----------- | ------------- |
| Power Query | Clean         |
| Model View  | Relationships |
| Card        | KPI           |
| Bar Chart   | Compare       |
| Line Chart  | Trend         |
| Slicer      | Filter        |

Memory Hook.

Import.

Model.

Visualise.

Explain.

---

# End-of-Sprint Challenge

Using the Evenec Retail Playground.

Complete these tasks.

- Import all CSV files.
- Clean data in Power Query.
- Create relationships.
- Build three KPI cards.
- Build one revenue chart.
- Add one slicer.

Target.

**15 minutes**

Explain every action aloud in English.

Congratulations.

You completed **Power BI Sprint 1**.