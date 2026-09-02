# Power BI Interview Bible

# Sprint 4 — Power BI Assessment Centre

## 45-Minute Challenge • Executive Presentation • Mock Interview

Congratulations.

You've reached the final sprint.

Everything you've learned now comes together in one realistic hiring assessment.

Imagine you're interviewing for a **Junior Data Analyst** role in London.

The hiring manager sends one message.

> "You have 45 minutes."

This chapter simulates a real UK assessment.

No memorisation.

No perfect conditions.

Just business decisions.

---

# Assessment Overview

Time limit:

**45 minutes**

Dataset:

- Customer table
- Order table
- Product table
- Payment table
- Employee table

Deliverables.

- Clean Power BI report
- Interactive dashboard
- Business insights
- Executive presentation

Exactly what many UK companies expect.

---

# Before You Start

Before building your report, make sure your model is ready.

Check:

- Relationships
- Date formats
- Measures
- Slicers

::: {.callout-note title="Memory Hook"}
Prepare. Then analyse.
:::

---

# Assessment Scenario

The Sales Director says.

> "Our quarterly board meeting starts soon."

Your dashboard must answer.

- How much revenue did we generate?
- Which city performs best?
- Which category needs attention?
- How should we invest next quarter?

One report.

One opportunity.

Imagine presenting this report five minutes before a board meeting.

---

# Your Mission

Build a complete executive dashboard.

Required.

- Revenue KPI
- Orders KPI
- Average Order KPI
- Top City KPI
- Revenue by City
- Revenue by Category
- Monthly Trend
- Slicers
- Drill-through
- Tooltips
- Navigation

Every feature should help someone make a faster decision.

Everything should feel polished.

---

# Dashboard Blueprint

This is the target layout for your assessment.

