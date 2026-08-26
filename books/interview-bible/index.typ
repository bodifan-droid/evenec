// Chapter-based numbering for books with appendix support
#let equation-numbering = it => {
  let pattern = if state("appendix-state", none).get() != none { "(A.1)" } else { "(1.1)" }
  numbering(pattern, counter(heading).get().first(), it)
}
#let callout-numbering = it => {
  let pattern = if state("appendix-state", none).get() != none { "A.1" } else { "1.1" }
  numbering(pattern, counter(heading).get().first(), it)
}
#let subfloat-numbering(n-super, subfloat-idx) = {
  let chapter = counter(heading).get().first()
  let pattern = if state("appendix-state", none).get() != none { "A.1a" } else { "1.1a" }
  numbering(pattern, chapter, n-super, subfloat-idx)
}
// Theorem configuration for theorion
// Chapter-based numbering (H1 = chapters)
#let theorem-inherited-levels = 1

// Appendix-aware theorem numbering
#let theorem-numbering(loc) = {
  if state("appendix-state", none).at(loc) != none { "A.1" } else { "1.1" }
}

// Theorem render function
// Note: brand-color is not available at this point in template processing
#let theorem-render(prefix: none, title: "", full-title: auto, body) = {
  block(
    width: 100%,
    inset: (left: 1em),
    stroke: (left: 2pt + black),
  )[
    #if full-title != "" and full-title != auto and full-title != none {
      strong[#full-title]
      linebreak()
    }
    #body
  ]
}
// Some definitions presupposed by pandoc's typst output.
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let fields = old_block.fields()
  let _ = fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => {
          let subfloat-idx = quartosubfloatcounter.get().first() + 1
          subfloat-numbering(n-super, subfloat-idx)
        })
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => block({
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          })

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let children = old_title_block.body.body.children
  let old_title = if children.len() == 1 {
    children.at(0)  // no icon: title at index 0
  } else {
    children.at(1)  // with icon: title at index 1
  }

  // TODO use custom separator if available
  // Use the figure's counter display which handles chapter-based numbering
  // (when numbering is a function that includes the heading counter)
  let callout_num = it.counter.display(it.numbering)
  let new_title = if empty(old_title) {
    [#kind #callout_num]
  } else {
    [#kind #callout_num: #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block,
    block_with_new_content(
      old_title_block.body,
      if children.len() == 1 {
        new_title  // no icon: just the title
      } else {
        children.at(0) + new_title  // with icon: preserve icon block + new title
      }))

  align(left, block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1)))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color,
        width: 100%,
        inset: 8pt)[#if icon != none [#text(icon_color, weight: 900)[#icon] ]#title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}


// syntax highlighting functions from skylighting:
/* Function definitions for syntax highlighting generated by skylighting: */
#let EndLine() = raw("\n")
#let Skylighting(fill: none, number: false, start: 1, sourcelines) = {
   let blocks = []
   let lnum = start - 1
   let bgcolor = rgb("#f1f3f5")
   for ln in sourcelines {
     if number {
       lnum = lnum + 1
       blocks = blocks + box(width: if start + sourcelines.len() > 999 { 30pt } else { 24pt }, text(fill: rgb("#aaaaaa"), [ #lnum ]))
     }
     blocks = blocks + ln + EndLine()
   }
   block(fill: bgcolor, width: 100%, inset: 8pt, radius: 2pt, blocks)
}
#let AlertTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let AnnotationTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let AttributeTok(s) = text(fill: rgb("#657422"),raw(s))
#let BaseNTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let BuiltInTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let CharTok(s) = text(fill: rgb("#20794d"),raw(s))
#let CommentTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let CommentVarTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))
#let ConstantTok(s) = text(fill: rgb("#8f5902"),raw(s))
#let ControlFlowTok(s) = text(weight: "bold",fill: rgb("#003b4f"),raw(s))
#let DataTypeTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let DecValTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let DocumentationTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))
#let ErrorTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let ExtensionTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let FloatTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let FunctionTok(s) = text(fill: rgb("#4758ab"),raw(s))
#let ImportTok(s) = text(fill: rgb("#00769e"),raw(s))
#let InformationTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let KeywordTok(s) = text(weight: "bold",fill: rgb("#003b4f"),raw(s))
#let NormalTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let OperatorTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let OtherTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let PreprocessorTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let RegionMarkerTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let SpecialCharTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let SpecialStringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let StringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let VariableTok(s) = text(fill: rgb("#111111"),raw(s))
#let VerbatimStringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let WarningTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))



#let article(
  title: none,
  subtitle: none,
  authors: none,
  keywords: (),
  date: none,
  abstract-title: none,
  abstract: none,
  thanks: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: none,
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: none,
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  mathfont: none,
  codefont: none,
  linestretch: 1,
  sectionnumbering: none,
  linkcolor: none,
  citecolor: none,
  filecolor: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  // Set document metadata for PDF accessibility
  set document(title: title, keywords: keywords)
  set document(
    author: authors.map(author => content-to-string(author.name)).join(", ", last: " & "),
  ) if authors != none and authors != ()
  set par(
    justify: true,
    leading: linestretch * 0.65em
  )
  set text(lang: lang,
           region: region,
           size: fontsize)
  set text(font: font) if font != none
  show math.equation: set text(font: mathfont) if mathfont != none
  show raw: set text(font: codefont) if codefont != none

  set heading(numbering: sectionnumbering)

  show link: set text(fill: rgb(content-to-string(linkcolor))) if linkcolor != none
  show ref: set text(fill: rgb(content-to-string(citecolor))) if citecolor != none
  show link: this => {
    if filecolor != none and type(this.dest) == label {
      text(this, fill: rgb(content-to-string(filecolor)))
    } else {
      text(this)
    }
   }

  let has-title-block = title != none or (authors != none and authors != ()) or date != none or abstract != none
  if has-title-block {
    place(
      top,
      float: true,
      scope: "parent",
      clearance: 4mm,
      block(below: 1em, width: 100%)[

        #if title != none {
          align(center, block(inset: 2em)[
            #set par(leading: heading-line-height) if heading-line-height != none
            #set text(font: heading-family) if heading-family != none
            #set text(weight: heading-weight)
            #set text(style: heading-style) if heading-style != "normal"
            #set text(fill: heading-color) if heading-color != black

            #text(size: title-size)[#title #if thanks != none {
              footnote(thanks, numbering: "*")
              counter(footnote).update(n => n - 1)
            }]
            #(if subtitle != none {
              parbreak()
              text(size: subtitle-size)[#subtitle]
            })
          ])
        }

        #if authors != none and authors != () {
          let count = authors.len()
          let ncols = calc.min(count, 3)
          grid(
            columns: (1fr,) * ncols,
            row-gutter: 1.5em,
            ..authors.map(author =>
                align(center)[
                  #author.name \
                  #author.affiliation \
                  #author.email
                ]
            )
          )
        }

        #if date != none {
          align(center)[#block(inset: 1em)[
            #date
          ]]
        }

        #if abstract != none {
          block(inset: 2em)[
          #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
          ]
        }
      ]
    )
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  doc
}

#set table(
  inset: 6pt,
  stroke: none
)
#import "@preview/fontawesome:0.5.0": *
#let brand-color = (:)
#let brand-color-background = (:)
#let brand-logo = (:)

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
  columns: 1,
)
// Logo is handled by orange-book's cover page, not as a page background
// NOTE: marginalia.setup is called in typst-show.typ AFTER book.with()
// to ensure marginalia's margins override the book format's default margins
#import "@preview/orange-book:0.7.1": book, part, chapter, appendices

#show: book.with(
  title: [Data Analyst Interview Bible (UK 2026)],
  subtitle: [UK Interview Edition],
  author: "Bohdan Shevchuk, ChatGPT (OpenAI)",
  date: "Invalid Date",
  main-color: brand-color.at("primary", default: blue),
  logo: {
    let logo-info = brand-logo.at("medium", default: none)
    if logo-info != none { image(logo-info.path, alt: logo-info.at("alt", default: none)) }
  },
  outline-depth: 3,
  supplement-chapter: "Chapter",
)


// Reset Quarto's custom figure counters at each chapter (level-1 heading).
// Orange-book only resets kind:image and kind:table, but Quarto uses custom kinds.
// This list is generated dynamically from crossref.categories.
#show heading.where(level: 1): it => {
  counter(figure.where(kind: "quarto-float-fig")).update(0)
  counter(figure.where(kind: "quarto-float-tbl")).update(0)
  counter(figure.where(kind: "quarto-float-lst")).update(0)
  counter(figure.where(kind: "quarto-callout-Note")).update(0)
  counter(figure.where(kind: "quarto-callout-Warning")).update(0)
  counter(figure.where(kind: "quarto-callout-Caution")).update(0)
  counter(figure.where(kind: "quarto-callout-Tip")).update(0)
  counter(figure.where(kind: "quarto-callout-Important")).update(0)
  counter(math.equation).update(0)
  it
}

= evenec
<evenec>
= Data Analyst Interview Bible (UK 2026)
<data-analyst-interview-bible-uk-2026>
== Part 1 --- HR Interview Mastery
<part-1-hr-interview-mastery>
#strong[First Edition]

#strong[Authors]

- Bohdan Shevchuk
- ChatGPT (OpenAI)

== Part 2 --- SQL Bible
<part-2-sql-bible>
This section prepares you for SQL interviews in UK companies using one consistent business dataset: #strong[Evenec Retail].

Topics include:

- SELECT & WHERE
- GROUP BY & HAVING
- JOINs
- CTEs
- Window Functions
- Business Cases
- Full Mock Interview

CC BY 4.0

= 
<section>
= 
<section-1>
#part[Part I — HR Interview Mastery]
= HR Interview Mastery
<hr-interview-mastery>
= Questions 1--15
<questions-115>
This chapter covers the first fifteen HR interview questions most commonly asked during Junior Data Analyst interviews in the United Kingdom.

The answers are written in #strong[natural B2 English] and are designed to sound confident, professional and conversational.

#horizontalrule

= How to Use This Chapter
<how-to-use-this-chapter>
Each question follows the same structure.

- #strong[Question] --- what the interviewer asks.
- #strong[Recruiter Psychology] --- what they are really evaluating.
- #strong[Model Answer] --- natural B2 English.
- #strong[Bogdan Note] --- how to adapt it to your real experience.
- #strong[Memory Hook] --- a quick phrase for remembering the structure.
- #strong[Follow-up Questions] --- what usually comes next.
- #strong[Common Mistake] --- what to avoid.

#horizontalrule

= Question 1 --- Tell me about yourself
<question-1-tell-me-about-yourself>
This is almost always the first question.

The interviewer is not asking for your life story.

They are checking whether you can introduce yourself clearly.

== Recruiter Psychology
<recruiter-psychology>
They evaluate:

- structured thinking;
- communication;
- confidence;
- career direction.

== Model Answer
<model-answer>
#quote(block: true)[
I'm currently working in a dental laboratory in London as a 3D Designer, where I work with digital workflows and attention to detail every day.

Before this role, I ran my own business in Ukraine, where I regularly worked with sales reports and customer information to make business decisions.

That experience made me interested in data analysis, so I completed the GoIT Data Analytics programme and learned SQL, Excel, Power BI and Python.

Now I'm looking for my first Junior Data Analyst role where I can combine business understanding with analytical skills.
]

#block[
#callout(
body: 
[
Use your real transition story.

Business → Dental Lab → GoIT → Data Analyst.

This makes your career change feel intentional.

]
, 
title: 
[
Bogdan Note
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]
#block[
#callout(
body: 
[
Past → Present → Future

]
, 
title: 
[
Memory Hook
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
=== Follow-up Questions
<follow-up-questions>
- Why did you change careers?
- What did you enjoy about your business?
- Why data analytics?

=== Common Mistake
<common-mistake>
Don't say:

#quote(block: true)[
"I love numbers."
]

Instead, connect your answer to real experience.

#horizontalrule

= Question 2 --- Why do you want to become a Data Analyst?
<question-2-why-do-you-want-to-become-a-data-analyst>
== Recruiter Psychology
<recruiter-psychology-1>
The interviewer wants to know whether your motivation is sustainable.

They're checking if this is a thoughtful career move rather than a temporary idea.

== Model Answer
<model-answer-1>
#quote(block: true)[
I enjoy solving business problems with data.

In my previous business I often used sales reports and customer information to make decisions.

I realised I wanted stronger technical skills, so I completed a Data Analytics programme.

Now I want to use both my business experience and analytical skills in a professional team.
]

#block[
#callout(
body: 
[
Mention business decisions instead of saying you've always loved data.

]
, 
title: 
[
Bogdan Note
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]
#block[
#callout(
body: 
[
Business → Learning → Career

]
, 
title: 
[
Memory Hook
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
=== Common Mistake
<common-mistake-1>
Don't say:

#quote(block: true)[
"Because analysts earn good salaries."
]

#horizontalrule

= Question 3 --- Why are you leaving your current job?
<question-3-why-are-you-leaving-your-current-job>
== Recruiter Psychology
<recruiter-psychology-2>
The interviewer wants to see whether you leave professionally.

They're checking for maturity rather than complaints.

== Model Answer
<model-answer-2>
#quote(block: true)[
I've learned valuable skills in my current role, especially attention to detail and digital workflows.

However, my long-term goal is to build my career in data analytics.

I'm looking for a role where I can grow professionally and use the skills I've been developing through my training.
]

#block[
#callout(
body: 
[
Positive → Growth → Future

]
, 
title: 
[
Memory Hook
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
=== Follow-up Questions
<follow-up-questions-1>
- What did you learn?
- What will you miss?

=== Common Mistake
<common-mistake-2>
Never criticise your current employer.

#horizontalrule

= Practice Break
<practice-break>
Answer these aloud.

+ Tell me about yourself.
+ Why Data Analytics?
+ Why are you leaving your current job?

Target time:

#strong[45--60 seconds each.]

#horizontalrule

= Question 4 --- Why do you want to work for our company?
<question-4-why-do-you-want-to-work-for-our-company>
== Recruiter Psychology
<recruiter-psychology-3>
This question checks whether you prepared.

A candidate who researches the company usually appears more motivated.

== Model Answer
<model-answer-3>
#quote(block: true)[
I like that your company makes decisions based on data and invests in digital improvement.

I also appreciate the opportunity to learn from experienced analysts and work on real business problems.

I'm looking for a place where I can grow while contributing from the beginning.
]

#block[
#callout(
body: 
[
Before every interview, spend five minutes checking the company's website, LinkedIn page and recent news.

]
, 
title: 
[
Bogdan Note
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]
=== Company Research Checklist
<company-research-checklist>
- Website
- LinkedIn
- News
- Products
- Values

=== Common Mistake
<common-mistake-3>
Never answer:

#quote(block: true)[
"I just need a job."
]

#horizontalrule

= Question 5 --- What are your strengths?
<question-5-what-are-your-strengths>
== Recruiter Psychology
<recruiter-psychology-4>
The interviewer wants strengths supported by evidence.

== Model Answer
<model-answer-4>
#quote(block: true)[
I'd highlight three strengths.

First, attention to detail.

Second, problem-solving.

Third, business understanding from running my own company.
]

#block[
#callout(
body: 
[
Always attach a real example to each strength.

]
, 
title: 
[
Bogdan Note
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]
=== Memory Hook
<memory-hook>
Three strengths.

=== Common Mistake
<common-mistake-4>
Listing ten strengths without examples.

#horizontalrule

= Question 6 --- What is your biggest weakness?
<question-6-what-is-your-biggest-weakness>
== Recruiter Psychology
<recruiter-psychology-5>
This isn't a trap.

They want to see self-awareness.

== Model Answer
<model-answer-5>
#quote(block: true)[
Earlier I sometimes spent too much time trying to make every detail perfect.

I've learned to balance quality with deadlines by prioritising the most important tasks first.
]

=== Good Weaknesses
<good-weaknesses>
- perfectionism
- asking for help too late
- public speaking while improving

=== Common Mistake
<common-mistake-5>
Don't use fake weaknesses like:

#quote(block: true)[
"I work too hard."
]

#horizontalrule

= Practice Break
<practice-break-1>
Ask yourself:

- Which strength has the strongest real example?
- Which weakness shows genuine improvement?

#horizontalrule

= Question 7 --- Tell me about a challenge you faced.
<question-7-tell-me-about-a-challenge-you-faced.>
== Recruiter Psychology
<recruiter-psychology-6>
This question measures problem-solving.

Use STAR.

== Model Answer
<model-answer-6>
=== Situation
<situation>
Our workflow had delays.

=== Task
<task>
Reduce processing time.

=== Action
<action>
Reviewed the workflow and improved communication.

=== Result
<result>
The process became smoother and deadlines became easier to meet.

#block[
#callout(
body: 
[
STAR

Situation → Task → Action → Result

]
, 
title: 
[
Memory Hook
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
=== Bogdan Note
<bogdan-note>
Later we'll replace this with your strongest real business example.

#horizontalrule

= Question 8 --- Tell me about a mistake you made.
<question-8-tell-me-about-a-mistake-you-made.>
== Recruiter Psychology
<recruiter-psychology-7>
Recruiters don't expect perfection.

They expect accountability.

== Model Answer
<model-answer-7>
#quote(block: true)[
In one project I focused too much on one part of the work before checking the wider process.

I realised this created unnecessary delays.

Since then I've started reviewing priorities earlier and communicating progress more regularly.
]

=== Common Mistake
<common-mistake-6>
Never blame other people.

#horizontalrule

= Question 9 --- How do you prioritise your work?
<question-9-how-do-you-prioritise-your-work>
== Recruiter Psychology
<recruiter-psychology-8>
Analysts constantly balance multiple requests.

The interviewer wants to understand your decision process.

== Model Answer
<model-answer-8>
#quote(block: true)[
I usually start by identifying deadlines and business impact.

Then I break larger tasks into smaller steps and review priorities during the day if something changes.
]

#block[
#callout(
body: 
[
Impact → Deadline → Dependencies

]
, 
title: 
[
Memory Hook
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
=== Common Mistake
<common-mistake-7>
Saying:

#quote(block: true)[
"I just do everything."
]

#horizontalrule

= Practice Break
<practice-break-2>
Answer Questions 7--9 in under #strong[90 seconds] each.

Focus on speaking naturally rather than perfectly.

#horizontalrule

= Question 10 --- Tell me about working with difficult people.
<question-10-tell-me-about-working-with-difficult-people.>
== Recruiter Psychology
<recruiter-psychology-9>
This question tests emotional intelligence.

