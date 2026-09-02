// credit: https://github.com/yhwu-is

#import "@preview/touying:0.5.5": *
#import "@preview/cetz:0.3.2"
#import "@preview/fletcher:0.5.2" as fletcher: edge, node
#import "@preview/ctheorems:1.1.3": *
#import "@preview/numbly:0.1.0": numbly

/// Default slide function for the presentation.
///
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
///
/// - repeat (int, auto): is the number of subslides. The default is `auto`, allowing touying to automatically calculate the number of subslides. The `repeat` argument is required when using `#slide(repeat: 3, self => [ .. ])` style code to create a slide, as touying cannot automatically detect callback-style `uncover` and `only`.
///
/// - setting (dictionary): is the setting of the slide, which can be used to apply set/show rules for the slide.
///
/// - composer (array, function): is the layout composer of the slide, allowing you to define the slide layout.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - bodies (arguments): is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  align: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  if align != auto {
    self.store.align = align
  }
  let header(self) = {
    set text(font: ("Libertinus Serif", "Source Han Serif SC"))
    set std.align(top)
    grid(
      rows: (auto, auto),
      row-gutter: 3mm,
      if self.store.progress-bar {
        components.progress-bar(height: 2pt, self.colors.primary, self.colors.tertiary)
      },
      block(
        inset: (x: .6em),
        components.left-and-right(
          text(fill: self.colors.primary, weight: "bold", size: 1.3em, utils.call-or-display(self, self.store.header)),
          text(fill: self.colors.primary.lighten(65%), utils.call-or-display(self, self.store.header-right)),
        ),
      ),
    )
  }
  let footer(self) = {
    set text(font: ("Libertinus Serif", "Source Han Serif SC"))
    set std.align(center + bottom)
    set text(size: .6em, weight: "semibold")
    {
      let cell(..args, it) = components.cell(
        ..args,
        inset: 1mm,
        std.align(horizon, text(fill: white, it)),
      )
      show: block.with(width: 100%, height: auto)
      grid(
        columns: self.store.footer-columns,
        rows: 1.5em,
        cell(fill: self.colors.primary, utils.call-or-display(self, self.store.footer-a)),
        cell(fill: self.colors.primary.lighten(45%), utils.call-or-display(self, self.store.footer-b)),
        cell(fill: self.colors.primary, utils.call-or-display(self, self.store.footer-c)),
      )
    }
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  let new-setting = body => {
    show: std.align.with(self.store.align)
    show: setting
    body
  }
  touying-slide(self: self, config: config, repeat: repeat, setting: new-setting, composer: composer, ..bodies)
})


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: yhwu-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.school,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle])
/// ```
///
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
///
/// - extra (string, none): is the extra information for the slide. This can be passed to the `title-slide` function to display additional information on the title slide.
#let title-slide(
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
  )
  let info = self.info + args.named()
  info.authors = {
    let authors = if "authors" in info {
      info.authors
    } else {
      info.author
    }
    if type(authors) == array {
      authors
    } else {
      (authors,)
    }
  }
  let body = {
    if info.logo != none {
      place(bottom + right, text(info.logo, size: 1.2em), dy: -1em)
    }
    std.align(
      center,
      {
        pad(
          top: 2em,
          block(
            breakable: false,
            {
              if info.subtitle != none {
                text(
                  size: 1.4em,
                  fill: self.colors.primary,
                  info.subtitle,
                  font: "Source Han Serif SC",
                  weight: "extrabold",
                )
                parbreak()
              }
              text(
                size: 2.2em,
                fill: self.colors.primary,
                info.title,
                font: ("Libertinus Serif", "Heiti SC"),
                weight: "extrabold",
              )
            },
          ),
        )
      },
    )
    v(1em)
    line(length: 100%, stroke: .4em + self.colors.primary)
    v(-0.8em)
    line(length: 65%, stroke: .4em + rgb("#FF4500"))
    v(1.5em)
    pad(
      left: 2em,
      grid(
        columns: (1fr,) * calc.min(info.authors.len(), 3),
        column-gutter: 1em,
        row-gutter: 1em,
        ..info.authors.map(author => text(
          size: 1.2em,
          fill: self.colors.neutral-darkest,
          author,
          font: "Kaiti SC",
          weight: "extrabold",
        )),
        v(-0.6em),
        if info.institution != none {
          parbreak()
          text(size: 1.2em, info.institution, font: "Kaiti SC", weight: "extrabold")
        },
        v(-0.6em),
        if info.at("extra", default: none) != none {
          parbreak()
          text(size: 1.2em, info.at("extra"), font: "Kaiti SC", weight: "bold")
        },
        v(-0.6em),
        if info.date != none {
          parbreak()
          text(size: 1.2em, utils.display-info-date(self))
        },
      ),
    )
  }
  touying-slide(self: self, body)
})