![](assets/diagrams/executive-dashboard-preview.svg){#fig:executive-dashboard-preview width=100%}

*Figure 4.1 — Executive Dashboard Blueprint.*

Notice how executives see KPIs first, trends second and detailed analysis last.

Keep this structure while building.

---

## Assessment Mindset

Don't try to build a beautiful dashboard first.

Follow this order:

1. Model
2. Measures
3. Visuals
4. Business insight

A working dashboard with a clear recommendation is worth more than a perfect-looking report that doesn't answer business questions.

# The 45-Minute Timer

Follow this sequence.

| Time  | Task                    |
| ----- | ----------------------- |
| 0–5   | Import & Model          |
| 5–12  | Power Query Cleaning    |
| 12–20 | Measures                |
| 20–28 | Visuals                 |
| 28–35 | Slicers & Drill-through |
| 35–40 | Formatting              |
| 40–45 | Presentation Review     |

Notice.

Professionals work against the clock.

If time runs out, prioritise working KPIs and one clear recommendation over additional formatting.

---

# Assessment Task 1

## Revenue Overview

Build.

- Total Revenue
- Total Orders
- Average Order

Interview English.

> I started by creating executive KPIs because they provide an immediate overview.

Business first.

---

# Assessment Task 2

## City Performance

Question.

Which city deserves additional marketing budget?

Expected Workflow.

- Bar Chart
- Sort descending
- Explain recommendation

Avoid saying "London has the highest revenue." Instead explain why that matters.

Don't stop at numbers.

Give advice.

---

# Assessment Task 3

## Category Analysis

Question.

Which category needs attention?

Use.

- Bar Chart
- Slicer
- Drill-through

Business Answer.

> This category contributes less revenue and may require promotional support.

---

# Assessment Task 4

## Monthly Trend

Question.

Is revenue becoming stronger or weaker?

Use.

- Line Chart
- Date hierarchy
- Month analysis

Executives love trends.

Trends explain whether today's numbers are improving or declining.

---

# Assessment Task 5

## Interactive Experience

Required.

- City slicer
- Category slicer
- Date slicer
- Sync Slicers

Then test everything.

Nothing should break.

---

# Assessment Task 6

## Drill-through Page

Create.

City Details.

Include.

- Revenue
- Orders
- Category breakdown

Now executives can investigate deeper.

::: {.callout-note title="Memory Hook"}

Overview.

Then detail.
:::

---

# Assessment Task 7

## Custom Tooltips

Create a Tooltip Page.

Show.

- Revenue
- Orders
- Average Order

Now hovering becomes informative.

Professional reports use this constantly.

---

# Assessment Task 8

## Navigation

Create.

Buttons.

- Overview
- Sales
- Categories

Use Bookmarks.

Now the report feels like an application.

---

# Hiring Manager Questions

These often appear after the practical task.

---

## Question 1

Why did you use Power Query?

Model Answer.

> It creates a repeatable cleaning process instead of manual editing.

---

## Question 2

Why build relationships instead of merging everything?

Model Answer.

> A proper data model improves performance and makes reports easier to maintain.

---

## Question 3

Why create Measures instead of Calculated Columns?

Model Answer.

> Measures respond dynamically to filters, while calculated columns remain fixed after loading.

---

## Question 4

Why choose a Card visual?

Model Answer.

> Executives need immediate visibility of the most important KPIs.

---

# Recruiter Questions

These test communication.

---

## Tell me about this dashboard.

Good Answer (B2).

> This dashboard helps managers monitor sales performance by city and category. It combines interactive filters with KPIs so decisions can be made quickly.

---

## What would you improve next?

Example.

> I'd add year-over-year comparisons and customer retention metrics.

Recruiters like improvement thinking.

---

# Presentation Challenge

You now have.

**60 seconds.**

Imagine presenting to the board.

Say.

> Good morning. This dashboard gives a quick overview of our sales performance. Revenue remains strongest in London, while Electronics continues to be our best-performing category. The slicers allow managers to explore different time periods and cities without changing the report. Based on these results, I'd recommend increasing marketing investment in our strongest regions while investigating weaker categories.

Aim for a calm pace rather than speaking quickly.

This sounds natural for B2 English.

---

# Assessment Rubric

Score yourself.

| Skill             | Points |
| ----------------- | -----: |
| Import            |      5 |
| Power Query       |     10 |
| Relationships     |     10 |
| Measures          |     20 |
| Dashboard Design  |     20 |
| Interactivity     |     15 |
| Business Insights |     10 |
| Presentation      |     10 |

Total.

**100 points**

Target.

**80+**

Excellent.

**90+**

Interview ready.

---

# Recruiter Red Flags

Avoid.

❌ Too many colours.

❌ Tiny text.

❌ Broken filters.

❌ No business explanation.

❌ Reading formulas instead of explaining decisions.

❌ Too many visuals answering the same question.

Remember.

::: {.callout-tip title="Final Interview Mindset"}

Companies hire communicators.

Not formula collectors.

Every chart should answer a business question, and every recommendation should explain what happens next.
:::

---

# Final Checklist

Before submitting.

- [ ] Relationships correct.
- [ ] Measures working.
- [ ] Slicers tested.
- [ ] Drill-through working.
- [ ] Tooltips working.
- [ ] Navigation working.
- [ ] White space preserved.
- [ ] Presentation rehearsed.

Treat this checklist like a pilot before takeoff.

---

# Independent Practice

::: {.callout-tip title="Practice Like a Real Candidate"}

Rebuild this assessment from scratch using any realistic business dataset or a practice dataset provided by your interviewer.

Challenge yourself to complete the full assessment before reviewing your previous work.
:::

---

# Final Interview Mindset

Throughout this book you've learned.

| Tool     | Purpose     |
| -------- | ----------- |
| SQL      | Extract     |
| Excel    | Analyse     |
| Power BI | Communicate |

This is how real analysts work.

Not one tool.

One business problem.

Solved across multiple tools.

---

# Congratulations

You've completed:

- HR Interview Mastery
- SQL Bible
- Excel Bible
- Power BI Bible

More importantly, you've practised thinking like a Data Analyst.

You've learned how to:

- answer behavioural questions confidently;
- write SQL that solves business problems;
- build professional Excel reports;
- create executive Power BI dashboards.

Remember:

Companies don't hire people because they memorise formulas.

They hire people who turn data into decisions.

Welcome to the Evenec Interview Bible.

---

<box align=center gap=3 padding={{top:4,bottom:2}}>
  <AsyncImage query="Evenec logo blue teal checkmark" aspectRatio="3:1" maxWidth=180 maxHeight=60/>

  **Published by Evenec**

  First Edition · UK 2026
</box>