== Model Answer
<model-answer-9>
#quote(block: true)[
I try to understand their perspective first.

Then I focus on solving the problem instead of making it personal.

Clear communication usually helps avoid misunderstandings.
]

=== Bogdan Note
<bogdan-note-1>
Use a real workplace example without criticising colleagues.

#horizontalrule

= Question 11 --- Describe teamwork.
<question-11-describe-teamwork.>
== Recruiter Psychology
<recruiter-psychology-10>
Junior analysts rarely work alone.

They're checking collaboration.

== Model Answer
<model-answer-10>
#quote(block: true)[
I enjoy working in teams because different people bring different strengths.

In my current role I regularly communicate with colleagues to make sure work moves smoothly between different stages.
]

=== Memory Hook
<memory-hook-1>
Communication → Reliability → Support.

#horizontalrule

= Question 12 --- How do you handle pressure?
<question-12-how-do-you-handle-pressure>
== Recruiter Psychology
<recruiter-psychology-11>
The interviewer wants confidence under deadlines.

== Model Answer
<model-answer-11>
#quote(block: true)[
I stay calm by breaking large tasks into smaller actions.

I also keep track of priorities so I focus on the most important work first.
]

#block[
#callout(
body: 
[
Break → Prioritise → Execute

]
, 
title: 
[
Memory Hook
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
=== Common Mistake
<common-mistake-8>
Don't pretend pressure never affects you.

#horizontalrule

= Question 13 --- Where do you see yourself in five years?
<question-13-where-do-you-see-yourself-in-five-years>
== Recruiter Psychology
<recruiter-psychology-12>
They're checking ambition without unrealistic expectations.

== Model Answer
<model-answer-12>
#quote(block: true)[
In five years I'd like to become a confident Data Analyst with strong technical skills and experience solving real business problems.

I'd also like to mentor newer colleagues as I continue developing professionally.
]

=== Common Mistake
<common-mistake-9>
Don't say:

#quote(block: true)[
"I want your manager's job."
]

#horizontalrule

= Question 14 --- Why should we hire you?
<question-14-why-should-we-hire-you>
== Recruiter Psychology
<recruiter-psychology-13>
This is your value statement.

== Model Answer
<model-answer-13>
#quote(block: true)[
I bring a combination of business experience, attention to detail and technical skills.

I've already invested time in learning SQL, Excel, Power BI and Python, and I'm motivated to continue growing while contributing to the team.
]

#block[
#callout(
body: 
[
Keep this answer around 30 seconds.

]
, 
title: 
[
Bogdan Note
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]
=== Memory Hook
<memory-hook-2>
Business + Technical + Motivation.

#horizontalrule

= Question 15 --- Do you have any questions for us?
<question-15-do-you-have-any-questions-for-us>
== Recruiter Psychology
<recruiter-psychology-14>
This is often the final impression.

Good questions show curiosity.

=== Model Answer
<model-answer-14>
#quote(block: true)[
I'd love to know what success looks like during the first three months in this role.

I'd also be interested in learning about the team's projects and development opportunities.
]

=== Five Excellent Questions
<five-excellent-questions>
- What does success look like in the first three months?
- What projects would I work on first?
- How does the team collaborate?
- What learning opportunities do junior analysts receive?
- Which tools does the team use most often?

=== Common Mistake
<common-mistake-10>
Never answer:

#quote(block: true)[
"No, I don't have any questions."
]

#horizontalrule

= Chapter Summary
<chapter-summary>
== Top Five Memory Hooks
<top-five-memory-hooks>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Concept], [Hook],),
  table.hline(),
  [Self-introduction], [Past → Present → Future],
  [STAR], [Situation → Task → Action → Result],
  [Prioritisation], [Impact → Deadline → Dependencies],
  [Pressure], [Break → Prioritise → Execute],
  [Company Research], [Website → LinkedIn → News],
)

#horizontalrule

= 5-Minute Interview Drill
<minute-interview-drill>
Set a timer.

Answer these five questions without reading your notes.

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Question], [Target],),
  table.hline(),
  [Tell me about yourself], [60 s],
  [Why Data Analytics?], [45 s],
  [Biggest strength], [30 s],
  [Biggest weakness], [45 s],
  [Why this company?], [45 s],
)
Listen to your recording afterwards.

Improve #strong[one sentence], not the whole answer.

Small improvements repeated consistently create confident interviews. \> \[!TIP\] \> #strong[Practice Before Your Interview] \> \> Before moving to the next chapter: \> \> - Answer these questions aloud in English. \> - Keep each answer between #strong[60--90 seconds]. \> - Use the STAR framework whenever possible. \> - Record yourself and listen for clarity and confidence. \> \> The goal is not to memorise answers, but to communicate naturally.

= HR Interview Mastery
<hr-interview-mastery-1>
= Questions 16--30
<questions-1630>
This chapter continues the HR interview preparation with behavioural and workplace questions that frequently appear during Junior Data Analyst interviews in the UK.

The goal is not to memorise perfect sentences but to understand how recruiters evaluate your thinking and communication.

#horizontalrule

= Question 16 --- Tell me about a time you learned something new quickly.
<question-16-tell-me-about-a-time-you-learned-something-new-quickly.>
== Recruiter Psychology
<recruiter-psychology-15>
Recruiters want evidence that you can learn new tools and adapt to change.

== Model Answer
<model-answer-15>
#quote(block: true)[
When I decided to move into data analytics, I needed to learn several new tools in a relatively short time.

I completed the GoIT Data Analytics programme, practised SQL, Excel, Power BI and Python, and built projects to apply what I learned.

That experience taught me how to organise my learning and stay consistent.
]

#block[
#callout(
body: 
[
This is one of your strongest career-transition stories.

]
, 
title: 
[
Bogdan Note
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]
#block[
#callout(
body: 
[
Learn → Practice → Apply

]
, 
title: 
[
Memory Hook
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
=== Common Mistake
<common-mistake-11>
Don't simply say:

#quote(block: true)[
"I'm a fast learner."
]

Show evidence.

#horizontalrule

= Question 17 --- Describe a time you improved a process.
<question-17-describe-a-time-you-improved-a-process.>
== Recruiter Psychology
<recruiter-psychology-16>
Analysts improve processes constantly.

Recruiters want initiative.

== Model Answer
<model-answer-16>
#quote(block: true)[
In my previous work I reviewed how tasks moved through our workflow.

I noticed unnecessary delays between steps, suggested a clearer process and improved communication.

The workflow became more organised and easier to manage.
]

=== Memory Hook
<memory-hook-3>
Observe → Improve → Result.

#horizontalrule

= Question 18 --- Tell me about a time you worked with data.
<question-18-tell-me-about-a-time-you-worked-with-data.>
== Recruiter Psychology
<recruiter-psychology-17>
Even if this isn't a formal analyst role, recruiters want transferable experience.

== Model Answer
<model-answer-17>
#quote(block: true)[
In my business I regularly reviewed sales information and customer data to understand performance.

I used that information when making decisions about products and priorities.

That experience became one of the reasons I became interested in data analytics.
]

#block[
#callout(
body: 
[
This answer connects your business experience directly to analytics.

]
, 
title: 
[
Bogdan Note
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]

#horizontalrule

= Practice Break
<practice-break-3>
Answer Questions 16--18 without reading.

Target:

- 60 seconds each.

#horizontalrule

= Question 19 --- How do you deal with repetitive tasks?
<question-19-how-do-you-deal-with-repetitive-tasks>
== Recruiter Psychology
<recruiter-psychology-18>
Data work often includes repetitive processes.

The interviewer wants discipline.

== Model Answer
<model-answer-18>
#quote(block: true)[
I try to stay focused by understanding why the task matters.

I also look for opportunities to organise my work more efficiently while maintaining accuracy.
]

=== Memory Hook
<memory-hook-4>
Purpose → Accuracy → Efficiency.

=== Common Mistake
<common-mistake-12>
Don't say repetitive work is boring.

#horizontalrule

= Question 20 --- Tell me about receiving feedback.
<question-20-tell-me-about-receiving-feedback.>
== Recruiter Psychology
<recruiter-psychology-19>
Can you accept feedback professionally?

== Model Answer
<model-answer-19>
#quote(block: true)[
I see feedback as an opportunity to improve.

In previous roles I've received suggestions that helped me become more organised and communicate more clearly.

I try to apply feedback as quickly as possible.
]

=== Memory Hook
<memory-hook-5>
Listen → Apply → Improve.

#horizontalrule

= Question 21 --- Tell me about giving feedback.
<question-21-tell-me-about-giving-feedback.>
== Recruiter Psychology
<recruiter-psychology-20>
This measures communication and professionalism.

== Model Answer
<model-answer-20>
#quote(block: true)[
I try to give feedback respectfully and focus on the work rather than the person.

I usually explain what worked well first before suggesting improvements.
]

=== Common Mistake
<common-mistake-13>
Avoid sounding confrontational.

#horizontalrule

= Question 22 --- How do you organise your work?
<question-22-how-do-you-organise-your-work>
== Recruiter Psychology
<recruiter-psychology-21>
Organisation is essential for analysts.

== Model Answer
<model-answer-21>
#quote(block: true)[
I usually start by identifying priorities and deadlines.

Then I create a simple task list and review my progress during the day.

This helps me stay organised without losing focus.
]

#block[
#callout(
body: 
[
Plan → Track → Review.

]
, 
title: 
[
Memory Hook
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]

#horizontalrule

= Practice Break
<practice-break-4>
Ask yourself:

- Which answer sounds the most natural?
- Which example feels strongest?

#horizontalrule

= Question 23 --- Tell me about a time you solved a problem.
<question-23-tell-me-about-a-time-you-solved-a-problem.>
== Recruiter Psychology
<recruiter-psychology-22>
Problem-solving is one of the core skills for analysts.

== Model Answer
<model-answer-22>
#quote(block: true)[
I once noticed that a workflow was creating unnecessary delays.

I reviewed the process, identified where communication was slowing things down and suggested a clearer approach.

The workflow became more efficient afterwards.
]

=== Memory Hook
<memory-hook-6>
Problem → Analysis → Solution → Result.

#horizontalrule

= Question 24 --- How do you stay motivated?
<question-24-how-do-you-stay-motivated>
== Recruiter Psychology
<recruiter-psychology-23>
Recruiters want consistent motivation.

== Model Answer
<model-answer-23>
#quote(block: true)[
I stay motivated when I can see progress.

I enjoy learning new skills and solving practical problems, so I like setting small goals and improving step by step.
]

=== Common Mistake
<common-mistake-14>
Don't rely only on external motivation.

#horizontalrule

= Question 25 --- What does success mean to you?
<question-25-what-does-success-mean-to-you>
== Recruiter Psychology
<recruiter-psychology-24>
The interviewer wants realistic professional values.

== Model Answer
<model-answer-24>
#quote(block: true)[
For me, success means delivering reliable work, continuing to learn and helping the team achieve good results.

I also think success includes building skills that allow me to take on greater responsibility over time.
]

=== Memory Hook
<memory-hook-7>
Reliable → Learn → Grow.

#horizontalrule

= Practice Break
<practice-break-5>
Record your answers to Questions 23--25.

Listen for:

- clarity
- pace
- confidence

#horizontalrule

= Question 26 --- Tell me about working under a deadline.
<question-26-tell-me-about-working-under-a-deadline.>
== Recruiter Psychology
<recruiter-psychology-25>
Deadlines are part of everyday analytical work.

== Model Answer
<model-answer-25>
#quote(block: true)[
When I work under deadlines, I first identify the highest-priority tasks.

Then I break the work into manageable steps and monitor my progress.

This helps me stay calm and deliver quality work.
]

=== Memory Hook
<memory-hook-8>
Prioritise → Break Down → Deliver.

#horizontalrule

= Question 27 --- Describe a situation where you took initiative.
<question-27-describe-a-situation-where-you-took-initiative.>
== Recruiter Psychology
<recruiter-psychology-26>
Recruiters want proactive people.

== Model Answer
<model-answer-26>
#quote(block: true)[
I noticed an opportunity to improve part of our workflow without being asked.

I suggested a practical change, discussed it with the team and helped implement it.

The process became smoother afterwards.
]

#block[
#callout(
body: 
[
Use examples where you solved problems instead of waiting for instructions.

]
, 
title: 
[
Bogdan Note
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]

#horizontalrule

= Question 28 --- How do you deal with uncertainty?
<question-28-how-do-you-deal-with-uncertainty>
== Recruiter Psychology
<recruiter-psychology-27>
Analysts often work with incomplete information.

== Model Answer
<model-answer-27>
#quote(block: true)[
I try to gather as much relevant information as possible before making a decision.

If something is unclear, I ask questions instead of making assumptions.

I believe good communication reduces uncertainty.
]

=== Memory Hook
<memory-hook-9>
Gather → Ask → Decide.

#horizontalrule

= Question 29 --- Describe a time you had multiple priorities.
<question-29-describe-a-time-you-had-multiple-priorities.>
== Recruiter Psychology
<recruiter-psychology-28>
This tests workload management.

== Model Answer
<model-answer-28>
#quote(block: true)[
I've had situations where several important tasks needed attention at the same time.

I reviewed deadlines, considered business impact and completed the highest-priority work first.

That helped me meet expectations without losing quality.
]

=== Common Mistake
<common-mistake-15>
Don't say you simply worked longer hours.

#horizontalrule

= Question 30 --- Why should we believe you'll succeed as a Junior Data Analyst without previous analyst experience?
<question-30-why-should-we-believe-youll-succeed-as-a-junior-data-analyst-without-previous-analyst-experience>
== Recruiter Psychology
<recruiter-psychology-29>
This is one of the most important transition questions.

Recruiters want confidence supported by evidence.

== Model Answer
<model-answer-29>
#quote(block: true)[
Although this would be my first professional Data Analyst role, I already have experience making business decisions using information, working carefully with digital workflows and learning new technical skills.

I've invested significant time in SQL, Excel, Power BI and Python, and I'm ready to continue learning while contributing to the team from day one.
]

#block[
#callout(
body: 
[
This is your strongest closing answer for career-transition interviews.

]
, 
title: 
[
Bogdan Note
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]
#block[
#callout(
body: 
[
Experience + Skills + Motivation.

]
, 
title: 
[
Memory Hook
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
=== Common Mistake
<common-mistake-16>
Never apologise for being junior.

Instead, emphasise what you already bring.

#horizontalrule

= Chapter Summary
<chapter-summary-1>
== Five Key Memory Hooks
<five-key-memory-hooks>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Concept], [Memory Hook],),
  table.hline(),
  [Learning], [Learn → Practice → Apply],
  [Organisation], [Plan → Track → Review],
  [Problem Solving], [Problem → Analysis → Solution],
  [Deadlines], [Prioritise → Break Down → Deliver],
  [Career Transition], [Experience + Skills + Motivation],
)

#horizontalrule

= 5-Minute Interview Drill
<minute-interview-drill-1>
Answer these questions without looking at your notes.

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Question], [Target],),
  table.hline(),
  [Learned something quickly], [60 s],
  [Improved a process], [60 s],
  [Worked with data], [45 s],
  [Solved a problem], [60 s],
  [Why you'll succeed as a Junior Data Analyst], [60 s],
)
Focus on speaking naturally rather than memorising every word.

Your goal is confidence, not perfection. \> \[!TIP\] \> #strong[Practice Before Your Interview] \> \> Before moving to the next chapter: \> \> - Answer these questions aloud in English. \> - Keep each answer between #strong[60--90 seconds]. \> - Use the STAR framework whenever possible. \> - Record yourself and listen for clarity and confidence. \> \> The goal is not to memorise answers, but to communicate naturally.

= HR Interview Mastery
<hr-interview-mastery-2>
= Questions 31--40
<questions-3140>
This chapter focuses on ownership, communication, adaptability and professional judgement.

These questions are common in behavioural interviews because recruiters want to understand how you think when situations become less predictable.

#horizontalrule

= Question 31 --- Tell me about a time you had to learn from failure.
<question-31-tell-me-about-a-time-you-had-to-learn-from-failure.>
== Recruiter Psychology
<recruiter-psychology-30>
The interviewer wants to see resilience.

They're looking for someone who reflects, learns and improves instead of becoming defensive.

== Model Answer
<model-answer-30>
#quote(block: true)[
One experience taught me that focusing only on immediate tasks without reviewing the bigger picture can create unnecessary delays.

I reflected on what happened, changed how I planned my work and started checking priorities earlier.

Since then I've become more organised when managing multiple responsibilities.
]

#block[
#callout(
body: 
[
Focus on the lesson rather than the failure itself.

]
, 
title: 
[
Bogdan Note
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]
#block[
#callout(
body: 
[
Reflect → Adjust → Improve.

]
, 
title: 
[
Memory Hook
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
=== Common Mistake
<common-mistake-17>
Don't choose a failure that makes you sound careless or irresponsible.

#horizontalrule

= Question 32 --- Describe a time you had to explain something complicated.
<question-32-describe-a-time-you-had-to-explain-something-complicated.>
== Recruiter Psychology
<recruiter-psychology-31>
Analysts often explain technical information to non-technical people.

Communication matters as much as technical knowledge.

== Model Answer
<model-answer-31>
#quote(block: true)[
I try to explain complex ideas using simple language and practical examples.

I usually avoid unnecessary technical terms and check whether the other person understands before continuing.

Clear communication helps everyone make better decisions.
]

=== Memory Hook
<memory-hook-10>
Simple → Example → Confirm.

=== Follow-up Questions
<follow-up-questions-2>
- How do you know someone understands?
- Can you give an example?

#horizontalrule

= Question 33 --- How do you handle changing priorities?
<question-33-how-do-you-handle-changing-priorities>
== Recruiter Psychology
<recruiter-psychology-32>
Business priorities change constantly.

They're checking flexibility.

== Model Answer
<model-answer-32>
#quote(block: true)[
When priorities change, I first understand what has become most important for the business.

Then I reorganise my tasks and communicate if timelines need to change.

Staying flexible helps me deliver the most valuable work first.
]

#block[
#callout(
body: 
[
Understand → Reorganise → Communicate.

]
, 
title: 
[
Memory Hook
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
=== Common Mistake
<common-mistake-18>
Don't say changing priorities frustrates you.

#horizontalrule

= Practice Break
<practice-break-6>
Answer Questions 31--33.

Focus on speaking naturally.

Target:

- 60 seconds each.

#horizontalrule

= Question 34 --- Tell me about a time you had to make a difficult decision.
<question-34-tell-me-about-a-time-you-had-to-make-a-difficult-decision.>
== Recruiter Psychology
<recruiter-psychology-33>
They're evaluating judgement.

== Model Answer
<model-answer-33>
#quote(block: true)[
I've had situations where I needed to balance several competing priorities.

I gathered the available information, considered the potential impact and made the decision that best supported the overall goal.

Afterwards I reviewed the outcome so I could learn from the experience.
]

