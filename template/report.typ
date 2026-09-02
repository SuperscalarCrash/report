#import "@preview/tablex:0.0.9": cellx, colspanx, hlinex, rowspanx, tablex, vlinex
#import "@preview/showybox:2.0.4": showybox

#let state-course = state("course", none)
#let state-author = state("author", none)
#let state-school-id = state("school_id", none)
#let state-date = state("date", none)
#let state-theme = state("theme", none)
#let state-block-theme = state("block_theme", none)

#let _underlined_cell(content, color: black) = {
  tablex(
    align: center + horizon,
    stroke: 0pt,
    inset: 0.75em,
    map-hlines: h => {
      if (h.y > 0) {
        (..h, stroke: 0.5pt + color)
      } else {
        h
      }
    },
    columns: 1fr,
    content,
  )
}

#let asset-zju-logo = image("zjulogo.svg", width: 80%)

#let project(
  theme: "project",
  block_theme: "default",
  course: "<course>",
  title: "<title>",
  header-title: none,
  title_size: 3em,
  cover_image_padding: 1em,
  cover_image_size: none,
  semester: "<semester>",
  name: none,
  author: none,
  school_id: none,
  date: none,
  college: none,
  place: none,
  teacher: none,
  major: none,
  cover_comments: none,
  cover_comments_size: 1.25em,
  cover_cells: none,
  language: none,
  table_of_contents: none,
  font_serif: (
    "New Computer Modern",
    "Songti SC",
  ),
  font_sans_serif: (
    "Heiti SC",
    "Source Han Sans SC",
  ),
  font_title: (
    "New Computer Modern",
    "Heiti SC",
  ),
  font_mono: "JetBrains Mono",
  body,
) = {
  font_mono = (font_mono, ..font_sans_serif)
  if (theme == "lab") {
    if (cover_image_size == none) {
      cover_image_size = 48%
    }
  } else if (theme == "project") {
    if (cover_image_size == none) {
      cover_image_size = 50%
    }
    if (language == none) {
      language = "en"
    }
    if (table_of_contents == none) {
      table_of_contents = true
    }
  }
  // fallback
  if (language == none) {
    language = "cn"
  }
  if (table_of_contents == none) {
    table_of_contents = false
  }

  set document(author: (author), title: title)

  set page(numbering: "1", number-align: center)

  set text(font: font_serif, lang: language, size: 12pt)
  show raw: set text(font: font_mono)
  show math.equation: set text(weight: 400)

  set par(spacing: 1.2em, leading: 0.75em)

  // Update global state
  state-course.update(course)
  state-author.update(author)
  state-school-id.update(school_id)
  state-date.update(date)
  state-theme.update(theme)
  state-block-theme.update(block_theme)

  // Cover Page
  if (theme == "project") {
    v(1fr)
    box(
      width: 100%,
      {
        set align(center)

        v(cover_image_padding)
        block(width: cover_image_size, asset-zju-logo)
        v(cover_image_padding)

        par(text(font: font_title, size: 2em, weight: 700, course))

        v(1em)

        par(text(font: font_title, size: 1.5em, weight: 400, title))

        if cover_cells != none {
          v(2em)
          align(
            center,
            box(width: 75%)[
              #set text(size: 1.2em)
              #tablex(
                columns: (6.5em + 5pt, 1fr),
                align: center + horizon,
                stroke: 0pt,
                inset: 1pt,
                map-cells: cell => {
                  if (cell.x == 0) {
                    _underlined_cell([#cell.content#"："], color: white)
                  } else {
                    _underlined_cell(cell.content, color: black)
                  }
                },
                ..cover_cells.flatten(),
              )
            ],
          )
        } else if cover_comments == none {
          text(cover_comments_size)[
            #v(1em)
            #if (author != none) [
              Author: #author
            ]

            Date: #date

            #semester Semester
          ]
        } else {
          cover_comments
        }
      },
    )
    v(4fr)
    pagebreak()
  } else if (theme == "nocover") {
    // no cover page
  } else {
    set text(fill: red, size: 3em, weight: 900)
    align(center)[Theme not found!]
    pagebreak()
  }

  if (table_of_contents) {
    {
      set align(center)
      set par(leading: 1em)
      outline(title: text(1.1em, "目录"), depth: 3, indent: auto)
    }
    pagebreak()
  }

  // Main body pages: section-aware header and ruled footer with "1 / 1" page numbers.
  set page(
    numbering: "1",
    header: context {
      let current = level => {
        let before = query(selector(heading.where(level: level)).before(here())).filter(hd => hd.numbering != none)
        if before.len() > 0 {
          before.last()
        } else {
          let on-page = query(selector(heading.where(level: level)).after(here())).filter(hd => (
            hd.numbering != none and hd.location().page() == here().page()
          ))
          if on-page.len() > 0 { on-page.first() }
        }
      }
      let h1 = current(1)
      let h2 = current(2)
      let left-sec = if h2 != none {
        let nums = counter(heading).at(h2.location())
        [#numbering("1.1", ..nums) #h(0.6em) #h2.body]
      }
      let right-sec = if h1 != none {
        let nums = counter(heading).at(h1.location())
        [#numbering("1", ..nums) #h(0.6em) #h1.body]
      }
      text(size: 10pt)[
        #grid(
          columns: (1fr, auto, 1fr),
          align(left, left-sec),
          align(center, if header-title != none { header-title } else { title }),
          align(right, right-sec),
        )
        #v(-0.5em)
        #line(length: 100%, stroke: 0.5pt)
      ]
    },
    footer: context {
      set align(center)
      text(size: 10pt)[
        #line(length: 100%, stroke: 0.5pt)
        #v(-0.2em)
        #counter(page).display("1 / 1", both: true)
      ]
    },
  )

  set par(justify: true)
  set table(align: center + horizon, stroke: 0.5pt)

  show raw.where(block: false): it => box(
    it,
    fill: luma(240),
    stroke: luma(160) + 0.5pt,
    inset: (left: 0.25em, right: 0.25em),
    outset: (top: 0.35em, bottom: 0.35em),
    radius: 0.35em,
  )

  // Emphasis semantic: _..._ renders bold red instead of italic
  show emph: it => text(fill: rgb(255, 0, 0), weight: "bold", it.body)

  set heading(
    numbering: (..args) => {
      let nums = args.pos()
      if nums.len() == 1 {
        return numbering("1 ", ..nums)
      } else {
        return numbering("1.1.", ..nums)
      }
    },
  )
  show heading: it => {
    block(above: 1.8em, below: 0em, it)
    par(leading: 1.5em)[#text(size: 0.0em)[#h(0.0em)]]
  }
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set align(center)
    block(above: 1.5em, below: 1.5em, it.body)
  }
  if (theme == "lab") {
    set heading(
      numbering: (..args) => {
        let nums = args.pos()
        if nums.len() == 1 {
          return none
        } else if nums.len() == 2 {
          return numbering("一、", ..nums.slice(1))
        } else {
          return numbering("1.1.", ..nums.slice(1))
        }
      },
    )

    show heading.where(level: 1): it => block(
      width: 100%,
      above: 2em,
      below: 1.5em,
      {
        set align(center)
        set text(size: 1.2em)
        it
      },
    )

    body
  } else {
    body
  }
}

#let codex(code, lang: none, filename: none, size: 1em, stroke: 0.5pt + luma(150), inset: 1em, radius: 0.25em) = {
  if code.len() > 0 {
    if code.ends-with("\n") {
      code = code.slice(0, code.len() - 1)
    }
  } else {
    code = "// code not found"
  }

  set text(size: size)
  set align(left)
  if filename != none {
    block(
      width: 100%,
      stroke: stroke,
      radius: radius,
      clip: true,
      stack(
        {
          block(width: 100%, inset: inset, filename)
        },
        line(length: 100%, stroke: stroke),
        block(width: 100%, inset: inset, raw(lang: lang, block: true, code)),
      ),
    )
  } else {
    block(width: 100%, stroke: stroke, radius: radius, inset: inset, raw(lang: lang, block: true, code))
  }
}

#let table3(
  // 三线表
  ..args,
  inset: 0.5em,
  stroke: 0.5pt,
  align: center + horizon,
  columns: 1fr,
) = {
  tablex(
    columns: 1fr,
    inset: 0pt,
    stroke: 0pt,
    map-hlines: h => {
      if (h.y > 0) {
        (..h, stroke: (stroke * 2) + black)
      } else {
        h
      }
    },
    tablex(
      ..args,
      inset: inset,
      stroke: stroke,
      align: align,
      columns: columns,
      map-hlines: h => {
        if (h.y == 0) {
          (..h, stroke: (stroke * 2) + black)
        } else if (h.y == 1) {
          (..h, stroke: stroke + black)
        } else {
          (..h, stroke: 0pt)
        }
      },
      auto-vlines: false,
    ),
  )
}

#let figurex(img, caption) = {
  show figure.caption: it => {
    set text(size: 0.9em, fill: luma(100), weight: 700)
    it
    v(0.1em)
  }
  set figure.caption(separator: ":")
  figure(
    img,
    caption: [
      #set text(weight: 400)
      #caption
    ],
  )
}