/// New section slide for the presentation.
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more configurations, you can use `utils.merge-dicts` to merge them.
///
/// - leading (length): The leading of paragraphs in the outline. Default is `50pt`.
#let new-section-slide(config: (:), leading: 50pt, body) = touying-slide-wrapper(self => {
  set text(size: 30pt, fill: self.colors.neutral-darkest)
  let body = {
    grid(
      columns: (0.8fr, 1fr),
      rows: 1fr,
      align(
        center + horizon,
        {
          context {
            if text.lang == "zh" {
              text(
                size: 80pt,
                weight: "bold",
                fill: self.colors.primary,
                [#text(size: 36pt, font: ("Libertinus Serif", "Source Han Serif SC"))[CONTENT]\ 目录],
              )
            } else {
              text(
                size: 48pt,
                weight: "bold",
                [CONTENT],
              )
            }
          }
        },
      ),
      pad(
        left: 10%,
        top: -2.5em,
        align(
          left + horizon,
          {
            set par(leading: 0.5em)
            set text(weight: "bold", font: ("Libertinus Serif", "Source Han Serif SC"))
            components.custom-progressive-outline(
              depth: 1,
              alpha: 30%,
              indent: (-1em,),
              numbered: (true,),
              vspace: (1.0em,),
            )
          },
        ),
      ),
    )
  }
  touying-slide(self: self, config: config, body)
})

// #let new-section-slide(config: (:), level: 1, numbered: true, body) = touying-slide-wrapper(self => {
//   let slide-body = {
//     set std.align(horizon)
//     show: pad.with(20%)
//     set text(size: 1.5em, fill: self.colors.primary, weight: "bold")
//     stack(
//       dir: ttb,
//       spacing: .65em,
//       utils.display-current-heading(level: level, numbered: numbered),
//       block(
//         height: 2pt,
//         width: 100%,
//         spacing: 0pt,
//         components.progress-bar(height: 2pt, self.colors.primary, self.colors.primary-light),
//       ),
//     )
//     body
//   }
//   touying-slide(self: self, config: config, slide-body)
// })

/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
///
/// - background-color (color, none): is the background color of the slide. Default is the primary color.
///
/// - background-img (string, none): is the background image of the slide. Default is none.
#let focus-slide(config: (:), background-color: none, background-img: none, body) = touying-slide-wrapper(self => {
  let background-color = if background-img == none and background-color == none {
    rgb(self.colors.primary)
  } else {
    background-color
  }
  let args = (:)
  if background-color != none {
    args.fill = background-color
  }
  if background-img != none {
    args.background = {
      set image(fit: "stretch", width: 100%, height: 100%)
      background-img
    }
  }
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(margin: 1em, ..args),
  )
  set text(fill: self.colors.neutral-lightest, weight: "bold", size: 2em)
  touying-slide(self: self, std.align(horizon, body))
})


// Create a slide where the provided content blocks are displayed in a grid and coloured in a checkerboard pattern without further decoration. You can configure the grid using the rows and `columns` keyword arguments (both default to none). It is determined in the following way:
///
/// - If `columns` is an integer, create that many columns of width `1fr`.
/// - If `columns` is `none`, create as many columns of width `1fr` as there are content blocks.
/// - Otherwise assume that `columns` is an array of widths already, use that.
/// - If `rows` is an integer, create that many rows of height `1fr`.
/// - If `rows` is `none`, create that many rows of height `1fr` as are needed given the number of co/ -ntent blocks and columns.
/// - Otherwise assume that `rows` is an array of heights already, use that.
/// - Check that there are enough rows and columns to fit in all the content blocks.
///
/// That means that `#matrix-slide[...][...]` stacks horizontally and `#matrix-slide(columns: 1)[...][...]` stacks vertically.
///
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
#let matrix-slide(config: (:), columns: none, rows: none, ..bodies) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em),
  )
  touying-slide(
    self: self,
    config: config,
    composer: components.checkerboard.with(columns: columns, rows: rows),
    ..bodies,
  )
})