=== Memory Hook
<memory-hook-11>
Gather → Decide → Review.

#horizontalrule

= Question 35 --- What would you do if you didn't know the answer?
<question-35-what-would-you-do-if-you-didnt-know-the-answer>
== Recruiter Psychology
<recruiter-psychology-34>
This is an honesty test.

Good analysts don't pretend to know everything.

== Model Answer
<model-answer-34>
#quote(block: true)[
If I didn't know the answer, I'd first research the problem using available resources.

If I still needed help, I'd ask a colleague while explaining what I'd already tried.

I believe learning efficiently is more important than pretending to know everything.
]

#block[
#callout(
body: 
[
This answer shows independence before asking for help.

]
, 
title: 
[
Bogdan Note
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]
=== Common Mistake
<common-mistake-19>
Never say you'd guess.

#horizontalrule

= Question 36 --- Tell me about a time you worked independently.
<question-36-tell-me-about-a-time-you-worked-independently.>
== Recruiter Psychology
<recruiter-psychology-35>
Junior analysts need supervision, but they also need initiative.

== Model Answer
<model-answer-35>
#quote(block: true)[
In previous roles I've managed responsibilities independently by planning my work and tracking my progress.

When necessary, I communicated updates and asked questions early rather than waiting until problems became bigger.

That helped me stay responsible while working efficiently.
]

=== Memory Hook
<memory-hook-12>
Plan → Execute → Update.

#horizontalrule

= Practice Break
<practice-break-7>
Record yourself answering Questions 34--36.

Listen for:

- confidence
- clarity
- pace

#horizontalrule

= Question 37 --- Describe a situation where you had to be very accurate.
<question-37-describe-a-situation-where-you-had-to-be-very-accurate.>
== Recruiter Psychology
<recruiter-psychology-36>
Accuracy is one of the most important qualities for analysts.

== Model Answer
<model-answer-36>
#quote(block: true)[
In my current work, accuracy is essential because small mistakes can affect later stages of the process.

I developed habits like double-checking important details and following consistent workflows.

Those habits are directly relevant to analytical work.
]

#block[
#callout(
body: 
[
This is a great opportunity to reference your dental laboratory experience.

]
, 
title: 
[
Bogdan Note
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]
#block[
#callout(
body: 
[
Check → Verify → Deliver.

]
, 
title: 
[
Memory Hook
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
=== Common Mistake
<common-mistake-20>
Don't simply say you're detail-oriented.

Explain how you ensure accuracy.

#horizontalrule

= Question 38 --- How do you react when someone disagrees with you?
<question-38-how-do-you-react-when-someone-disagrees-with-you>
== Recruiter Psychology
<recruiter-psychology-37>
Conflict management matters.

They're looking for professionalism.

== Model Answer
<model-answer-37>
#quote(block: true)[
I try to understand why the other person sees the situation differently.

Then I focus on discussing facts rather than personalities.

Even if we disagree, I believe respectful communication usually leads to better decisions.
]

=== Memory Hook
<memory-hook-13>
Listen → Understand → Discuss Facts.

#horizontalrule

= Question 39 --- Tell me about a goal you achieved.
<question-39-tell-me-about-a-goal-you-achieved.>
== Recruiter Psychology
<recruiter-psychology-38>
They want evidence that you finish what you start.

== Model Answer
<model-answer-38>
#quote(block: true)[
One goal I achieved was successfully completing my transition toward data analytics.

I balanced work with learning SQL, Excel, Power BI and Python while completing practical projects.

That experience showed me the importance of consistency over time.
]

#block[
#callout(
body: 
[
Use your career transition as a personal achievement.

]
, 
title: 
[
Bogdan Note
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]
=== Common Mistake
<common-mistake-21>
Choose a goal with a measurable result whenever possible.

#horizontalrule

= Question 40 --- Why should we choose you over another candidate?
<question-40-why-should-we-choose-you-over-another-candidate>
== Recruiter Psychology
<recruiter-psychology-39>
This is your positioning statement.

They're asking what makes you different.

== Model Answer
<model-answer-39>
#quote(block: true)[
I believe I offer a valuable combination of business experience, technical learning and a strong willingness to grow.

I've already demonstrated that I can learn new skills, adapt to change and work carefully with detailed processes.

I'm ready to bring that mindset into my first Junior Data Analyst role.
]

#block[
#callout(
body: 
[
Business + Learning + Reliability.

]
, 
title: 
[
Memory Hook
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
=== Common Mistake
<common-mistake-22>
Don't compare yourself negatively with other candidates.

Focus on your own value.

#horizontalrule

= Chapter Summary
<chapter-summary-2>
== Five Key Memory Hooks
<five-key-memory-hooks-1>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Concept], [Memory Hook],),
  table.hline(),
  [Learning from failure], [Reflect → Adjust → Improve],
  [Explaining complexity], [Simple → Example → Confirm],
  [Changing priorities], [Understand → Reorganise → Communicate],
  [Decision making], [Gather → Decide → Review],
  [Accuracy], [Check → Verify → Deliver],
)

#horizontalrule

= STAR Practice
<star-practice>
Complete these prompts using the STAR framework.

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Prompt], [Time],),
  table.hline(),
  [Learned from failure], [90 s],
  [Explained something complicated], [90 s],
  [Worked independently], [90 s],
  [Achieved a goal], [90 s],
)
Remember:

- Situation
- Task
- Action
- Result

#horizontalrule

= End-of-Chapter Reflection
<end-of-chapter-reflection>
Ask yourself these questions.

- Which answer sounds most natural?
- Which story feels strongest?
- Which answer still sounds memorised?
- Which example could become more specific?

Your goal is not perfect English.

Your goal is sounding like a confident future colleague. \> \[!TIP\] \> #strong[Practice Before Your Interview] \> \> Before moving to the next chapter: \> \> - Answer these questions aloud in English. \> - Keep each answer between #strong[60--90 seconds]. \> - Use the STAR framework whenever possible. \> - Record yourself and listen for clarity and confidence. \> \> The goal is not to memorise answers, but to communicate naturally.

= HR Interview Mastery
<hr-interview-mastery-3>
= Questions 41--50
<questions-4150>
This final chapter completes the HR Interview Mastery section with advanced behavioural questions, salary negotiation strategies for the UK market, recruiter red flags, a realistic mock interview and practical checklists.

The goal is to help you finish an interview with confidence.

#horizontalrule

= Question 41 --- Tell me about a time you disagreed with a decision.
<question-41-tell-me-about-a-time-you-disagreed-with-a-decision.>
== Recruiter Psychology
<recruiter-psychology-40>
They're checking whether you can disagree professionally.

== Model Answer
<model-answer-40>
#quote(block: true)[
I try to understand the reasoning behind a decision before reacting.

If I have concerns, I explain them respectfully and focus on facts rather than emotions.

Even when a different decision is made, I continue supporting the team's goal.
]

#block[
#callout(
body: 
[
Listen → Explain → Support.

]
, 
title: 
[
Memory Hook
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
=== Common Mistake
<common-mistake-23>
Don't describe yourself as someone who always argues.

#horizontalrule

= Question 42 --- Tell me about adapting to change.
<question-42-tell-me-about-adapting-to-change.>
== Recruiter Psychology
<recruiter-psychology-41>
Analysts work in changing environments.

== Model Answer
<model-answer-41>
#quote(block: true)[
I've experienced several major changes during my career, including moving to London and changing careers into data analytics.

Those experiences taught me how to learn quickly and stay flexible while continuing to work toward long-term goals.
]

#block[
#callout(
body: 
[
Your move to London is a strong real-life example of adaptability.

]
, 
title: 
[
Bogdan Note
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]
=== Memory Hook
<memory-hook-14>
Adapt → Learn → Grow.

#horizontalrule

= Question 43 --- How do you handle constructive criticism?
<question-43-how-do-you-handle-constructive-criticism>
== Recruiter Psychology
<recruiter-psychology-42>
They're evaluating coachability.

== Model Answer
<model-answer-42>
#quote(block: true)[
I appreciate constructive feedback because it helps me improve.

I try to understand the suggestion, apply it in my work and review whether the change produces better results.
]

=== Memory Hook
<memory-hook-15>
Listen → Apply → Improve.

#horizontalrule

= Practice Break
<practice-break-8>
Answer Questions 41--43.

Target:

- 45--60 seconds each.

#horizontalrule

= Question 44 --- Describe a situation where you helped someone.
<question-44-describe-a-situation-where-you-helped-someone.>
== Recruiter Psychology
<recruiter-psychology-43>
They're checking collaboration.

== Model Answer
<model-answer-43>
#quote(block: true)[
I enjoy helping colleagues when I can.

Sometimes sharing knowledge or explaining a process saves time for the whole team.

I believe teamwork becomes stronger when people support each other.
]

=== Common Mistake
<common-mistake-24>
Don't make yourself sound like the only person who solves problems.

#horizontalrule

= Question 45 --- How do you stay organised when learning new skills?
<question-45-how-do-you-stay-organised-when-learning-new-skills>
== Recruiter Psychology
<recruiter-psychology-44>
Junior analysts learn constantly.

== Model Answer
<model-answer-44>
#quote(block: true)[
I usually divide large topics into smaller learning goals.

Then I practise regularly and apply what I've learned through real exercises or projects.

That approach helped me learn SQL, Excel, Power BI and Python.
]

#block[
#callout(
body: 
[
Small Goals → Practice → Projects.

]
, 
title: 
[
Memory Hook
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]

#horizontalrule

= Question 46 --- Tell me about making a decision with limited information.
<question-46-tell-me-about-making-a-decision-with-limited-information.>
== Recruiter Psychology
<recruiter-psychology-45>
Real business decisions rarely have perfect information.

== Model Answer
<model-answer-45>
#quote(block: true)[
When information is limited, I collect the most relevant facts available and avoid making unnecessary assumptions.

If needed, I ask questions to reduce uncertainty before deciding.

My goal is making the most informed decision possible.
]

=== Memory Hook
<memory-hook-16>
Gather → Clarify → Decide.

#horizontalrule

= Practice Break
<practice-break-9>
Ask yourself:

- Which answer feels most natural?
- Which example sounds strongest?

#horizontalrule

= Question 47 --- What motivates you to keep learning?
<question-47-what-motivates-you-to-keep-learning>
== Recruiter Psychology
<recruiter-psychology-46>
They want long-term learners.

== Model Answer
<model-answer-46>
#quote(block: true)[
I enjoy seeing measurable progress.

Learning new skills becomes more motivating when I can immediately apply them to practical problems.

That's one reason I enjoy data analytics.
]

=== Memory Hook
<memory-hook-17>
Progress → Application → Motivation.

#horizontalrule

= Question 48 --- Describe a time you worked carefully with details.
<question-48-describe-a-time-you-worked-carefully-with-details.>
== Recruiter Psychology
<recruiter-psychology-47>
Accuracy is critical.

== Model Answer
<model-answer-47>
#quote(block: true)[
In my current work, small details can affect later stages of production.

I developed habits like checking important details twice and following consistent workflows.

Those habits are directly relevant to analytical work.
]

#block[
#callout(
body: 
[
Your dental laboratory experience is one of your strongest proof points.

]
, 
title: 
[
Bogdan Note
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]
=== Memory Hook
<memory-hook-18>
Check → Verify → Deliver.

#horizontalrule

= Question 49 --- What would your previous colleagues say about you?
<question-49-what-would-your-previous-colleagues-say-about-you>
== Recruiter Psychology
<recruiter-psychology-48>
They're checking self-awareness.

== Model Answer
<model-answer-48>
#quote(block: true)[
I think they'd describe me as reliable, organised and willing to help.

I'd also hope they'd say I'm someone who learns quickly and stays calm when solving problems.
]

=== Common Mistake
<common-mistake-25>
Don't exaggerate.

Keep it believable.

#horizontalrule

= Question 50 --- Is there anything else you'd like us to know?
<question-50-is-there-anything-else-youd-like-us-to-know>
== Recruiter Psychology
<recruiter-psychology-49>
This is your final opportunity.

Finish confidently.

== Model Answer
<model-answer-49>
#quote(block: true)[
I'd like you to know that I'm genuinely committed to building my career in data analytics.

I've already invested significant time in developing technical skills while gaining valuable experience in business and digital workflows.

I'm excited about contributing to a team where I can continue learning and creating value.
]

#block[
#callout(
body: 
[
Commitment → Skills → Value.

]
, 
title: 
[
Memory Hook
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
=== Final Impression Tip
<final-impression-tip>
End with confidence.

Pause.

Smile.

#horizontalrule

= Chapter Summary
<chapter-summary-3>
== Five Final Memory Hooks
<five-final-memory-hooks>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Concept], [Memory Hook],),
  table.hline(),
  [Disagreement], [Listen → Explain → Support],
  [Adaptability], [Adapt → Learn → Grow],
  [Learning], [Small Goals → Practice → Projects],
  [Accuracy], [Check → Verify → Deliver],
  [Final Answer], [Commitment → Skills → Value],
)

#horizontalrule

= Salary Negotiation (UK £35--45k)
<salary-negotiation-uk-3545k>
For your situation, salary negotiation is especially important because you're targeting London.

== When should you discuss salary?
<when-should-you-discuss-salary>
The safest order is:

+ HR screening.
+ Technical interview.
+ Final discussion.
+ Salary conversation.

Avoid becoming the first person to mention a number unless asked directly.

#horizontalrule

== If HR asks first
<if-hr-asks-first>
#quote(block: true)[
What salary are you expecting?
]

=== Best Answer (B2)
<best-answer-b2>
#quote(block: true)[
Based on my research and the responsibilities of this role, I'm looking for something in the region of #strong[£35,000 to £45,000], depending on the overall package and growth opportunities.
]

Why this works:

- sounds flexible;
- gives a range;
- avoids sounding demanding.

#horizontalrule

== If they offer £32,000
<if-they-offer-32000>
Don't reject immediately.

=== Good Response
<good-response>
#quote(block: true)[
Thank you for the offer.

I appreciate it.

Based on my research and my skills, I was expecting something closer to #strong[£35,000].

Is there any flexibility?
]

Professional.

Calm.

Confident.

#horizontalrule

== If they ask for your minimum salary
<if-they-ask-for-your-minimum-salary>
Don't say:

#quote(block: true)[
"I'll take anything."
]

Instead:

#quote(block: true)[
I'm looking for a package that reflects the responsibilities of the role, ideally starting around #strong[£35,000].
]

#horizontalrule

== Salary Negotiation Checklist
<salary-negotiation-checklist>
- Stay calm.
- Pause before answering.
- Give a range.
- Mention market research.
- Stay professional.

#horizontalrule

= Recruiter Red Flags
<recruiter-red-flags>
Sometimes interviews reveal problems about the employer.

== Green Flags
<green-flags>
- Clear role expectations.
- Friendly communication.
- Learning opportunities.
- Structured interview.
- Honest answers.

== Yellow Flags
<yellow-flags>
- Unclear responsibilities.
- Frequent interruptions.
- Constantly changing answers.

Ask more questions.

== Red Flags
<red-flags>
- Nobody can explain the role.
- Unrealistic workload.
- Pressure to accept immediately.
- Negative comments about previous employees.
- No onboarding plan.

Remember:

You're interviewing the company too.

#horizontalrule

= Mini Mock Interview
<mini-mock-interview>
Practice without reading.

== Interview Starts
<interview-starts>
#strong[Interviewer]

#quote(block: true)[
Tell me about yourself.
]

\(Pause.)

Answer.

#horizontalrule

#strong[Interviewer]

#quote(block: true)[
Why Data Analytics?
]

\(Pause.)

Answer.

#horizontalrule

#strong[Interviewer]

#quote(block: true)[
Tell me about a challenge you solved.
]

\(Pause.)

Answer.

#horizontalrule

#strong[Interviewer]

#quote(block: true)[
Why should we hire you?
]

\(Pause.)

Answer.

#horizontalrule

#strong[Interviewer]

#quote(block: true)[
Do you have any questions for us?
]

\(Pause.)

Answer.

#horizontalrule

= Self-Evaluation
<self-evaluation>
Score yourself.

#table(
  columns: 2,
  align: (auto,right,),
  table.header([Skill], [Score],),
  table.hline(),
  [Confidence], [1--5],
  [Clarity], [1--5],
  [Structure], [1--5],
  [Natural English], [1--5],
  [Examples], [1--5],
)
Total:

\_\_/25

Repeat until you consistently score above #strong[20].

#horizontalrule

= Final Interview Checklist
<final-interview-checklist>
== The Day Before
<the-day-before>
- Research the company.
- Review your CV.
- Practise five key answers.
- Prepare questions.
- Charge your laptop.
- Check your internet.

== One Hour Before
<one-hour-before>
- Open the meeting link.
- Prepare water.
- Close distractions.
- Keep notes nearby.

== During the Interview
<during-the-interview>
- Smile.
- Speak slowly.
- Pause before answering.
- Use STAR.
- Ask questions.

== After the Interview
<after-the-interview>
Within 24 hours, send a short thank-you message.

Example:

#quote(block: true)[
Thank you for your time today.

I enjoyed learning more about the role and the team.

I appreciate the opportunity and look forward to hearing from you.
]

Professional.

Simple.

Effective.

#horizontalrule

= Part 1 Complete
<part-1-complete>
Congratulations.

You have now completed #strong[HR Interview Mastery].

Before moving to the SQL Bible, make sure you can confidently answer all #strong[50 questions] without memorising every word.

The goal is sounding like a future colleague---not sounding like you've memorised a script. \> \[!TIP\] \> #strong[Practice Before Your Interview] \> \> Before moving to the next chapter: \> \> - Answer these questions aloud in English. \> - Keep each answer between #strong[60--90 seconds]. \> - Use the STAR framework whenever possible. \> - Record yourself and listen for clarity and confidence. \> \> The goal is not to memorise answers, but to communicate naturally.

#part[Part II — SQL Bible]
= SQL Bible
<sql-bible>
= Sprint 1 --- Foundations
<sprint-1-foundations>
== SELECT • WHERE • ORDER BY • LIMIT • DISTINCT
<select-where-order-by-limit-distinct>
Welcome to the SQL Bible.

