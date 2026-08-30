# Power BI Interview Bible

# Sprint 3 — Executive Dashboard

## KPI Cards • Slicers • Drill-through • Tooltips • Bookmarks

Monday.

09:00.

The Sales Director opens your dashboard.

Within ten seconds they should understand:

- How much revenue we generated.
- Which city performs best.
- Which category needs attention.
- What changed this month.

That's the purpose of executive dashboards.

We'll build this report using the **Evenec Retail Playground**.

Main files:

- customers.csv
- orders.csv
- products.csv
- payments.csv

---

# What We'll Build

By the end of this sprint you'll have:

- Executive KPI Cards
- Revenue Dashboard
- Category Analysis
- Interactive Slicers
- Drill-through Pages
- Custom Tooltips
- Navigation Buttons
- Professional Layout

This is much closer to a real company dashboard than a classroom exercise.

---

# Dashboard Preview

![](assets/diagrams/executive-dashboard-preview.svg){#fig:executive-dashboard-preview width=100%}

*Figure 3.1 — Executive Dashboard Preview.*

Keep this layout in mind while building.

### Executive Reading Order

A good dashboard guides the user's eyes naturally.

1. KPI Cards
2. Revenue Trend
3. Category Performance
4. Detailed Analysis

Executives scan before they investigate.

---

# Dashboard Design Principles

Good dashboards answer questions.

Bad dashboards display everything.

Follow these rules.

- White background.
- Dark text.
- Consistent spacing.
- Four KPI cards.
- Two main charts.
- Interactive filters.

Memory Hook.

One screen.

One story.

---

# Step 1 — Build KPI Cards

Create these measures if they don't already exist.

```DAX
Total Revenue =
SUM(Orders[amount])

Total Orders =
COUNTROWS(Orders)

Average Order =
AVERAGE(Orders[amount])
```

Create four Card visuals.

- Revenue
- Orders
- Average Order
- Top City

Arrange them across the top.

---

## How CALCULATE Changes Context

This is the biggest "aha moment" in DAX.

Instead of calculating using the current report state, **CALCULATE()** creates a new filter context before returning the result.

![](assets/diagrams/dax-context.svg){#fig:dax-context width=100%}

*Figure 2.2 — Row Context, Filter Context and Context Transition.*

### Interview Anchor

Remember this sequence:

**Row → Filter → CALCULATE**

If you can explain these three ideas clearly, you'll answer many Junior Power BI interview questions with confidence.

Exactly like executive dashboards.

---

# Top City Measure

Create.

```DAX
Top City =
VAR CityTable =
    SUMMARIZE(
        Customers,
        Customers[city],
        "Revenue", [Total Revenue]
    )
RETURN
    MAXX(
        TOPN(1, CityTable, [Revenue]),
        Customers[city]
    )
```

TOPN(1) returns the city with the highest revenue.

Business Meaning.

The dashboard always displays the strongest city.

---

# Interview Question 6

Why use Cards?

Good Answer.

> Cards allow executives to understand key metrics immediately.

Notice.

Business language.

Not technical language.

---

# Step 2 — Revenue by City

Create.

Bar Chart.

Fields.

- City
- Total Revenue

Sort.

Highest first.

Now your manager instantly sees priorities.

---

# Step 3 — Revenue by Category

Create another visual.

Rows.

Category.

Values.

Revenue.

Business Question.

Which product category deserves more investment?

Exactly the kind of question hiring managers ask.

---

# Step 4 — Date Trend

Create.

Line Chart.

Axis.

Order Date.

Values.

Total Revenue.

Now trends become visible.

Memory Hook.

Bars compare.

Lines reveal change.

---

# Step 5 — Slicers

Add.

- City
- Category
- Date

Now one click changes the entire dashboard.

Exactly what executives expect.

Interview English.

> Slicers allow users to explore the data without changing the report itself.

### Recruiter Tip

Don't overload a report with too many slicers.

Three well-chosen filters usually provide a better user experience than ten.

---

# Step 6 — Sync Slicers

Imagine multiple pages.

Users shouldn't repeat filters.

Open.

View.

Sync Slicers.

Now filters stay connected.

Professional reports use this constantly.

---

# Step 7 — Drill-through

This is one of the strongest interview features.

Business Task.

Right-click London.

Open.

City Details.

Create a new page.

Name.

`City Details`

Add.

- Revenue
- Orders
- Category breakdown

Now users can investigate deeper.

Memory Hook.

Overview.

Then detail.

---

# Step 8 — Custom Tooltips

Instead of tiny tooltips.

Create.

Tooltip Page.

Add.

- Revenue
- Orders
- Average Order

Now hovering over London reveals extra insights.

This feels premium.

---

# Step 9 — Bookmarks

Bookmarks create interactive experiences.

Example.

Buttons.

- Overview
- Sales
- Categories

Each button switches views.

Business dashboards often use this technique.

---

# Navigation Buttons

Insert.

Buttons.

Connect them to Bookmarks.

Now the report behaves like an application.

Interview Tip.

Navigation makes reports feel polished.

---

# Conditional Formatting

Highlight.

Top performers.

Example.

Green.

High revenue.

Business Purpose.

Direct attention.

Don't make users search.

---

# Business Case

The CEO asks.

> Why did revenue fall?

Workflow.

1. Filter month.
2. Compare categories.
3. Drill through.
4. Explain findings.

Good Answer.

> Revenue declined because one category underperformed while London remained stable.

Notice.

Insight.

Not description.

---

# Storytelling with Data

Don't present.

Five charts.

Present.

One story.

Example.

Revenue grew.

Electronics led.

London remained strongest.

Three sentences.

Executive ready.

---

# Mini Mock Interview

Interviewer.

> Why use Drill-through?

Pause.

Answer.

---

Interviewer.

> Why create Tooltips?

Pause.

Answer.

---

Interviewer.

> Why sync slicers?

Pause.

Answer.

---

# Executive Dashboard Checklist

Before presenting.

- [ ] KPI cards updated.
- [ ] Charts sorted.
- [ ] Slicers working.
- [ ] Drill-through tested.
- [ ] Tooltips working.
- [ ] Navigation buttons working.
- [ ] White space preserved.

Use this checklist before every interview assignment.

---

# Power BI Dashboard Cheat Sheet

| Feature       | Purpose                |
| ------------- | ---------------------- |
| Card          | Executive KPI          |
| Bar Chart     | Compare                |
| Line Chart    | Trend                  |
| Slicer        | Filter                 |
| Sync Slicers  | Cross-page filtering   |
| Tooltip       | Extra insight          |
| Bookmark      | Interactive navigation |
| Drill-through | Detailed analysis      |

Memory Hook.

Filter.

Explore.

Explain.

---

# End-of-Sprint Challenge

Build a complete Executive Dashboard.

Requirements.

- Revenue KPI
- Orders KPI
- Average Order KPI
- Top City KPI
- Revenue by City chart
- Revenue by Category chart
- Monthly Revenue trend
- City slicer
- Category slicer
- Date slicer
- Drill-through page
- Tooltip page
- Navigation buttons

Target.

**25 minutes**

Then present your dashboard in English within **60 seconds**.

---

# Presentation Script (B2)

Imagine you've just finished.

Say.

> I created an executive dashboard that shows revenue, order volume and customer performance. The KPI cards provide an immediate overview, while the slicers allow users to explore different cities and categories. I also added drill-through pages and custom tooltips to help managers investigate specific business questions without creating additional reports.

This sounds natural for a B2-level interview.

> [!TIP]
>
> **From Analyst to Storyteller**
>
> Your dashboard should answer three questions before anyone asks them:
>
> - What happened?
> - Why did it happen?
> - What should we do next?
>
> That's what turns a dashboard into a business decision.

---

# Memory Hooks

| Concept       | Hook              |
| ------------- | ----------------- |
| Card          | Immediate insight |
| Slicer        | Remote control    |
| Drill-through | Go deeper         |
| Tooltip       | Hidden insight    |
| Bookmark      | Interactive app   |
| White Space   | Professional look |

Congratulations.

You completed **Power BI Sprint 3**.