/// yhwu's theme.
///
/// Example:
///
/// ```typst
/// #show: yhwu-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// The default colors:
///
/// ```typ
/// config-colors(
///   primary: rgb("#04364A"),
///   secondary: rgb("#176B87"),
///   tertiary: rgb("#448C95"),
///   neutral-lightest: rgb("#ffffff"),
///   neutral-darkest: rgb("#000000"),
/// )
/// ```
///
/// - aspect-ratio (string): is the aspect ratio of the slides. Default is `16-9`.
///
/// - align (alignment): is the alignment of the slides. Default is `top`.
///
/// - progress-bar (boolean): is whether to show the progress bar. Default is `true`.
///
/// - header (content, function): is the header of the slides. Default is `utils.display-current-heading(level: 2)`.
///
/// - header-right (content, function): is the right part of the header. Default is `self.info.logo`.
///
/// - footer-columns (tuple): is the columns of the footer. Default is `(25%, 1fr, 25%)`.
///
/// - footer-a (content, function): is the left part of the footer. Default is `self.info.author`.
///
/// - footer-b (content, function): is the middle part of the footer. Default is `self.info.short-title` or `self.info.title`.
///
/// - footer-c (content, function): is the right part of the footer. Default is `self => h(1fr) + utils.display-info-date(self) + h(1fr) + context utils.slide-counter.display() + " / " + utils.last-slide-number + h(1fr)`.
#let yhwu-theme(
  aspect-ratio: "4-3",
  align: horizon,
  progress-bar: true,
  header: utils.display-current-heading(level: 2, numbered: false),
  header-right: self => utils.display-current-heading(level: 1, numbered: false) + h(.3em),
  footer-columns: (25%, 1fr, 25%),
  footer-a: self => self.info.author,
  footer-b: self => if self.info.short-title == auto {
    self.info.title
  } else {
    self.info.short-title
  },
  footer-c: self => {
    h(1fr)
    utils.display-info-date(self)
    h(1fr)
    context utils.slide-counter.display() + " / " + utils.last-slide-number
    h(1fr)
  },
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 2em, bottom: 1.25em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(size: 22pt)
        show heading: set text(fill: self.colors.primary)

        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: rgb("#00008B"),
      secondary: rgb("#7B68EE"),
      tertiary: rgb("#FF0000"),
      quaternary: rgb("#00FF00"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    // save the variables for later use
    config-store(
      align: align,
      progress-bar: progress-bar,
      header: header,
      header-right: header-right,
      footer-columns: footer-columns,
      footer-a: footer-a,
      footer-b: footer-b,
      footer-c: footer-c,
    ),
    ..args,
  )

  body
}

#let _tblock(self: none, title: none, color: rgb("#00008B"), it) = {
  grid(
    columns: 1,
    row-gutter: 0pt,
    block(
      fill: color,
      width: 100%,
      radius: (top: 6pt),
      inset: (top: 0.4em, bottom: 0.3em, left: 0.5em, right: 0.5em),
      text(fill: self.colors.neutral-lightest, weight: "bold", title),
    ),

    rect(
      fill: gradient.linear(color, color.lighten(90%), angle: 90deg),
      width: 100%,
      height: 4pt,
    ),

    block(
      fill: color.lighten(90%),
      width: 100%,
      radius: (bottom: 6pt),
      inset: (top: 0.4em, bottom: 0.5em, left: 0.5em, right: 0.5em),
      it,
    ),
  )
}

#let thm_counter = counter("thm")
#let def_counter = counter("def")
#let prop_counter = counter("prop")
#let lem_counter = counter("lem")
#let cor_counter = counter("cor")
#let ex_counter = counter("ex")

#let thmblock(type: "thm", title: "定理", numbering: none, color: rgb("#00008B"), it) = {
  if (type == "thm") {
    if numbering == true {
      thm_counter.step()
      title = title + context thm_counter.display()
    }
    touying-fn-wrapper(_tblock.with(title: title, color: color, it))
  } else if (type == "def") {
    if numbering == true {
      def_counter.step()
      title = "定义" + context def_counter.display()
    } else {
      title = "定义"
    }
    touying-fn-wrapper(_tblock.with(title: title, color: rgb("#8B0000"), it))
  } else if (type == "prop") {
    if numbering == true {
      prop_counter.step()
      title = "命题" + context prop_counter.display()
    } else {
      title = "命题"
    }
    touying-fn-wrapper(_tblock.with(title: title, color: color, it))
  } else if (type == "lem") {
    if numbering == true {
      lem_counter.step()
      title = "引理" + context lem_counter.display()
    } else {
      title = "引理"
    }
    touying-fn-wrapper(_tblock.with(title: title, color: rgb("#8A2BE2"), it))
  } else if (type == "cor") {
    if numbering == true {
      cor_counter.step()
      title = "推论" + context cor_counter.display()
    } else {
      title = "推论"
    }
    touying-fn-wrapper(_tblock.with(title: title, color: rgb("#00BFFF"), it))
  } else if (type == "ex") {
    if numbering == true {
      ex_counter.step()
      title = "例" + context ex_counter.display()
    } else {
      title = "例"
    }
    touying-fn-wrapper(_tblock.with(title: title, color: rgb("#808080"), it))
  }
}

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)