This book is designed for #strong[Junior Data Analyst interviews in the UK].

Instead of learning isolated syntax, you'll solve realistic business problems using one consistent dataset.

#horizontalrule

= Introducing the Evenec Retail Dataset
<introducing-the-evenec-retail-dataset>
Throughout the SQL Bible we'll work with one fictional company.

#quote(block: true)[
#strong[Evenec Retail]
]

An online retail business selling products across the UK.

This makes interview practice much closer to real companies like Tesco, Amazon, Deliveroo or Wise.

== Database Structure
<database-structure>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Table], [Purpose],),
  table.hline(),
  [customers], [Customer information],
  [orders], [Orders placed],
  [order\_items], [Products inside orders],
  [products], [Product catalogue],
  [payments], [Payment information],
  [employees], [Internal staff],
)

#horizontalrule

= Main Tables
<main-tables>
== customers
<customers>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Column], [Type],),
  table.hline(),
  [customer\_id], [INT],
  [first\_name], [TEXT],
  [last\_name], [TEXT],
  [city], [TEXT],
  [signup\_date], [DATE],
)

#horizontalrule

== orders
<orders>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Column], [Type],),
  table.hline(),
  [order\_id], [INT],
  [customer\_id], [INT],
  [order\_date], [DATE],
  [amount], [DECIMAL],
  [status], [TEXT],
)

#horizontalrule

== products
<products>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Column], [Type],),
  table.hline(),
  [product\_id], [INT],
  [product\_name], [TEXT],
  [category], [TEXT],
  [price], [DECIMAL],
)

#horizontalrule

= Memory Map
<memory-map>
Throughout this book remember:

Customer places an Order.

Order contains Items.

Items reference Products.

This simple relationship helps you understand joins later.

#horizontalrule

= Question 1 --- Show Every Customer
<question-1-show-every-customer>
== Recruiter Psychology
<recruiter-psychology-50>
This tests whether you understand the most fundamental SQL operation.

== Business Task
<business-task>
The manager wants to see every customer.

== SQL Solution
<sql-solution>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" ");#OperatorTok("*");],
[#KeywordTok("FROM");#NormalTok(" customers;");],));
== Explain It (B2)
<explain-it-b2>
#quote(block: true)[
This query selects every column from the customers table.
]

== Memory Hook
<memory-hook-19>
SELECT = Choose.

== Common Mistake
<common-mistake-26>
Using #NormalTok("SELECT ALL");.

#NormalTok("SELECT *"); already returns all columns.

== Practice Challenge
<practice-challenge>
Return only:

- first\_name
- city

#horizontalrule

= Question 2 --- Select Specific Columns
<question-2-select-specific-columns>
== Recruiter Psychology
<recruiter-psychology-51>
Interviewers prefer selecting only necessary columns.

== Business Task
<business-task-1>
Display customer names and cities.

== SQL Solution
<sql-solution-1>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" first_name,");],
[#NormalTok("       city");],
[#KeywordTok("FROM");#NormalTok(" customers;");],));
== Explain It (B2)
<explain-it-b2-1>
#quote(block: true)[
Instead of returning every column, I only select the information I need.
]

== Memory Hook
<memory-hook-20>
Only what matters.

== Common Mistake
<common-mistake-27>
Using #NormalTok("SELECT *"); in every query.

#horizontalrule

= Question 3 --- Filter London Customers
<question-3-filter-london-customers>
== Recruiter Psychology
<recruiter-psychology-52>
This checks your ability to filter data.

== Business Task
<business-task-2>
Find customers living in London.

== SQL Solution
<sql-solution-2>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" first_name,");],
[#NormalTok("       city");],
[#KeywordTok("FROM");#NormalTok(" customers");],
[#KeywordTok("WHERE");#NormalTok(" city ");#OperatorTok("=");#NormalTok(" ");#StringTok("'London'");#NormalTok(";");],));
== Explain It (B2)
<explain-it-b2-2>
#quote(block: true)[
First I filter the rows where the city is London, then I return the required columns.
]

== Memory Hook
<memory-hook-21>
WHERE filters rows.

== Common Mistake
<common-mistake-28>
Using #NormalTok("="); incorrectly with text.

Always use quotes.

#horizontalrule

= Quick Drill
<quick-drill>
Without looking:

Write a query that finds customers from Manchester.

#horizontalrule

= Question 4 --- Orders Above £100
<question-4-orders-above-100>
== Recruiter Psychology
<recruiter-psychology-53>
Numeric filtering appears constantly during interviews.

== Business Task
<business-task-3>
Show orders above £100.

== SQL Solution
<sql-solution-3>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" order_id,");],
[#NormalTok("       amount");],
[#KeywordTok("FROM");#NormalTok(" orders");],
[#KeywordTok("WHERE");#NormalTok(" amount ");#OperatorTok(">");#NormalTok(" ");#DecValTok("100");#NormalTok(";");],));
== Explain It (B2)
<explain-it-b2-3>
#quote(block: true)[
I filter orders where the amount is greater than one hundred.
]

== Memory Hook
<memory-hook-22>
Greater than means bigger money.

== Common Mistake
<common-mistake-29>
Using #NormalTok(">="); when the question says "above".

#horizontalrule

= Question 5 --- Multiple Conditions
<question-5-multiple-conditions>
== Recruiter Psychology
<recruiter-psychology-54>
Interviewers want to see logical operators.

== Business Task
<business-task-4>
Find completed orders above £200.

== SQL Solution
<sql-solution-4>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" order_id,");],
[#NormalTok("       amount,");],
[#NormalTok("       status");],
[#KeywordTok("FROM");#NormalTok(" orders");],
[#KeywordTok("WHERE");#NormalTok(" amount ");#OperatorTok(">");#NormalTok(" ");#DecValTok("200");],
[#NormalTok("  ");#KeywordTok("AND");#NormalTok(" status ");#OperatorTok("=");#NormalTok(" ");#StringTok("'Completed'");#NormalTok(";");],));
== Explain It (B2)
<explain-it-b2-4>
#quote(block: true)[
Both conditions must be true.
]

== Memory Hook
<memory-hook-23>
AND = Both.

OR = Either.

== Common Mistake
<common-mistake-30>
Forgetting quotes around text.

#horizontalrule

= Question 6 --- OR Condition
<question-6-or-condition>
== Business Task
<business-task-5>
Find customers from London or Birmingham.

== SQL Solution
<sql-solution-5>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" first_name,");],
[#NormalTok("       city");],
[#KeywordTok("FROM");#NormalTok(" customers");],
[#KeywordTok("WHERE");#NormalTok(" city ");#OperatorTok("=");#NormalTok(" ");#StringTok("'London'");],
[#NormalTok("   ");#KeywordTok("OR");#NormalTok(" city ");#OperatorTok("=");#NormalTok(" ");#StringTok("'Birmingham'");#NormalTok(";");],));
== Explain It (B2)
<explain-it-b2-5>
#quote(block: true)[
Either city matches.
]

== Memory Hook
<memory-hook-24>
OR opens another door.

#horizontalrule

= Interview Tip
<interview-tip>
Many interviewers ask:

#quote(block: true)[
"Can you explain your query?"
]

Always explain:

+ Filter.
+ Select.
+ Result.

#horizontalrule

= Question 7 --- Sort Highest Revenue First
<question-7-sort-highest-revenue-first>
== Recruiter Psychology
<recruiter-psychology-55>
Sorting is one of the most common interview tasks.

== Business Task
<business-task-6>
Show the largest orders first.

== SQL Solution
<sql-solution-6>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" order_id,");],
[#NormalTok("       amount");],
[#KeywordTok("FROM");#NormalTok(" orders");],
[#KeywordTok("ORDER");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" amount ");#KeywordTok("DESC");#NormalTok(";");],));
== Explain It (B2)
<explain-it-b2-6>
#quote(block: true)[
I sort the amounts from highest to lowest.
]

== Memory Hook
<memory-hook-25>
DESC = Biggest first.

ASC = Smallest first.

== Common Mistake
<common-mistake-31>
Forgetting DESC.

Default sorting is ascending.

#horizontalrule

= Question 8 --- Oldest Customers First
<question-8-oldest-customers-first>
== Business Task
<business-task-7>
Sort customers by signup date.

== SQL Solution
<sql-solution-7>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" first_name,");],
[#NormalTok("       signup_date");],
[#KeywordTok("FROM");#NormalTok(" customers");],
[#KeywordTok("ORDER");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" signup_date ");#KeywordTok("ASC");#NormalTok(";");],));
== Explain It (B2)
<explain-it-b2-7>
#quote(block: true)[
The earliest customers appear first.
]

#horizontalrule

= Question 9 --- Top Five Orders
<question-9-top-five-orders>
== Recruiter Psychology
<recruiter-psychology-56>
LIMIT appears frequently.

== Business Task
<business-task-8>
Return only the five largest orders.

== SQL Solution
<sql-solution-8>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" order_id,");],
[#NormalTok("       amount");],
[#KeywordTok("FROM");#NormalTok(" orders");],
[#KeywordTok("ORDER");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" amount ");#KeywordTok("DESC");],
[#KeywordTok("LIMIT");#NormalTok(" ");#DecValTok("5");#NormalTok(";");],));
== Explain It (B2)
<explain-it-b2-8>
#quote(block: true)[
First I sort the orders, then I return only the top five.
]

== Memory Hook
<memory-hook-26>
Sort.

Then limit.

#horizontalrule

= Practice Challenge
<practice-challenge-1>
Return the top three customers alphabetically.

#horizontalrule

= Question 10 --- Remove Duplicate Cities
<question-10-remove-duplicate-cities>
== Recruiter Psychology
<recruiter-psychology-57>
DISTINCT is simple but frequently tested.

== Business Task
<business-task-9>
List every city only once.

== SQL Solution
<sql-solution-9>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" ");#KeywordTok("DISTINCT");#NormalTok(" city");],
[#KeywordTok("FROM");#NormalTok(" customers;");],));
== Explain It (B2)
<explain-it-b2-9>
#quote(block: true)[
DISTINCT removes duplicate values.
]

== Memory Hook
<memory-hook-27>
DISTINCT means unique.

== Common Mistake
<common-mistake-32>
Using GROUP BY unnecessarily.

#horizontalrule

= Question 11 --- Find Products in Electronics
<question-11-find-products-in-electronics>
== Business Task
<business-task-10>
Show products from the Electronics category.

== SQL Solution
<sql-solution-10>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" product_name,");],
[#NormalTok("       price");],
[#KeywordTok("FROM");#NormalTok(" products");],
[#KeywordTok("WHERE");#NormalTok(" ");#KeywordTok("category");#NormalTok(" ");#OperatorTok("=");#NormalTok(" ");#StringTok("'Electronics'");#NormalTok(";");],));
== Explain It (B2)
<explain-it-b2-10>
#quote(block: true)[
I filter products by category.
]

#horizontalrule

= Question 12 --- Sort Products by Price
<question-12-sort-products-by-price>
== Business Task
<business-task-11>
Show the cheapest products first.

== SQL Solution
<sql-solution-11>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" product_name,");],
[#NormalTok("       price");],
[#KeywordTok("FROM");#NormalTok(" products");],
[#KeywordTok("ORDER");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" price ");#KeywordTok("ASC");#NormalTok(";");],));
== Explain It (B2)
<explain-it-b2-11>
#quote(block: true)[
I sort products from the lowest price to the highest.
]

#horizontalrule

= SQL Interview Vocabulary
<sql-interview-vocabulary>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Word], [Meaning],),
  table.hline(),
  [Filter], [Remove unwanted rows],
  [Sort], [Change order],
  [Return], [Show results],
  [Column], [Vertical field],
  [Row], [Single record],
)
Use these words during interviews.

#horizontalrule

= Mini Mock Interview
<mini-mock-interview-1>
== Interviewer
<interviewer>
#quote(block: true)[
Show all customers.
]

Pause.

Answer.

#horizontalrule

== Interviewer
<interviewer-1>
#quote(block: true)[
Show completed orders above £200.
]

Pause.

Answer.

#horizontalrule

== Interviewer
<interviewer-2>
#quote(block: true)[
Return the five largest orders.
]

Pause.

Answer.

#horizontalrule

= Cheat Sheet
<cheat-sheet>
== SELECT
<select>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" ");#KeywordTok("column");],
[#KeywordTok("FROM");#NormalTok(" ");#KeywordTok("table");#NormalTok(";");],));
== WHERE
<where>
#Skylighting(([#KeywordTok("WHERE");#NormalTok(" condition;");],));
== ORDER BY
<order-by>
#Skylighting(([#KeywordTok("ORDER");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" ");#KeywordTok("column");#NormalTok(" ");#KeywordTok("DESC");#NormalTok(";");],));
== LIMIT
<limit>
#Skylighting(([#KeywordTok("LIMIT");#NormalTok(" ");#DecValTok("5");#NormalTok(";");],));
== DISTINCT
<distinct>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" ");#KeywordTok("DISTINCT");#NormalTok(" ");#KeywordTok("column");#NormalTok(";");],));

#horizontalrule

= Memory Hooks Summary
<memory-hooks-summary>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Concept], [Hook],),
  table.hline(),
  [SELECT], [Choose],
  [WHERE], [Filter rows],
  [ORDER BY], [Organise],
  [LIMIT], [Stop early],
  [DISTINCT], [Unique],
)

#horizontalrule

= End-of-Sprint Challenge
<end-of-sprint-challenge>
Without looking at previous examples, solve these tasks.

+ Show customers from London.
+ Show orders above £150.
+ Show completed orders.
+ Show the five largest orders.
+ List unique cities.
+ Show Electronics products sorted by price.

Target:

- under #strong[8 minutes]
- explain every query aloud in English.

Congratulations.

You have completed #strong[SQL Sprint 1]. \> \[!TIP\] \> #strong[Practice with Real Data] \> \> Open the #strong[Evenec Retail Playground] and run every query from this chapter on a real SQLite database. \> \> #box(image("sql/../../../assets/qr/github-playground.svg", width: 0.9375in)) \> \> #strong[Open on GitHub] \> \> #NormalTok("playground/evenec-retail");

= SQL Bible
<sql-bible-1>
= Sprint 2 --- Aggregations
<sprint-2-aggregations>
== GROUP BY • HAVING • Aggregate Functions
<group-by-having-aggregate-functions>
Congratulations.

You already know how to retrieve data.

Now you'll learn how analysts #strong[summarise business performance], which is exactly what hiring managers expect from a Junior Data Analyst.

#horizontalrule

= Why Aggregations Matter
<why-aggregations-matter>
Most business questions are not:

#quote(block: true)[
Show me every order.
]

Instead they sound like:

- Which city generates the most revenue?
- How many customers signed up last month?
- What is the average order value?
- Which category sells best?

All of these require aggregation.

#horizontalrule

= Memory Map
<memory-map-1>
Think of the process like making piles.

Rows become groups.

Each group gets a calculation.

Example:

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([City], [Orders],),
  table.hline(),
  [London], [25],
  [Manchester], [18],
  [Leeds], [9],
)
Rows disappear.

Groups remain.

#horizontalrule

= Aggregate Functions Overview
<aggregate-functions-overview>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Function], [Purpose],),
  table.hline(),
  [COUNT()], [Count rows],
  [SUM()], [Total value],
  [AVG()], [Average],
  [MIN()], [Smallest],
  [MAX()], [Largest],
)
Memory Hook:

#quote(block: true)[
#strong[Count • Sum • Average • Minimum • Maximum]
]

#horizontalrule

= Question 13 --- Count All Orders
<question-13-count-all-orders>
== Recruiter Psychology
<recruiter-psychology-58>
Interviewers often begin with COUNT() because it's simple but essential.

== Business Task
<business-task-12>
How many orders exist?

== SQL Solution
<sql-solution-12>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" ");#FunctionTok("COUNT");#NormalTok("(");#OperatorTok("*");#NormalTok(") ");#KeywordTok("AS");#NormalTok(" total_orders");],
[#KeywordTok("FROM");#NormalTok(" orders;");],));
== Explain It (B2)
<explain-it-b2-12>
#quote(block: true)[
COUNT returns the number of rows.
]

== Memory Hook
<memory-hook-28>
COUNT counts records.

== Common Mistake
<common-mistake-33>
Using #NormalTok("COUNT(amount)"); instead of #NormalTok("COUNT(*)");.

#horizontalrule

= Question 14 --- Count London Customers
<question-14-count-london-customers>
== Business Task
<business-task-13>
Count customers living in London.

== SQL Solution
<sql-solution-13>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" ");#FunctionTok("COUNT");#NormalTok("(");#OperatorTok("*");#NormalTok(") ");#KeywordTok("AS");#NormalTok(" london_customers");],
[#KeywordTok("FROM");#NormalTok(" customers");],
[#KeywordTok("WHERE");#NormalTok(" city ");#OperatorTok("=");#NormalTok(" ");#StringTok("'London'");#NormalTok(";");],));
== Explain It (B2)
<explain-it-b2-13>
#quote(block: true)[
First I filter London customers, then I count them.
]

#horizontalrule

= Question 15 --- Total Revenue
<question-15-total-revenue>
== Recruiter Psychology
<recruiter-psychology-59>
Revenue questions appear constantly.

== Business Task
<business-task-14>
Calculate total sales.

== SQL Solution
<sql-solution-14>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" ");#FunctionTok("SUM");#NormalTok("(amount) ");#KeywordTok("AS");#NormalTok(" total_revenue");],
[#KeywordTok("FROM");#NormalTok(" orders;");],));
== Explain It (B2)
<explain-it-b2-14>
#quote(block: true)[
SUM adds every order amount together.
]

== Memory Hook
<memory-hook-29>
SUM builds money.

#horizontalrule

= Question 16 --- Average Order Value
<question-16-average-order-value>
== Business Task
<business-task-15>
Find the average order value.

== SQL Solution
<sql-solution-15>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" ");#FunctionTok("AVG");#NormalTok("(amount) ");#KeywordTok("AS");#NormalTok(" average_order");],
[#KeywordTok("FROM");#NormalTok(" orders;");],));
== Explain It (B2)
<explain-it-b2-15>
#quote(block: true)[
AVG calculates the typical order value.
]

== Common Mistake
<common-mistake-34>
Confusing average with total.

#horizontalrule

= Question 17 --- Largest Order
<question-17-largest-order>
== Business Task
<business-task-16>
Find the highest order.

== SQL Solution
<sql-solution-16>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" ");#FunctionTok("MAX");#NormalTok("(amount) ");#KeywordTok("AS");#NormalTok(" largest_order");],
[#KeywordTok("FROM");#NormalTok(" orders;");],));
== Explain It (B2)
<explain-it-b2-16>
#quote(block: true)[
MAX returns the highest value.
]

#horizontalrule

= Question 18 --- Smallest Order
<question-18-smallest-order>
== SQL Solution
<sql-solution-17>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" ");#FunctionTok("MIN");#NormalTok("(amount) ");#KeywordTok("AS");#NormalTok(" smallest_order");],
[#KeywordTok("FROM");#NormalTok(" orders;");],));
== Explain It (B2)
<explain-it-b2-17>
#quote(block: true)[
MIN finds the lowest value.
]

#horizontalrule

= Understanding GROUP BY
<understanding-group-by>
Imagine these rows.

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Customer], [Amount],),
  table.hline(),
  [Alice], [120],
  [Alice], [80],
  [Bob], [60],
)
GROUP BY creates:

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Customer], [Revenue],),
  table.hline(),
  [Alice], [200],
  [Bob], [60],
)
Rows become summaries.

Memory Hook:

#quote(block: true)[
GROUP BY creates piles.
]

#horizontalrule

= Question 19 --- Revenue by Customer
<question-19-revenue-by-customer>
== Recruiter Psychology
<recruiter-psychology-60>
This is one of the most common interview questions.

== Business Task
<business-task-17>
Calculate revenue for each customer.

== SQL Solution
<sql-solution-18>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" customer_id,");],
[#NormalTok("       ");#FunctionTok("SUM");#NormalTok("(amount) ");#KeywordTok("AS");#NormalTok(" revenue");],
[#KeywordTok("FROM");#NormalTok(" orders");],
[#KeywordTok("GROUP");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" customer_id;");],));
== Explain It (B2)
<explain-it-b2-18>
#quote(block: true)[
I group orders by customer and calculate total revenue.
]

== Common Mistake
<common-mistake-35>
Forgetting #NormalTok("GROUP BY");.

#horizontalrule

= Question 20 --- Orders by Status
<question-20-orders-by-status>
== Business Task
<business-task-18>
Count completed and cancelled orders.

== SQL Solution
<sql-solution-19>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" status,");],
[#NormalTok("       ");#FunctionTok("COUNT");#NormalTok("(");#OperatorTok("*");#NormalTok(") ");#KeywordTok("AS");#NormalTok(" orders");],
[#KeywordTok("FROM");#NormalTok(" orders");],
[#KeywordTok("GROUP");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" status;");],));
== Explain It (B2)
<explain-it-b2-19>
#quote(block: true)[
Every status becomes one group.
]

#horizontalrule

= Question 21 --- Customers by City
<question-21-customers-by-city>
== Business Task
<business-task-19>
Count customers in each city.

== SQL Solution
<sql-solution-20>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" city,");],
[#NormalTok("       ");#FunctionTok("COUNT");#NormalTok("(");#OperatorTok("*");#NormalTok(") ");#KeywordTok("AS");#NormalTok(" customers");],
[#KeywordTok("FROM");#NormalTok(" customers");],
[#KeywordTok("GROUP");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" city;");],));
== Explain It (B2)
<explain-it-b2-20>
#quote(block: true)[
Each city becomes one group.
]

#horizontalrule

= GROUP BY Rule
<group-by-rule>
Every selected column must be either:

- grouped
- aggregated

Example.

Correct.

#Skylighting(([#KeywordTok("SELECT");#NormalTok(" city,");],
[#NormalTok("       ");#FunctionTok("COUNT");#NormalTok("(");#OperatorTok("*");#NormalTok(")");],
[#KeywordTok("FROM");#NormalTok(" customers");],
[#KeywordTok("GROUP");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" city;");],));
Wrong.

#Skylighting(([#KeywordTok("SELECT");#NormalTok(" city,");],
[#NormalTok("       first_name");],
[#KeywordTok("FROM");#NormalTok(" customers");],
[#KeywordTok("GROUP");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" city;");],));
Memory Hook:

#quote(block: true)[
Every passenger needs a seat.
]

#horizontalrule

= Question 22 --- Average Revenue by City
<question-22-average-revenue-by-city>
== Business Task
<business-task-20>
Calculate average order value by city.

== SQL Solution
<sql-solution-21>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" city,");],
[#NormalTok("       ");#FunctionTok("AVG");#NormalTok("(amount) ");#KeywordTok("AS");#NormalTok(" average_revenue");],
[#KeywordTok("FROM");#NormalTok(" customers");],
[#KeywordTok("JOIN");#NormalTok(" orders ");#KeywordTok("USING");#NormalTok("(customer_id)");],
[#KeywordTok("GROUP");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" city;");],));
== Explain It (B2)
<explain-it-b2-21>
#quote(block: true)[
I join customers and orders, group by city and calculate the average.
]

Don't worry about JOIN syntax yet.

Sprint 3 explains it fully.

#horizontalrule

= HAVING
<having>
WHERE filters rows.

HAVING filters groups.

Memory Hook.

#quote(block: true)[
WHERE before GROUP.
]

#quote(block: true)[
HAVING after GROUP.
]

#horizontalrule

= Question 23 --- Cities with More Than Five Customers
<question-23-cities-with-more-than-five-customers>
== Recruiter Psychology
<recruiter-psychology-61>
WHERE vs HAVING is a classic interview trap.

== SQL Solution
<sql-solution-22>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" city,");],
[#NormalTok("       ");#FunctionTok("COUNT");#NormalTok("(");#OperatorTok("*");#NormalTok(") ");#KeywordTok("AS");#NormalTok(" customers");],
[#KeywordTok("FROM");#NormalTok(" customers");],
[#KeywordTok("GROUP");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" city");],
[#KeywordTok("HAVING");#NormalTok(" ");#FunctionTok("COUNT");#NormalTok("(");#OperatorTok("*");#NormalTok(") ");#OperatorTok(">");#NormalTok(" ");#DecValTok("5");#NormalTok(";");],));
== Explain It (B2)
<explain-it-b2-22>
#quote(block: true)[
I first create city groups, then remove groups with five or fewer customers.
]

#horizontalrule

= Question 24 --- Customers Spending Over £500
<question-24-customers-spending-over-500>
== Business Task
<business-task-21>
Find customers whose total spending exceeds £500.

== SQL Solution
<sql-solution-23>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" customer_id,");],
[#NormalTok("       ");#FunctionTok("SUM");#NormalTok("(amount) ");#KeywordTok("AS");#NormalTok(" revenue");],
[#KeywordTok("FROM");#NormalTok(" orders");],
[#KeywordTok("GROUP");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" customer_id");],
[#KeywordTok("HAVING");#NormalTok(" ");#FunctionTok("SUM");#NormalTok("(amount) ");#OperatorTok(">");#NormalTok(" ");#DecValTok("500");#NormalTok(";");],));
== Explain It (B2)
<explain-it-b2-23>
#quote(block: true)[
HAVING filters the grouped results.
]

#horizontalrule

= WHERE vs HAVING
<where-vs-having>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([WHERE], [HAVING],),
  table.hline(),
  [Filters rows], [Filters groups],
  [Before grouping], [After grouping],
)
Interview Tip.

If you're calculating something like SUM or COUNT,

think HAVING.

#horizontalrule

= Question 25 --- Top Revenue Cities
<question-25-top-revenue-cities>
== Business Task
<business-task-22>
Show cities ranked by revenue.

== SQL Solution
<sql-solution-24>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" city,");],
[#NormalTok("       ");#FunctionTok("SUM");#NormalTok("(amount) ");#KeywordTok("AS");#NormalTok(" revenue");],
[#KeywordTok("FROM");#NormalTok(" customers");],
[#KeywordTok("JOIN");#NormalTok(" orders ");#KeywordTok("USING");#NormalTok("(customer_id)");],
[#KeywordTok("GROUP");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" city");],
[#KeywordTok("ORDER");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" revenue ");#KeywordTok("DESC");#NormalTok(";");],));
== Explain It (B2)
<explain-it-b2-24>
#quote(block: true)[
I calculate revenue for every city and sort from highest to lowest.
]

#horizontalrule

= Business Case
<business-case>
Imagine you're interviewing at Tesco.

The hiring manager asks.

#quote(block: true)[
Which city performs best?
]

Your answer.

+ Join customers and orders.
+ Group by city.
+ Calculate revenue.
+ Sort descending.

Notice.

You're describing thinking.

Not just SQL.

#horizontalrule

= Mini Mock Interview
<mini-mock-interview-2>
== Interviewer
<interviewer-3>
How many customers do we have?

Pause.

Answer.

#horizontalrule

== Interviewer
<interviewer-4>
Which city has the highest revenue?

Pause.

Answer.

#horizontalrule

== Interviewer
<interviewer-5>
Which customers spent over £500?

Pause.

Answer.

#horizontalrule

= Cheat Sheet
<cheat-sheet-1>
== COUNT
<count>
#Skylighting(([#FunctionTok("COUNT");#NormalTok("(");#OperatorTok("*");#NormalTok(")");],));
== SUM
<sum>
#Skylighting(([#FunctionTok("SUM");#NormalTok("(amount)");],));
== AVG
<avg>
#Skylighting(([#FunctionTok("AVG");#NormalTok("(amount)");],));
== GROUP BY
<group-by>
#Skylighting(([#KeywordTok("GROUP");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" customer_id");],));
== HAVING
<having-1>
#Skylighting(([#KeywordTok("HAVING");#NormalTok(" ");#FunctionTok("SUM");#NormalTok("(amount) ");#OperatorTok(">");#NormalTok(" ");#DecValTok("500");],));

#horizontalrule

= Memory Hooks
<memory-hooks>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Concept], [Hook],),
  table.hline(),
  [COUNT], [Count records],
  [SUM], [Build money],
  [AVG], [Typical value],
  [GROUP BY], [Make piles],
  [HAVING], [Filter groups],
)

#horizontalrule

= End-of-Sprint Challenge
<end-of-sprint-challenge-1>
Complete these without looking.

+ Count all customers.
+ Count London customers.
+ Calculate total revenue.
+ Find average order value.
+ Find the largest order.
+ Revenue by customer.
+ Customers by city.
+ Cities with more than five customers.
+ Customers spending over £500.
+ Top revenue cities.

Target.

- #strong[12 minutes]
- explain every query aloud in English.

Congratulations.

You have completed #strong[SQL Sprint 2]. \> \[!TIP\] \> #strong[Practice with Real Data] \> \> Open the #strong[Evenec Retail Playground] and run every query from this chapter on a real SQLite database. \> \> #box(image("sql/../../../assets/qr/github-playground.svg", width: 0.9375in)) \> \> #strong[Open on GitHub] \> \> #NormalTok("playground/evenec-retail");

= SQL Bible
<sql-bible-2>
= Sprint 3 --- JOINs, CTEs & Subqueries
<sprint-3-joins-ctes-subqueries>
== The Language of Relationships
<the-language-of-relationships>
Welcome to the most important chapter for Junior Data Analyst interviews.

Most real business questions require combining information from multiple tables.

Instead of memorising JOIN syntax, you'll learn to think like an analyst.

#horizontalrule

= The Evenec Retail Relationship Map
<the-evenec-retail-relationship-map>
Our dataset follows one business story.

- Customers place Orders.
- Orders contain Items.
- Items reference Products.
- Orders receive Payments.

== Entity Relationship Overview
<entity-relationship-overview>
customers

orders

payments

order\_items

products

customer\_id order\_id order\_id product\_id
Memory Hook:

#quote(block: true)[
#strong[Customer → Order → Item → Product]
]

#horizontalrule

= Why JOIN Exists
<why-join-exists>
Imagine two separate tables.

#strong[customers]

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([customer\_id], [first\_name],),
  table.hline(),
  [1], [Alice],
  [2], [Bob],
)
#strong[orders]

#table(
  columns: 3,
  align: (auto,auto,auto,),
  table.header([order\_id], [customer\_id], [amount],),
  table.hline(),
  [101], [1], [120],
  [102], [2], [60],
)
A JOIN connects them.

Result.

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([first\_name], [amount],),
  table.hline(),
  [Alice], [120],
  [Bob], [60],
)

#horizontalrule

= JOIN Mental Model
<join-mental-model>
Instead of remembering syntax,

remember relationships.

#quote(block: true)[
Keys connect stories.
]

Primary Key.

Foreign Key.

Bridge.

#horizontalrule

= Question 26 --- INNER JOIN
<question-26-inner-join>
== Recruiter Psychology
<recruiter-psychology-62>
This is one of the most common interview questions.

== Business Task
<business-task-23>
Show every order together with the customer's name.

== SQL Solution
<sql-solution-25>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" c.first_name,");],
[#NormalTok("       o.order_id,");],
[#NormalTok("       o.amount");],
[#KeywordTok("FROM");#NormalTok(" customers c");],
[#KeywordTok("INNER");#NormalTok(" ");#KeywordTok("JOIN");#NormalTok(" orders o");],
[#KeywordTok("ON");#NormalTok(" c.customer_id ");#OperatorTok("=");#NormalTok(" o.customer_id;");],));
== Explain It (B2)
<explain-it-b2-25>
#quote(block: true)[
I connect customers and orders using customer\_id and return customer names with their orders.
]

== Memory Hook
<memory-hook-30>
INNER = Both must exist.

#horizontalrule

= INNER JOIN Visual
<inner-join-visual>
Customers Orders
Only the overlap remains.

#horizontalrule

= Question 27 --- LEFT JOIN
<question-27-left-join>
== Business Task
<business-task-24>
Show every customer, even if they never ordered.

== SQL
<sql>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" c.first_name,");],
[#NormalTok("       o.order_id");],
[#KeywordTok("FROM");#NormalTok(" customers c");],
[#KeywordTok("LEFT");#NormalTok(" ");#KeywordTok("JOIN");#NormalTok(" orders o");],
[#KeywordTok("ON");#NormalTok(" c.customer_id ");#OperatorTok("=");#NormalTok(" o.customer_id;");],));
== Explain It (B2)
<explain-it-b2-26>
#quote(block: true)[
Every customer appears. Missing orders become NULL.
]

== Memory Hook
<memory-hook-31>
#strong[Left keeps everyone.]

This phrase will appear throughout the book.

#horizontalrule

= LEFT JOIN Visual
<left-join-visual>
Customers Orders
Everything from the left table survives.

#horizontalrule

= Interview Trap
<interview-trap>
Question.

#quote(block: true)[
Why is LEFT JOIN useful?
]

Good answer.

#quote(block: true)[
It allows me to keep every customer even when related records don't exist.
]

Avoid saying.

#quote(block: true)[
Because it joins left.
]

Explain the business value.

#horizontalrule

= Question 28 --- Find Customers Without Orders
<question-28-find-customers-without-orders>
== SQL
<sql-1>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" c.first_name");],
[#KeywordTok("FROM");#NormalTok(" customers c");],
[#KeywordTok("LEFT");#NormalTok(" ");#KeywordTok("JOIN");#NormalTok(" orders o");],
[#KeywordTok("ON");#NormalTok(" c.customer_id ");#OperatorTok("=");#NormalTok(" o.customer_id");],
[#KeywordTok("WHERE");#NormalTok(" o.order_id ");#KeywordTok("IS");#NormalTok(" ");#KeywordTok("NULL");#NormalTok(";");],));
== Explain It (B2)
<explain-it-b2-27>
#quote(block: true)[
I keep every customer and filter those without matching orders.
]

Memory Hook.

NULL means "missing".

#horizontalrule

= Question 29 --- Join Three Tables
<question-29-join-three-tables>
Business questions often need multiple joins.

Example.

Customers.

Orders.

Payments.

#Skylighting(([#KeywordTok("SELECT");#NormalTok(" c.first_name,");],
[#NormalTok("       o.order_id,");],
[#NormalTok("       p.payment_method");],
[#KeywordTok("FROM");#NormalTok(" customers c");],
[#KeywordTok("JOIN");#NormalTok(" orders o");],
[#KeywordTok("ON");#NormalTok(" c.customer_id ");#OperatorTok("=");#NormalTok(" o.customer_id");],
[#KeywordTok("JOIN");#NormalTok(" payments p");],
[#KeywordTok("ON");#NormalTok(" o.order_id ");#OperatorTok("=");#NormalTok(" p.order_id;");],));
Explain.

#quote(block: true)[
First I connect customers to orders, then orders to payments.
]

Think.

Step by step.

#horizontalrule

= JOIN Order
<join-order>
Always ask yourself.

What is my starting table?

Then walk through relationships.

Customer

↓

Order

↓

Payment

Never jump randomly.

#horizontalrule

= CTE --- Common Table Expression
<cte-common-table-expression>
Interviewers love CTEs because they improve readability.

Memory Hook.

#quote(block: true)[
CTE = Temporary workspace.
]

Instead of writing one giant query,

build it in steps.

#horizontalrule

= Question 30 --- First CTE
<question-30-first-cte>
Business Task.

Find high-value customers.

#Skylighting(([#KeywordTok("WITH");#NormalTok(" customer_revenue ");#KeywordTok("AS");#NormalTok(" (");],
[#NormalTok("    ");#KeywordTok("SELECT");#NormalTok(" customer_id,");],
[#NormalTok("           ");#FunctionTok("SUM");#NormalTok("(amount) ");#KeywordTok("AS");#NormalTok(" revenue");],
[#NormalTok("    ");#KeywordTok("FROM");#NormalTok(" orders");],
[#NormalTok("    ");#KeywordTok("GROUP");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" customer_id");],
[#NormalTok(")");],
[#KeywordTok("SELECT");#NormalTok(" ");#OperatorTok("*");],
[#KeywordTok("FROM");#NormalTok(" customer_revenue");],
[#KeywordTok("WHERE");#NormalTok(" revenue ");#OperatorTok(">");#NormalTok(" ");#DecValTok("500");#NormalTok(";");],));
== Explain It (B2)
<explain-it-b2-28>
#quote(block: true)[
First I create a temporary table, then I filter it.
]

Memory Hook.

WITH creates a temporary workspace.

#horizontalrule

= Why CTE Is Better
<why-cte-is-better>
Instead of.

#Skylighting(([#KeywordTok("SELECT");#NormalTok(" ");#OperatorTok("..");#NormalTok(".");],));
inside another huge query,

split the problem.

Cleaner.

Easier to explain.

Interviewers appreciate readability.

#horizontalrule

= Subqueries
<subqueries>
A subquery is simply

#quote(block: true)[
a query inside another query.
]

Memory Hook.

#quote(block: true)[
Box inside a box.
]

#horizontalrule

= Question 31 --- Above Average Orders
<question-31-above-average-orders>
Business Task.

Find orders larger than the average.

#Skylighting(([#KeywordTok("SELECT");#NormalTok(" order_id,");],
[#NormalTok("       amount");],
[#KeywordTok("FROM");#NormalTok(" orders");],
[#KeywordTok("WHERE");#NormalTok(" amount ");#OperatorTok(">");],
[#NormalTok("(");],
[#NormalTok("    ");#KeywordTok("SELECT");#NormalTok(" ");#FunctionTok("AVG");#NormalTok("(amount)");],
[#NormalTok("    ");#KeywordTok("FROM");#NormalTok(" orders");],
[#NormalTok(");");],));
== Explain It (B2)
<explain-it-b2-29>
#quote(block: true)[
First SQL calculates the average, then it compares every order against it.
]

#horizontalrule

= Subquery Visual
<subquery-visual>
Main Query

AVG(amount)
One query feeds another.

#horizontalrule

= Question 32 --- Products Above Average Price
<question-32-products-above-average-price>
#Skylighting(([#KeywordTok("SELECT");#NormalTok(" product_name,");],
[#NormalTok("       price");],
[#KeywordTok("FROM");#NormalTok(" products");],
[#KeywordTok("WHERE");#NormalTok(" price ");#OperatorTok(">");],
[#NormalTok("(");],
[#NormalTok("    ");#KeywordTok("SELECT");#NormalTok(" ");#FunctionTok("AVG");#NormalTok("(price)");],
[#NormalTok("    ");#KeywordTok("FROM");#NormalTok(" products");],
[#NormalTok(");");],));
Explain.

#quote(block: true)[
Products become filtered using the average price.
]

#horizontalrule

= CTE vs Subquery
<cte-vs-subquery>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([CTE], [Subquery],),
  table.hline(),
  [Easier to read], [Shorter],
  [Reusable], [Quick calculations],
  [Better for interviews], [Fine for simple tasks],
)
Interview Tip.

If readability matters,

choose a CTE.

#horizontalrule

= Business Case --- Amazon Style
<business-case-amazon-style>
Imagine this question.

#quote(block: true)[
Find customers whose spending is above the company average.
]

Think aloud.

+ Calculate customer revenue.
+ Calculate average revenue.
+ Compare.

Interviewers score your reasoning,

not just the final SQL.

#horizontalrule

= Mini Mock Interview
<mini-mock-interview-3>
Interviewer.

#quote(block: true)[
Explain LEFT JOIN.
]

Pause.

Answer.

#horizontalrule

Interviewer.

#quote(block: true)[
Why use a CTE?
]

Pause.

Answer.

#horizontalrule

Interviewer.

#quote(block: true)[
Find orders above average.
]

Pause.

Answer.

#horizontalrule

= Cheat Sheet
<cheat-sheet-2>
== INNER JOIN
<inner-join>
#Skylighting(([#KeywordTok("INNER");#NormalTok(" ");#KeywordTok("JOIN");#NormalTok(" ");#KeywordTok("table");],
[#KeywordTok("ON");#NormalTok(" ");#KeywordTok("key");#NormalTok(" ");#OperatorTok("=");#NormalTok(" ");#KeywordTok("key");#NormalTok(";");],));
== LEFT JOIN
<left-join>
#Skylighting(([#KeywordTok("LEFT");#NormalTok(" ");#KeywordTok("JOIN");#NormalTok(" ");#KeywordTok("table");],
[#KeywordTok("ON");#NormalTok(" ");#KeywordTok("key");#NormalTok(" ");#OperatorTok("=");#NormalTok(" ");#KeywordTok("key");#NormalTok(";");],));
== CTE
<cte>
#Skylighting(([#KeywordTok("WITH");#NormalTok(" temp ");#KeywordTok("AS");#NormalTok(" (");#OperatorTok("..");#NormalTok(".)");],
[#KeywordTok("SELECT");#NormalTok(" ");#OperatorTok("..");#NormalTok(".");],));
== Subquery
<subquery>
#Skylighting(([#KeywordTok("WHERE");#NormalTok(" ");#FunctionTok("value");#NormalTok(" ");#OperatorTok(">");],
[#NormalTok("(");],
[#KeywordTok("SELECT");#NormalTok(" ");#FunctionTok("AVG");#NormalTok("(");#OperatorTok("..");#NormalTok(".)");],
[#NormalTok(")");],));

#horizontalrule

= Memory Hooks Summary
<memory-hooks-summary-1>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Concept], [Hook],),
  table.hline(),
  [INNER], [Both exist],
  [LEFT], [Left keeps everyone],
  [NULL], [Missing],
  [CTE], [Temporary workspace],
  [Subquery], [Box inside a box],
)

#horizontalrule

= End-of-Sprint Challenge
<end-of-sprint-challenge-2>
Complete these without looking.

+ Join customers and orders.
+ Show every customer using LEFT JOIN.
+ Find customers without orders.
+ Join customers, orders and payments.
+ Build a CTE.
+ Find orders above average.
+ Find products above average price.
+ Explain INNER JOIN in English.
+ Explain LEFT JOIN in English.
+ Explain why CTE improves readability.

Target.

- #strong[15 minutes]
- explain every solution aloud in English.

Congratulations.

You have completed #strong[SQL Sprint 3]. \> \[!TIP\] \> #strong[Practice with Real Data] \> \> Open the #strong[Evenec Retail Playground] and run every query from this chapter on a real SQLite database. \> \> #box(image("sql/../../../assets/qr/github-playground.svg", width: 0.9375in)) \> \> #strong[Open on GitHub] \> \> #NormalTok("playground/evenec-retail");

= SQL Bible
<sql-bible-3>
= Sprint 4 --- Window Functions & Interview Finale
<sprint-4-window-functions-interview-finale>
== ROW\_NUMBER • RANK • DENSE\_RANK • LAG • LEAD • OVER()
<row_number-rank-dense_rank-lag-lead-over>
Welcome to the final SQL sprint.

By now you've learned:

- filtering;
- aggregation;
- joins;
- CTEs;
- subqueries.

Now you'll learn the functions that often separate a confident Junior Analyst from someone who only knows basic SQL.

#horizontalrule

= Why Window Functions Matter
<why-window-functions-matter>
Imagine this question.

#quote(block: true)[
Who are the top three customers in every city?
]

GROUP BY cannot answer this alone.

Window functions calculate values #strong[without destroying individual rows].

Memory Hook.

#quote(block: true)[
GROUP BY collapses.
]

#quote(block: true)[
WINDOW looks through.
]

#horizontalrule

= The Window Mental Model
<the-window-mental-model>
Think of standing inside a moving window.

The table stays.

The calculation changes.

Rows remain visible.

#horizontalrule

= OVER()
<over>
Every window function uses:

#Skylighting(([#KeywordTok("OVER");#NormalTok("(");#OperatorTok("..");#NormalTok(".)");],));
Think of it as:

#quote(block: true)[
Look through this window.
]

#horizontalrule

= Question 33 --- ROW\_NUMBER()
<question-33-row_number>
== Recruiter Psychology
<recruiter-psychology-63>
This is one of the most common technical interview questions.

== Business Task
<business-task-25>
Number every order.

#Skylighting(([#KeywordTok("SELECT");#NormalTok(" order_id,");],
[#NormalTok("       amount,");],
[#NormalTok("       ");#FunctionTok("ROW_NUMBER");#NormalTok("() ");#KeywordTok("OVER");#NormalTok("(");#KeywordTok("ORDER");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" amount ");#KeywordTok("DESC");#NormalTok(") ");#KeywordTok("AS");#NormalTok(" row_num");],
[#KeywordTok("FROM");#NormalTok(" orders;");],));
== Explain It (B2)
<explain-it-b2-30>
#quote(block: true)[
I sort orders by amount and assign a unique number to each row.
]

Memory Hook.

ROW\_NUMBER never repeats.

#horizontalrule

= Visual
<visual>
#table(
  columns: 2,
  align: (auto,right,),
  table.header([Amount], [ROW\_NUMBER],),
  table.hline(),
  [500], [1],
  [400], [2],
  [300], [3],
)
Unique numbering.

#horizontalrule

= Question 34 --- RANK()
<question-34-rank>
Business Task.

Rank customers by revenue.

#Skylighting(([#KeywordTok("SELECT");#NormalTok(" customer_id,");],
[#NormalTok("       revenue,");],
[#NormalTok("       ");#FunctionTok("RANK");#NormalTok("() ");#KeywordTok("OVER");#NormalTok("(");#KeywordTok("ORDER");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" revenue ");#KeywordTok("DESC");#NormalTok(") ");#KeywordTok("AS");#NormalTok(" customer_rank");],
[#KeywordTok("FROM");#NormalTok(" customer_revenue;");],));
Result.

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Revenue], [Rank],),
  table.hline(),
  [500], [1],
  [400], [2],
  [400], [2],
  [300], [4],
)
Notice.

Rank skips numbers.

Memory Hook.

RANK leaves gaps.

#horizontalrule

= Question 35 --- DENSE\_RANK()
<question-35-dense_rank>
Same example.

#Skylighting(([#KeywordTok("SELECT");#NormalTok(" customer_id,");],
[#NormalTok("       revenue,");],
[#NormalTok("       ");#FunctionTok("DENSE_RANK");#NormalTok("() ");#KeywordTok("OVER");#NormalTok("(");#KeywordTok("ORDER");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" revenue ");#KeywordTok("DESC");#NormalTok(") ");#KeywordTok("AS");#NormalTok(" ");#FunctionTok("dense_rank");],
[#KeywordTok("FROM");#NormalTok(" customer_revenue;");],));
Result.

#table(
  columns: 2,
  align: (auto,right,),
  table.header([Revenue], [Dense Rank],),
  table.hline(),
  [500], [1],
  [400], [2],
  [400], [2],
  [300], [3],
)
No gaps.

Memory Hook.

Dense fills gaps.

#horizontalrule

= Interview Trap
<interview-trap-1>
Question.

#quote(block: true)[
When would you choose DENSE\_RANK instead of RANK?
]

Good answer.

#quote(block: true)[
When tied values shouldn't create gaps in the ranking.
]

#horizontalrule

= PARTITION BY
<partition-by>
Window functions become much more powerful.

Example.

Rank customers #strong[inside each city].

#Skylighting(([#KeywordTok("SELECT");#NormalTok(" customer_id,");],
[#NormalTok("       city,");],
[#NormalTok("       revenue,");],
[#NormalTok("       ");#FunctionTok("ROW_NUMBER");#NormalTok("()");],
[#NormalTok("       ");#KeywordTok("OVER");#NormalTok("(");],
[#NormalTok("           ");#KeywordTok("PARTITION");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" city");],
[#NormalTok("           ");#KeywordTok("ORDER");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" revenue ");#KeywordTok("DESC");],
[#NormalTok("       ) ");#KeywordTok("AS");#NormalTok(" city_rank");],
[#KeywordTok("FROM");#NormalTok(" customer_revenue;");],));
Memory Hook.

PARTITION creates mini competitions.

#horizontalrule

= Visual
<visual-1>
London.

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Revenue], [Rank],),
  table.hline(),
  [500], [1],
  [300], [2],
)
Manchester.

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Revenue], [Rank],),
  table.hline(),
  [600], [1],
  [250], [2],
)
Separate rankings.

#horizontalrule

= Question 36 --- Top Customer in Every City
<question-36-top-customer-in-every-city>
Business Task.

Return only the best customer from each city.

#Skylighting(([#KeywordTok("WITH");#NormalTok(" ranked ");#KeywordTok("AS");],
[#NormalTok("(");],
[#KeywordTok("SELECT");#NormalTok(" customer_id,");],
[#NormalTok("       city,");],
[#NormalTok("       revenue,");],
[#NormalTok("       ");#FunctionTok("ROW_NUMBER");#NormalTok("()");],
[#NormalTok("       ");#KeywordTok("OVER");#NormalTok("(");],
[#NormalTok("         ");#KeywordTok("PARTITION");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" city");],
[#NormalTok("         ");#KeywordTok("ORDER");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" revenue ");#KeywordTok("DESC");],
[#NormalTok("       ) ");#KeywordTok("AS");#NormalTok(" rn");],
[#KeywordTok("FROM");#NormalTok(" customer_revenue");],
[#NormalTok(")");],
[],
[#KeywordTok("SELECT");#NormalTok(" ");#OperatorTok("*");],
[#KeywordTok("FROM");#NormalTok(" ranked");],
[#KeywordTok("WHERE");#NormalTok(" rn");#OperatorTok("=");#DecValTok("1");#NormalTok(";");],));
Explain.

#quote(block: true)[
First I rank customers inside each city, then I keep only rank one.
]

#horizontalrule

= LAG()
<lag>
LAG compares with the previous row.

Business Task.

Compare today's revenue with yesterday's.

#Skylighting(([#KeywordTok("SELECT");#NormalTok(" order_date,");],
[#NormalTok("       revenue,");],
[#NormalTok("       ");#FunctionTok("LAG");#NormalTok("(revenue)");],
[#NormalTok("       ");#KeywordTok("OVER");#NormalTok("(");#KeywordTok("ORDER");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" order_date) ");#KeywordTok("AS");#NormalTok(" previous_day");],
[#KeywordTok("FROM");#NormalTok(" daily_sales;");],));
Memory Hook.

LAG looks back.

#horizontalrule

= LEAD()
<lead>
LEAD looks forward.

#Skylighting(([#KeywordTok("SELECT");#NormalTok(" order_date,");],
[#NormalTok("       revenue,");],
[#NormalTok("       ");#FunctionTok("LEAD");#NormalTok("(revenue)");],
[#NormalTok("       ");#KeywordTok("OVER");#NormalTok("(");#KeywordTok("ORDER");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" order_date) ");#KeywordTok("AS");#NormalTok(" ");#FunctionTok("next_day");],
[#KeywordTok("FROM");#NormalTok(" daily_sales;");],));
Memory Hook.

LEAD looks ahead.

#horizontalrule

= Running Total
<running-total>
A classic interview question.

Business Task.

Calculate cumulative revenue.

#Skylighting(([#KeywordTok("SELECT");#NormalTok(" order_date,");],
[#NormalTok("       amount,");],
[#NormalTok("       ");#FunctionTok("SUM");#NormalTok("(amount)");],
[#NormalTok("       ");#KeywordTok("OVER");#NormalTok("(");],
[#NormalTok("         ");#KeywordTok("ORDER");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" order_date");],
[#NormalTok("       ) ");#KeywordTok("AS");#NormalTok(" running_total");],
[#KeywordTok("FROM");#NormalTok(" orders;");],));
Explain.

#quote(block: true)[
The total grows after every row.
]

Memory Hook.

Running total keeps growing.

#horizontalrule

= Moving Average
<moving-average>
Another popular interview task.

#Skylighting(([#KeywordTok("SELECT");#NormalTok(" order_date,");],
[#NormalTok("       revenue,");],
[#NormalTok("       ");#FunctionTok("AVG");#NormalTok("(revenue)");],
[#NormalTok("       ");#KeywordTok("OVER");#NormalTok("(");],
[#NormalTok("         ");#KeywordTok("ORDER");#NormalTok(" ");#KeywordTok("BY");#NormalTok(" order_date");],
[#NormalTok("         ");#KeywordTok("ROWS");#NormalTok(" ");#KeywordTok("BETWEEN");#NormalTok(" ");#DecValTok("6");#NormalTok(" ");#KeywordTok("PRECEDING");],
[#NormalTok("         ");#KeywordTok("AND");#NormalTok(" ");#KeywordTok("CURRENT");#NormalTok(" ");#KeywordTok("ROW");],
[#NormalTok("       ) ");#KeywordTok("AS");#NormalTok(" seven_day_average");],
[#KeywordTok("FROM");#NormalTok(" daily_sales;");],));
Interview Tip.

Don't memorise.

Understand.

The window moves.

#horizontalrule

= Window Function Cheat Sheet
<window-function-cheat-sheet>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Function], [Purpose],),
  table.hline(),
  [ROW\_NUMBER], [Unique numbering],
  [RANK], [Ranking with gaps],
  [DENSE\_RANK], [Ranking without gaps],
  [LAG], [Previous row],
  [LEAD], [Next row],
  [SUM OVER], [Running total],
)

#horizontalrule

= Business Case 1 --- Tesco
<business-case-1-tesco>
Question.

Which city generated the most revenue?

Expected Thinking.

- Join customers.
- Group by city.
- Sum revenue.
- Sort descending.

#horizontalrule

= Business Case 2 --- Amazon
<business-case-2-amazon>
Question.

Find the highest-spending customer in every city.

Expected Solution.

Use:

- CTE
- ROW\_NUMBER
- PARTITION BY

#horizontalrule

= Business Case 3 --- Deliveroo
<business-case-3-deliveroo>
Question.

Find customers who haven't ordered recently.

Expected Thinking.

- Latest order.
- Compare dates.
- Filter inactive customers.

#horizontalrule

= Business Case 4 --- NHS
<business-case-4-nhs>
Question.

Calculate average appointments per patient.

Same SQL principle.

Business changes.

Logic stays.

#horizontalrule

= Business Case 5 --- Wise
<business-case-5-wise>
Question.

Which payment method processes the most money?

Expected Thinking.

- Join payments.
- Group by payment method.
- SUM(amount).

#horizontalrule

= Business Case 6 --- Monzo
<business-case-6-monzo>
Question.

Find unusually large transactions.

Expected Thinking.

Use:

- AVG
- Subquery
- WHERE.

#horizontalrule

= Business Case 7 --- Retail Dashboard
<business-case-7-retail-dashboard>
Question.

Create KPIs.

Required.

- Total revenue
- Average order
- Largest order
- Customer count

#horizontalrule

= Business Case 8 --- Customer Retention
<business-case-8-customer-retention>
Question.

Who made repeat purchases?

Expected Thinking.

Count orders.

HAVING COUNT()\>1.

#horizontalrule

= Business Case 9 --- Product Performance
<business-case-9-product-performance>
Question.

Top-selling category.

Expected Thinking.

Join.

Group.

Sort.

#horizontalrule

= Business Case 10 --- Executive Report
<business-case-10-executive-report>
Imagine presenting to a CEO.

Don't say.

#quote(block: true)[
GROUP BY…
]

Instead say.

#quote(block: true)[
London generated the highest revenue, while Birmingham showed the fastest growth.
]

Analysts communicate business impact.

#horizontalrule

= Full Mock SQL Interview (45 Minutes)
<full-mock-sql-interview-45-minutes>
This simulates a real UK Junior Data Analyst interview.

== Part 1 --- Warm-up (10 min)
<part-1-warm-up-10-min>
#strong[Interviewer]

Show London customers.

Pause.

Answer.

#horizontalrule

Find completed orders.

Pause.

Answer.

#horizontalrule

Top five orders.

Pause.

Answer.

#horizontalrule

== Part 2 --- Aggregations (10 min)
<part-2-aggregations-10-min>
Revenue by city.

Pause.

Answer.

#horizontalrule

Customers spending over £500.

Pause.

Answer.

#horizontalrule

Explain HAVING.

Pause.

Answer.

#horizontalrule

== Part 3 --- JOINs (10 min)
<part-3-joins-10-min>
Connect customers and orders.

Pause.

Answer.

#horizontalrule

Find customers without orders.

Pause.

Answer.

#horizontalrule

Explain LEFT JOIN.

Pause.

Answer.

#horizontalrule

== Part 4 --- Advanced SQL (15 min)
<part-4-advanced-sql-15-min>
Rank customers.

Pause.

Answer.

#horizontalrule

Above-average orders.

Pause.

Answer.

#horizontalrule

Top customer in every city.

Pause.

Answer.

#horizontalrule

Running total.

Pause.

Answer.

#horizontalrule

= Interview English Cheat Sheet
<interview-english-cheat-sheet>
Useful phrases.

Instead of:

#quote(block: true)[
"SQL does this…"
]

Say:

#quote(block: true)[
First I filter…
]

#quote(block: true)[
Then I group…
]

#quote(block: true)[
After that I calculate…
]

#quote(block: true)[
Finally I sort…
]

This sounds much more natural in interviews.

#horizontalrule

= Common Interview Mistakes
<common-interview-mistakes>
❌ Writing before thinking.

✔ Explain your approach first.

#horizontalrule

❌ Memorising syntax only.

✔ Explain business reasoning.

#horizontalrule

❌ Panicking during joins.

✔ Draw relationships mentally.

#horizontalrule

= 5-Minute Emergency Revision
<minute-emergency-revision>
Remember these.

== SELECT
<select-1>
Choose columns.

== WHERE
<where-1>
Filter rows.

== GROUP BY
<group-by-1>
Create groups.

== HAVING
<having-2>
Filter groups.

== JOIN
<join>
Connect stories.

== CTE
<cte-1>
Temporary workspace.

== ROW\_NUMBER
<row_number>
Unique numbering.

== RANK
<rank>
Leaves gaps.

== DENSE\_RANK
<dense_rank>
No gaps.

== LAG
<lag-1>
Looks back.

== LEAD
<lead-1>
Looks ahead.

#horizontalrule

= Final SQL Challenge
<final-sql-challenge>
Complete these ten tasks without looking.

+ London customers.
+ Revenue by city.
+ Top five orders.
+ Customers over £500.
+ Join customers and orders.
+ Customers without orders.
+ Above-average orders.
+ Top customer per city.
+ Running total.
+ Rank customers.

Target.

- #strong[25 minutes]
- explain every query aloud in English.

#horizontalrule

= SQL Bible Complete
<sql-bible-complete>
Congratulations.

You have completed all four SQL sprints.

Before moving to Excel and Power BI, make sure you can:

- write queries without copying;
- explain every query in English;
- recognise business questions behind SQL tasks.

Remember.

Companies don't hire analysts because they know SQL.

They hire analysts because they solve business problems with SQL. \> \[!TIP\] \> #strong[Practice with Real Data] \> \> Open the #strong[Evenec Retail Playground] and run every query from this chapter on a real SQLite database. \> \> #box(image("sql/../../../assets/qr/github-playground.svg", width: 0.9375in)) \> \> #strong[Open on GitHub] \> \> #NormalTok("playground/evenec-retail");

#part[Part III — Excel Interview Bible]
= Excel Interview Bible
<excel-interview-bible>
= Sprint 1 --- Excel Foundations
<sprint-1-excel-foundations>
== Tables • Filters • Sorting • Essential Navigation
<tables-filters-sorting-essential-navigation>
Welcome to the Excel Interview Bible.

Unlike traditional Excel courses, this chapter prepares you for #strong[real Junior Data Analyst interviews in UK companies].

We'll use the #strong[Evenec Retail Playground] throughout every exercise.

#horizontalrule

= The Evenec Retail Dataset
<the-evenec-retail-dataset>
Open:

#NormalTok("playground/evenec-retail/csv/customers.csv");

This is your first working dataset.

You are already familiar with it from SQL.

Now we'll analyse it in Excel.

#horizontalrule

= Why Companies Use Excel
<why-companies-use-excel>
SQL extracts data.

Excel explores it.

A typical workflow looks like this.

- SQL exports data.
- Excel cleans it.
- Pivot Tables summarise it.
- Charts communicate results.

Memory Hook.

#quote(block: true)[
SQL finds data.
]

#quote(block: true)[
Excel explains data.
]

#horizontalrule

= Interview Question 1
<interview-question-1>
== Recruiter Psychology
<recruiter-psychology-64>
Can you work confidently with raw spreadsheets?

== Task
<task-1>
Open #NormalTok("customers.csv");.

Convert it into an Excel Table.

== Steps
<steps>
+ Select any cell.
+ Press #strong[Ctrl + T].
+ Tick "My table has headers."

== Why Tables Matter
<why-tables-matter>
Tables automatically expand.

Formulas become easier.

Filters appear automatically.

== Bogdan Notes
<bogdan-notes>
During interviews, creating a Table quickly signals confidence with Excel fundamentals.

#horizontalrule

= Interview Question 2
<interview-question-2>
== Filters
<filters>
Task.

Show only customers from London.

=== Steps
<steps-1>
- Click the filter arrow.
- Choose London.

=== Interview English
<interview-english>
#quote(block: true)[
I filtered the customer list to display only London records.
]

Memory Hook.

Filter hides.

Delete removes.

Never confuse them.

#horizontalrule

= Interview Question 3
<interview-question-3>
== Multi-Level Sorting
<multi-level-sorting>
Task.

Sort customers by:

+ City (A-Z)
+ Signup Date (Oldest First)

=== Steps
<steps-2>
Data → Sort

Add another level.

=== Why Recruiters Ask This
<why-recruiters-ask-this>
Real reports rarely use one sort.

#horizontalrule

= Freeze Panes
<freeze-panes>
Imagine scrolling through 5,000 rows.

Headers disappear.

Solution.

View → Freeze Panes.

Memory Hook.

Freeze protects headers.

#horizontalrule

= Interview Question 4
<interview-question-4>
Find the newest customer.

Hint.

Sort by Signup Date.

Descending.

#horizontalrule

= Essential Keyboard Shortcuts
<essential-keyboard-shortcuts>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Shortcut], [Purpose],),
  table.hline(),
  [Ctrl+T], [Create Table],
  [Ctrl+Shift+L], [Toggle Filters],
  [Ctrl+Arrow], [Jump through data],
  [Ctrl+Home], [Top of sheet],
  [Ctrl+End], [Last used cell],
)
Practice until these become automatic.

#horizontalrule

= Structured References
<structured-references>
Instead of

#Skylighting(([#NormalTok("=A2+B2");],));
Tables allow

#Skylighting(([#NormalTok("=[@Revenue]+[@Tax]");],));
Interview Tip.

Recruiters often prefer structured references because they're easier to maintain.

#horizontalrule

= Interview Question 5
<interview-question-5>
Count customers using the status bar.

Don't write a formula.

Select the column.

Read the status bar.

This demonstrates practical Excel knowledge.

#horizontalrule

= Removing Duplicates
<removing-duplicates>
Task.

Find unique cities.

Data → Remove Duplicates.

Compare this with SQL.

SQL used:

#Skylighting(([#KeywordTok("SELECT");#NormalTok(" ");#KeywordTok("DISTINCT");#NormalTok(" city");],
[#KeywordTok("FROM");#NormalTok(" customers;");],));
Notice.

Different tool.

Same business goal.

#horizontalrule

= Find & Replace
<find-replace>
Useful for cleaning imported data.

Shortcut.

#strong[Ctrl + H]

Interview Example.

Replace

#NormalTok("Ltd.");

with

#NormalTok("Limited");.

#horizontalrule

= Data Validation
<data-validation>
Business Task.

Create a dropdown list for order status.

Possible values.

- Completed
- Pending
- Cancelled

Why it matters.

Prevents inconsistent data entry.

#horizontalrule

= Conditional Formatting
<conditional-formatting>
Task.

Highlight customers who joined this year.

Steps.

Home → Conditional Formatting.

Interview English.

#quote(block: true)[
I used conditional formatting to highlight recent customers.
]

#horizontalrule

= Quick Quality Checks
<quick-quality-checks>
Before analysing any spreadsheet, ask:

- Missing values?
- Duplicate rows?
- Correct dates?
- Correct currency?
- Consistent spelling?

Memory Hook.

#quote(block: true)[
Clean before analysing.
]

#horizontalrule

= Mini Mock Interview
<mini-mock-interview-4>
Interviewer.

#quote(block: true)[
Convert this CSV into a Table.
]

Pause.

Answer.

#horizontalrule

Interviewer.

#quote(block: true)[
Show only London customers.
]

Pause.

Answer.

#horizontalrule

Interviewer.

#quote(block: true)[
Find duplicate cities.
]

Pause.

Answer.

#horizontalrule

= Practice Challenge
<practice-challenge-2>
Using #NormalTok("customers.csv");.

Complete these tasks.

+ Convert to Table.
+ Filter London.
+ Sort by city and date.
+ Freeze headers.
+ Find newest customer.
+ Remove duplicate cities.
+ Create a dropdown list.
+ Highlight recent customers.

Target.

#strong[10 minutes]

Explain every action aloud in English.

#horizontalrule

= Memory Hooks
<memory-hooks-1>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Concept], [Hook],),
  table.hline(),
  [Table], [Smart spreadsheet],
  [Filter], [Hide rows],
  [Sort], [Change order],
  [Freeze], [Keep headers],
  [Validation], [Prevent mistakes],
)
Congratulations.

You completed #strong[Excel Sprint 1]. \> \[!TIP\] \> #strong[Practice with Real Data] \> \> Open the #strong[Evenec Retail Playground] and run every query from this chapter on a real SQLite database. \> \> #box(image("excel/../../../assets/qr/github-playground.svg", width: 0.9375in)) \> \> #strong[Open on GitHub] \> \> #NormalTok("playground/evenec-retail");

= Excel Interview Bible
<excel-interview-bible-1>
= Sprint 2 --- XLOOKUP, INDEX/MATCH & Text Functions
<sprint-2-xlookup-indexmatch-text-functions>
== Find • Clean • Combine • Validate
<find-clean-combine-validate>
Welcome to Sprint 2.

This chapter teaches the Excel functions that recruiters most often expect Junior Data Analysts to know.

We'll continue using the #strong[Evenec Retail Playground].

Main files:

- #NormalTok("customers.csv");
- #NormalTok("orders.csv");
- #NormalTok("products.csv");

#horizontalrule

= Why Lookup Functions Matter
<why-lookup-functions-matter>
Imagine this business question.

#quote(block: true)[
"Find the customer's city using only their Customer ID."
]

This is exactly what lookup functions solve.

Memory Hook.

#quote(block: true)[
IDs connect stories.
]

Just like SQL JOIN.

#horizontalrule

= Interview Question 6
<interview-question-6>
== XLOOKUP Basics
<xlookup-basics>
=== Recruiter Psychology
<recruiter-psychology-65>
This is currently one of the most valuable Excel functions.

=== Business Task
<business-task-26>
Return the customer's city using #NormalTok("customer_id");.

=== Formula
<formula>
#Skylighting(([#NormalTok("=XLOOKUP(A2,Customers[customer_id],Customers[city])");],));
=== Explain It (B2)
<explain-it-b2-31>
#quote(block: true)[
XLOOKUP searches for the customer ID and returns the matching city.
]

=== Memory Hook
<memory-hook-32>
Search.

Match.

Return.

=== Common Mistake
<common-mistake-36>
Mixing lookup and return columns.

#horizontalrule

= Visual
<visual-2>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Customer ID], [Result],),
  table.hline(),
  [101], [London],
  [205], [Leeds],
  [412], [Bristol],
)

#horizontalrule

= Why XLOOKUP Replaced VLOOKUP
<why-xlookup-replaced-vlookup>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([VLOOKUP], [XLOOKUP],),
  table.hline(),
  [Left-to-right only], [Any direction],
  [Column numbers], [Column names],
  [Less flexible], [More flexible],
)
Interview Tip.

If asked which you prefer,

choose XLOOKUP.

#horizontalrule

= Interview Question 7
<interview-question-7>
== Product Price Lookup
<product-price-lookup>
Business Task.

Find product prices from #NormalTok("products.csv");.

Formula.

#Skylighting(([#NormalTok("=XLOOKUP(B2,Products[product_id],Products[price])");],));
Explain.

#quote(block: true)[
The product ID becomes the search key.
]

#horizontalrule

= Missing Matches
<missing-matches>
Business Task.

Display "Not Found" instead of an error.

Formula.

#Skylighting(([#NormalTok("=XLOOKUP(A2,Customers[customer_id],Customers[city],\"Not Found\")");],));
Memory Hook.

Friendly errors improve reports.

#horizontalrule

= INDEX + MATCH
<index-match>
Some companies still ask this.

Understand it.

Don't fear it.

Formula.

#Skylighting(([#NormalTok("=INDEX(Customers[city],MATCH(A2,Customers[customer_id],0))");],));
Explain.

#quote(block: true)[
MATCH finds the row.
]

INDEX returns the value.

Memory Hook.

MATCH finds.

INDEX retrieves.

#horizontalrule

= XLOOKUP vs INDEX/MATCH
<xlookup-vs-indexmatch>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([XLOOKUP], [INDEX/MATCH],),
  table.hline(),
  [Modern], [Classic],
  [Simpler], [More technical],
  [Preferred], [Still common],
)
Interview Advice.

Know both.

Use XLOOKUP when available.

#horizontalrule

= Interview Question 8
<interview-question-8>
== LEFT()
<left>
Business Task.

Extract the first three letters.

Formula.

#Skylighting(([#NormalTok("=LEFT(B2,3)");],));
Example.

London

↓

Lon

#horizontalrule

= RIGHT()
<right>
Business Task.

Extract the last two characters.

Formula.

#Skylighting(([#NormalTok("=RIGHT(B2,2)");],));
Useful for codes.

#horizontalrule

= MID()
<mid>
Business Task.

Extract characters from the middle.

Formula.

#Skylighting(([#NormalTok("=MID(B2,4,5)");],));
Memory Hook.

Start.

Length.

Extract.

#horizontalrule

= LEN()
<len>
Business Task.

Count characters.

Formula.

#Skylighting(([#NormalTok("=LEN(B2)");],));
Interview Example.

Find unusually short names.

#horizontalrule

= TRIM()
<trim>
One of the most practical functions.

Business Task.

Remove extra spaces.

Formula.

#Skylighting(([#NormalTok("=TRIM(B2)");],));
Why Recruiters Like This

Imported data often contains hidden spaces.

#horizontalrule

= UPPER, LOWER, PROPER
<upper-lower-proper>
Standardise text.

Upper.

#Skylighting(([#NormalTok("=UPPER(B2)");],));
Lower.

#Skylighting(([#NormalTok("=LOWER(B2)");],));
Proper.

#Skylighting(([#NormalTok("=PROPER(B2)");],));
Business Example.

Convert

john SMITH

into

John Smith.

#horizontalrule

= TEXT()
<text>
Business Task.

Format dates.

Formula.

#Skylighting(([#NormalTok("=TEXT(A2,\"dd mmm yyyy\")");],));
Example.

2025-01-15

↓

15 Jan 2025

Interview Tip.

Formatting with TEXT doesn't change the original value.

#horizontalrule

= CONCAT()
<concat>
Business Task.

Build a full name.

Formula.

#Skylighting(([#NormalTok("=CONCAT(B2,\" \",C2)");],));
Alternative.

#Skylighting(([#NormalTok("=B2&\" \"&C2");],));
Memory Hook.

Join words.

#horizontalrule

= TEXTJOIN()
<textjoin>
Business Task.

Combine multiple values.

Formula.

#Skylighting(([#NormalTok("=TEXTJOIN(\", \",TRUE,A2:A5)");],));
Very useful for reports.

#horizontalrule

= Cleaning Imported Data
<cleaning-imported-data>
Real companies rarely receive perfect spreadsheets.

Check:

- Extra spaces
- Wrong capitalisation
- Duplicate IDs
- Blank cells

Always clean before analysing.

#horizontalrule

= Interview Question 9
<interview-question-9>
Customer Full Name

Using #NormalTok("customers.csv");.

Create.

John Smith

from:

John

-

Smith

Expected Formula.

#Skylighting(([#NormalTok("=CONCAT([@first_name],\" \",[@last_name])");],));

#horizontalrule

= Interview Question 10
<interview-question-10>
Product Label

Create.

Electronics - £249.99

Formula.

#Skylighting(([#NormalTok("=CONCAT([@category],\" - £\",[@price])");],));
Business Purpose.

More readable reports.

#horizontalrule

= Error Handling
<error-handling>
Instead of showing

#NormalTok("#N/A");

use

#Skylighting(([#NormalTok("=IFERROR(formula,\"Missing\")");],));
Interview English.

#quote(block: true)[
IFERROR makes reports easier to understand.
]

Memory Hook.

Hide technical errors.

#horizontalrule

= Mini Business Case
<mini-business-case>
Imagine you're working at Deliveroo.

The manager asks.

#quote(block: true)[
Build a clean customer list.
]

Expected Workflow.

+ TRIM.
+ PROPER.
+ Remove duplicates.
+ Create Full Name.
+ Format dates.

Notice.

This is exactly how analysts think.

#horizontalrule

= Mini Mock Interview
<mini-mock-interview-5>
Interviewer.

#quote(block: true)[
Find a customer's city.
]

Pause.

Answer.

#horizontalrule

Interviewer.

#quote(block: true)[
Clean imported names.
]

Pause.

Answer.

#horizontalrule

Interviewer.

#quote(block: true)[
Explain XLOOKUP.
]

Pause.

Answer.

#horizontalrule

= Formula Cheat Sheet
<formula-cheat-sheet>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Task], [Formula],),
  table.hline(),
  [Lookup], [XLOOKUP],
  [Alternative], [INDEX/MATCH],
  [First letters], [LEFT],
  [Last letters], [RIGHT],
  [Middle], [MID],
  [Length], [LEN],
  [Clean spaces], [TRIM],
  [Uppercase], [UPPER],
  [Lowercase], [LOWER],
  [Proper Case], [PROPER],
  [Format], [TEXT],
  [Join], [CONCAT],
  [Many values], [TEXTJOIN],
)

#horizontalrule

= Memory Hooks
<memory-hooks-2>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Function], [Hook],),
  table.hline(),
  [XLOOKUP], [Find & Return],
  [MATCH], [Find Position],
  [INDEX], [Bring Value],
  [LEFT], [Beginning],
  [RIGHT], [Ending],
  [MID], [Middle],
  [TRIM], [Clean Spaces],
  [TEXT], [Pretty Format],
)

#horizontalrule

= End-of-Sprint Challenge
<end-of-sprint-challenge-3>
Using the Evenec Retail CSV files, complete these tasks without copying the answers.

+ Lookup customer city.
+ Lookup product price.
+ Replace missing values with "Not Found".
+ Build a full name.
+ Extract the first three letters.
+ Clean extra spaces.
+ Convert names to Proper Case.
+ Format dates.
+ Build a product label.
+ Explain XLOOKUP in English.

Target.

#strong[15 minutes]

Remember.

Companies don't hire people because they know formulas.

They hire people because they can quickly turn messy data into useful information.

Congratulations.

You completed #strong[Excel Sprint 2]. \> \[!TIP\] \> #strong[Practice with Real Data] \> \> Open the #strong[Evenec Retail Playground] and run every query from this chapter on a real SQLite database. \> \> #box(image("excel/../../../assets/qr/github-playground.svg", width: 0.9375in)) \> \> #strong[Open on GitHub] \> \> #NormalTok("playground/evenec-retail");

= Excel Interview Bible
<excel-interview-bible-2>
= Sprint 3 --- Manager's Monday Morning Dashboard
<sprint-3-managers-monday-morning-dashboard>
== Pivot Tables • Pivot Charts • Slicers • Timeline • Power Query
<pivot-tables-pivot-charts-slicers-timeline-power-query>
Monday.

09:00.

Your manager sends one message.

#quote(block: true)[
"I need a sales dashboard in twenty minutes."
]

This chapter teaches exactly that workflow.

You'll build a complete business dashboard using the #strong[Evenec Retail Playground].

Main files:

- orders.csv
- customers.csv
- products.csv

#horizontalrule

= What We'll Build
<what-well-build>
By the end of this sprint you'll have a dashboard showing:

- Total Revenue
- Total Orders
- Average Order Value
- Top Performing City
- Best Selling Category
- Interactive Filters
- Timeline

This looks much closer to a real business report than a classroom exercise.

#horizontalrule

= Dashboard Preview
<dashboard-preview>
Imagine this layout.

Revenue Orders Avg Order Top City

Revenue by City Category Sales

Timeline + Slicers
Keep this mental picture while building.

#horizontalrule

= Step 1 --- Import Data with Power Query
<step-1-import-data-with-power-query>
== Recruiter Psychology
<recruiter-psychology-66>
Many UK companies expect analysts to know basic Power Query.

== Business Task
<business-task-27>
Import #NormalTok("orders.csv");.

=== Steps
<steps-3>
+ Data
+ Get Data
+ From Text/CSV
+ Select #NormalTok("orders.csv");
+ Load to Excel

=== Explain It (B2)
<explain-it-b2-32>
#quote(block: true)[
I imported the CSV using Power Query instead of copying data manually.
]

Memory Hook.

Power Query is the kitchen.

It prepares ingredients before cooking.

#horizontalrule

= Why Power Query Matters
<why-power-query-matters>
Manual work:

- copy
- paste
- repeat

Power Query:

- refresh
- done

Interview Tip.

Mention refreshable workflows.

Recruiters like automation.

#horizontalrule

= Step 2 --- Build Your First Pivot Table
<step-2-build-your-first-pivot-table>
== Business Task
<business-task-28>
Revenue by City.

=== Steps
<steps-4>
Insert

→ Pivot Table

Fields.

Rows:

- city

Values:

- Sum of amount

=== Result
<result-1>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([City], [Revenue],),
  table.hline(),
  [London], [£120,000],
  [Manchester], [£87,000],
)
=== Explain It (B2)
<explain-it-b2-33>
#quote(block: true)[
The Pivot Table automatically groups cities and calculates total revenue.
]

Memory Hook.

Pivot means summarise.

#horizontalrule

= Question 11
<question-11>
Why use a Pivot Table instead of formulas?

Good answer.

#quote(block: true)[
It's faster, easier to update and automatically groups data.
]

#horizontalrule

= Step 3 --- Sort Highest Revenue
<step-3-sort-highest-revenue>
Right-click.

Sort.

Largest to Smallest.

Now the manager immediately sees:

- top city
- weakest city

Business before beauty.

#horizontalrule

= Step 4 --- Create a Pivot Chart
<step-4-create-a-pivot-chart>
Business Task.

Turn revenue into a chart.

Insert

→ Pivot Chart.

Choose.

Clustered Column.

Why this chart?

Easy comparison.

Interview English.

#quote(block: true)[
I chose a column chart because it's easier to compare categories.
]

#horizontalrule

= Chart Psychology
<chart-psychology>
Don't decorate.

Communicate.

Avoid:

- 3D charts
- unnecessary colours
- heavy shadows

Keep charts clean.

#horizontalrule

= Step 5 --- Revenue by Category
<step-5-revenue-by-category>
Use.

products.csv

and

orders.csv.

Create another Pivot Table.

Rows.

Category.

Values.

Revenue.

Business Question.

Which category performs best?

Exactly the type of question hiring managers ask.

#horizontalrule

= Step 6 --- Add Slicers
<step-6-add-slicers>
Business Task.

Filter instantly.

Insert

→ Slicer.

Choose.

- City
- Category

Now one click changes the whole dashboard.

Memory Hook.

Slicers are remote controls.

#horizontalrule

= Step 7 --- Add Timeline
<step-7-add-timeline>
Timeline works with dates.

Insert.

Timeline.

Choose.

Order Date.

Now the manager can switch between:

- month
- quarter
- year

This feels like a professional dashboard.

#horizontalrule

= Step 8 --- Build KPI Cards
<step-8-build-kpi-cards>
Create four KPI boxes.

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([KPI], [Formula],),
  table.hline(),
  [Revenue], [SUM],
  [Orders], [COUNT],
  [Average Order], [AVERAGE],
  [Top City], [Pivot],
)
Arrange them across the top.

Exactly like executive dashboards.

#horizontalrule

= KPI Layout
<kpi-layout>

Revenue Orders Average Top City
Notice how little information creates a strong executive view.

#horizontalrule

= Formatting Like a Professional
<formatting-like-a-professional>
Use.

- white background
- dark text
- consistent spacing
- aligned cards

Good dashboards feel calm.

Not crowded.

#horizontalrule

= Business Case --- Monday Morning
<business-case-monday-morning>
The CEO asks.

#quote(block: true)[
Which city should receive more marketing budget?
]

Workflow.

+ Filter by month.
+ Compare cities.
+ Check category.
+ Present one recommendation.

Don't say.

#quote(block: true)[
"London has the highest SUM."
]

Say.

#quote(block: true)[
"London generated the highest revenue this month, so I'd recommend focusing additional marketing spend there."
]

Business language wins interviews.

#horizontalrule

= Common Dashboard Mistakes
<common-dashboard-mistakes>
Avoid.

- too many colours
- tiny fonts
- inconsistent spacing
- duplicate charts
- manual calculations

Memory Hook.

One question.

One chart.

#horizontalrule

= Mini Mock Interview
<mini-mock-interview-6>
Interviewer.

#quote(block: true)[
Build revenue by city.
]

Pause.

Answer.

#horizontalrule

Interviewer.

#quote(block: true)[
Why choose a Pivot Table?
]

Pause.

Answer.

#horizontalrule

Interviewer.

#quote(block: true)[
Why add slicers?
]

Pause.

Answer.

#horizontalrule

= Dashboard Checklist
<dashboard-checklist>
Before presenting.

- ☐ Tables refreshed
- ☐ Filters working
- ☐ Slicers connected
- ☐ Timeline working
- ☐ KPI cards updated
- ☐ Charts readable
- ☐ No empty cells

Use this checklist before every interview assignment.

#horizontalrule

= Power Query Cheat Sheet
<power-query-cheat-sheet>
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Action], [Purpose],),
  table.hline(),
  [Import CSV], [Load data],
  [Refresh], [Update automatically],
  [Remove Columns], [Clean data],
  [Change Type], [Fix formats],
  [Close & Load], [Return to Excel],
)
Memory Hook.

Power Query prepares.

Pivot Table explains.

#horizontalrule

= End-of-Sprint Challenge
<end-of-sprint-challenge-4>
Using the Evenec Retail Playground.

Build a complete dashboard.

Requirements.

- Revenue KPI
- Orders KPI
- Average Order KPI
- Revenue by City chart
- Revenue by Category chart
- City slicer
- Timeline
- Clean formatting

Target.

#strong[20 minutes]

Explain every decision aloud in English.

Congratulations.

You completed #strong[Excel Sprint 3]. \> \[!TIP\] \> #strong[Practice with Real Data] \> \> Open the #strong[Evenec Retail Playground] and run every query from this chapter on a real SQLite database. \> \> #box(image("excel/../../../assets/qr/github-playground.svg", width: 0.9375in)) \> \> #strong[Open on GitHub] \> \> #NormalTok("playground/evenec-retail");

= Excel Interview Bible
<excel-interview-bible-3>
= Sprint 4 --- Excel Assessment Centre
<sprint-4-excel-assessment-centre>
== Dashboards • Business Cases • Mock Interview • 30-Minute Challenge
<dashboards-business-cases-mock-interview-30-minute-challenge>
Welcome to the final Excel sprint.

Everything you've learned now comes together in one realistic hiring assessment.

Imagine you're interviewing for a #strong[Junior Data Analyst] role at a UK company.

The interviewer sends one message.

#quote(block: true)[
"You have 30 minutes."
]

Your goal isn't just to use Excel.

Your goal is to make business decisions with data.

#horizontalrule

= Assessment Overview
<assessment-overview>
Time limit:

#strong[30 minutes]

Dataset:

- customers.csv
- orders.csv
- products.csv

Deliverables.

- Clean workbook
- Dashboard
- Business insights
- Verbal explanation

Exactly what many UK companies expect.

#horizontalrule

= Before You Start
<before-you-start>
Open.

#NormalTok("evenec_retail_dataset.xlsx");

or import the CSV files.

Check.

- Tables
- Dates
- Filters
- No missing formatting

Memory Hook.

Prepare before analysing.

#horizontalrule

= Assessment Task
<assessment-task>
The Sales Director asks.

#quote(block: true)[
"Tell me how our business performed and where we should focus next."
]

You have.

- 30 minutes.
- One workbook.
- One chance.

#horizontalrule

= Task 1 --- Revenue KPI
<task-1-revenue-kpi>
Create.

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([KPI], [Goal],),
  table.hline(),
  [Total Revenue], [Executive card],
)
Business Question.

How much money did we generate?

Presentation Tip.

Large number.

Minimal text.

#horizontalrule

= Task 2 --- Total Orders
<task-2-total-orders>
Build another KPI.

Use.

- Pivot Table

or

- COUNTA

Interview English.

#quote(block: true)[
This KPI shows the total number of completed orders.
]

#horizontalrule

= Task 3 --- Average Order Value
<task-3-average-order-value>
Formula.

#Skylighting(([#NormalTok("=AVERAGE(amount)");],));
Business Meaning.

How valuable is a typical customer purchase?

#horizontalrule

= KPI Layout
<kpi-layout-1>
Your dashboard should begin with four cards.

Revenue Orders Average Top City
Keep the design simple.

Executives scan.

They don't read.

#horizontalrule

= Task 4 --- Revenue by City
<task-4-revenue-by-city>
Create.

Pivot Table.

Rows.

City.

Values.

Revenue.

Then create.

Pivot Chart.

Business Question.

Where should marketing invest more?

#horizontalrule

= Task 5 --- Best Selling Category
<task-5-best-selling-category>
Use.

Products.

Orders.

Revenue.

Show.

Top category.

Interview Tip.

Don't just show numbers.

Explain why they matter.

#horizontalrule

= Task 6 --- Interactive Dashboard
<task-6-interactive-dashboard>
Add.

- City slicer
- Timeline

Now demonstrate.

London.

↓

Manchester.

↓

Entire year.

This interaction impresses interviewers.

#horizontalrule

= Dashboard Design Rules
<dashboard-design-rules>
Use.

- white background
- dark text
- aligned cards
- consistent spacing

Avoid.

- rainbow colours
- 3D charts
- unnecessary decorations

Professional dashboards feel calm.

#horizontalrule

= Business Case 1 --- CEO Report
<business-case-1-ceo-report>
Question.

Which city deserves more investment?

Expected Thinking.

+ Compare revenue.
+ Look for trends.
+ Recommend one action.

Good Answer.

#quote(block: true)[
London generated the strongest revenue, so I'd prioritise additional marketing there.
]

Notice.

Recommendation.

Not just observation.

#horizontalrule

= Business Case 2 --- Operations
<business-case-2-operations>
Question.

Which category performs worst?

Expected Workflow.

- Pivot
- Sort
- Compare

Business Language.

#quote(block: true)[
This category may need promotional support.
]

#horizontalrule

= Business Case 3 --- Customer Growth
<business-case-3-customer-growth>
Question.

How has customer acquisition changed?

Use.

Signup Date.

Timeline.

Pivot.

Look for trends.

#horizontalrule

= Business Case 4 --- Executive Summary
<business-case-4-executive-summary>
Imagine presenting to the board.

Don't say.

#quote(block: true)[
"The Pivot Table shows…"
]

Instead.

#quote(block: true)[
Revenue increased, London remained our strongest market, and Electronics generated the highest sales.
]

Executives hear conclusions.

Not formulas.

#horizontalrule

= Interview Question 11
<interview-question-11>
Why choose a Pivot Table?

Model Answer (B2)

#quote(block: true)[
It's faster than building multiple formulas and it's easier to update when new data arrives.
]

#horizontalrule

= Interview Question 12
<interview-question-12>
When would you use Power Query?

Model Answer

#quote(block: true)[
I'd use Power Query when I need to clean or refresh imported data automatically.
]

#horizontalrule

= Interview Question 13
<interview-question-13>
Why use XLOOKUP?

Model Answer

#quote(block: true)[
It connects related data without manually copying information.
]

Notice.

Business language.

Always.

#horizontalrule

= Interview Question 14
<interview-question-14>
How do you check spreadsheet quality?

Model Answer

#quote(block: true)[
I check duplicates, missing values, date formats and incorrect text formatting.
]

Memory Hook.

Clean.

Then analyse.

#horizontalrule

= Mini Mock Interview
<mini-mock-interview-7>
Interviewer.

#quote(block: true)[
Show revenue by city.
]

Pause.

Answer.

#horizontalrule

Interviewer.

#quote(block: true)[
Why use slicers?
]

Pause.

Answer.

#horizontalrule

Interviewer.

#quote(block: true)[
Explain your dashboard.
]

Pause.

Answer.

#horizontalrule

= The 30-Minute Assessment
<the-30-minute-assessment>
Set a timer.

Follow this sequence.

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Minutes], [Task],),
  table.hline(),
  [0--5], [Import & prepare],
  [5--10], [KPIs],
  [10--15], [Pivot Tables],
  [15--20], [Charts],
  [20--25], [Slicers & Timeline],
  [25--30], [Final review],
)
Exactly how professionals work.

#horizontalrule

= Assessment Rubric
<assessment-rubric>
Score yourself.

#table(
  columns: 2,
  align: (auto,right,),
  table.header([Skill], [Points],),
  table.hline(),
  [Tables], [10],
  [Filtering], [10],
  [XLOOKUP], [15],
  [Pivot Tables], [20],
  [Charts], [15],
  [Dashboard], [20],
  [Presentation], [10],
)
Total.

#strong[100 points]

Target.

#strong[80+]

#horizontalrule

= Recruiter Red Flags
<recruiter-red-flags-1>
Avoid.

❌ Overcomplicated dashboards.

❌ Tiny fonts.

❌ Manual calculations everywhere.

❌ No explanation.

Recruiters notice communication as much as Excel skills.

#horizontalrule

= B2 Presentation Script
<b2-presentation-script>
Imagine you've just finished.

Say.

#quote(block: true)[
I created an interactive dashboard showing revenue, order volume and customer performance. The Pivot Tables summarise the data automatically, while the slicers allow quick filtering by city and time period. Based on the results, I'd recommend focusing additional marketing on the strongest-performing city.
]

This sounds natural for B2 English.

#horizontalrule

= Emergency Interview Cheat Sheet
<emergency-interview-cheat-sheet>
Remember these.

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Tool], [Purpose],),
  table.hline(),
  [Table], [Organise data],
  [Filter], [Focus],
  [Sort], [Prioritise],
  [XLOOKUP], [Connect],
  [Pivot], [Summarise],
  [Power Query], [Prepare],
  [Slicer], [Interact],
  [Timeline], [Time analysis],
)
Memory Hook.

Prepare.

Summarise.

Explain.

#horizontalrule

= Final Excel Challenge
<final-excel-challenge>
Without copying any solutions.

Build a complete executive dashboard.

Requirements.

- Revenue KPI
- Orders KPI
- Average Order KPI
- Top City
- Revenue by City chart
- Category chart
- Slicer
- Timeline
- Clean formatting
- 60-second presentation

Target.

#strong[30 minutes]

Explain every decision aloud in English.

#horizontalrule

= Excel Bible Complete
<excel-bible-complete>
Congratulations.

You completed all four Excel sprints.

You can now:

- clean imported data;
- build lookup formulas;
- create Pivot Tables;
- build executive dashboards;
- explain your work confidently in English.

Remember.

Companies don't hire analysts because they know Excel.

They hire analysts because they turn spreadsheets into business decisions. \> \[!TIP\] \> #strong[Practice with Real Data] \> \> Open the #strong[Evenec Retail Playground] and run every query from this chapter on a real SQLite database. \> \> #box(image("excel/../../../assets/qr/github-playground.svg", width: 0.9375in)) \> \> #strong[Open on GitHub] \> \> #NormalTok("playground/evenec-retail");

= 
<section-2>
= 
<section-3>



