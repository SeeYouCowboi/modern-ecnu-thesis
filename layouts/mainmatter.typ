#import "@preview/anti-matter:0.1.1": fence, step, core
#import "@preview/i-figured:0.2.4"
#import "../utils/style.typ": 字号, 字体
#import "../utils/custom-numbering.typ": custom-numbering
#import "../utils/custom-heading.typ": heading-display, active-heading, current-heading, heading-content
#import "../utils/indent.typ": fake-par
#import "../utils/unpairs.typ": unpairs
#import "../utils/pagebreak-from-odd.typ": pagebreak-from-odd
#import "../utils/word-counter.typ": *

#let mainmatter(
  // documentclass 传入参数
  doctype: "master",
  twoside: false,
  fonts: (:),
  // 其他参数
  leading: 1.5 * 15.6pt - 0.7em,
  spacing: 1.5 * 15.6pt - 0.7em,
  justify: true,
  first-line-indent: 2em,
  // 浮动于页顶或页底的上下间距
  figure-clearance: 32pt,
  figure-caption-spacing: 0.4em,
  numbering: custom-numbering.with(first-level: "第一章 ", depth: 4, "1.1 "),
  // 正文字体与字号参数
  text-args: auto,
  // 标题字体与字号
  heading-font: auto,
  heading-size: (字号.三号, 字号.四号,),
  heading-weight: ("regular",),
  heading-above: (2 * 15.6pt - 0.7em, 2 * 15.6pt - 0.7em),
  heading-below: (2 * 15.6pt, 2 * 15.6pt - 0.7em),
  heading-pagebreak: (true, false),
  heading-align: (center, auto),
  // 页眉
  header-render: auto,
  header-vspace: 0em,
  display-header: false,
  stroke-width: 0.75pt,
  reset-footnote: true,
  // caption 的 separator
  separator: "  ",
  // caption 样式
  caption-style: text.with(font: 字体.楷体, style: "italic", size: 字号.小四),
  caption-size: 字号.小四,
  // figure 计数
  show-figure: i-figured.show-figure,
  // equation 计数
  show-equation: i-figured.show-equation,
  ..args,
  it,
) = {

  // 0.  标志前言结束
  {
    // TODO: 用了一个很 tricky 的方式防止前言最后一页的页码打印出来，可能有更优解
    set page(footer: { text(size: 0pt, ".") })
    v(-1pt)
    fence()
  }

  set page(footer: context {
    set text(size: 字号.五号)
    let p = core.inner-counter().get().at(0)
    if doctype == "bachelor" {
      align(center)[
        #core.inner-counter().display()
      ]
    } else if calc.rem(p, 2) == 1 {
      h(1fr)
      text(core.inner-counter().display())
    } else {
      text(core.inner-counter().display())
      h(1fr)
    }
  })


  // 1.  默认参数
  fonts = 字体 + fonts
  if (text-args == auto) {
    text-args = (font: fonts.宋体, size: 字号.小四)
  }
  // 1.1 字体与字号
  if (heading-font == auto) {
    heading-font = (fonts.黑体,)
  }
  // 1.2 处理 heading- 开头的其他参数
  let heading-text-args-lists = args.named().pairs()
    .filter((pair) => pair.at(0).starts-with("heading-"))
    .map((pair) => (pair.at(0).slice("heading-".len()), pair.at(1)))

  // 2.  辅助函数
  let array-at(arr, pos) = {
    arr.at(calc.min(pos, arr.len()) - 1)
  }

  // 3.  设置基本样式
  // 3.1 文本和段落样式
  set text(..text-args)
  set par(
    leading: leading,
    justify: justify,
    first-line-indent: first-line-indent
  )
  // show par: set block(spacing: spacing)
  show raw: set text(font: fonts.等宽)
  show raw.where(block: true): set par(leading: 1em)
  // 3.2 脚注样式
  show footnote.entry: set text(font: fonts.宋体, size: 字号.五号)
  // 3.3 设置 figure 的编号
  show heading: i-figured.reset-counters
  show figure: show-figure
  // 3.4 设置 equation 的编号和假段落首行缩进
  show math.equation.where(block: true): show-equation
  show math.equation.where(block: true): it => {
    it
    fake-par
  }
  // 3.5 表格表头置顶 + 不用冒号用空格分割 + 样式
  show figure.where(
    kind: table
  ): set figure.caption(position: top)
  set figure.caption(separator: separator)
  show figure.caption: caption-style
  show figure.caption: set text(size: caption-size, font: fonts.楷体)
  show figure.caption: set par(leading: 1.25em)
  show figure.caption: c => block(inset: (top: figure-caption-spacing, bottom: figure-caption-spacing))[
    #text(font: fonts.黑体, weight: "bold", style: "normal")[
      #c.supplement #context c.counter.display(c.numbering)
      ]
      #c.separator#c.body
  ]
  show figure.where(placement: none): it => {
    v(figure-clearance / 6)
    it
    fake-par
  }
  set place(clearance: figure-clearance)
   // 3.6 优化列表显示
  //     术语列表 terms 不应该缩进
  show terms: set par(first-line-indent: 0pt)
  show terms.item: it => block[
    #set par(hanging-indent: 2em)
    #text(font: fonts.黑体)[#it.term] #h(0.5em) #it.description
  ]
  // 3.7 处理链接样式
  show link: it => {
    set text(fill: color.rgb("#0066CC"))
    it
  }
  set table(stroke: 0.5pt + black)

  // 4.  处理标题
  // 4.1 设置标题的 Numbering
  set heading(numbering: numbering)
  // 4.2 设置字体字号并加入假段落模拟首行缩进
  show heading: it => {
    set text(
      font: array-at(heading-font, it.level),
      size: array-at(heading-size, it.level),
      weight: array-at(heading-weight, it.level),
      ..unpairs(heading-text-args-lists
        .map((pair) => (pair.at(0), array-at(pair.at(1), it.level))))
    )
    set block(
      above: array-at(heading-above, it.level),
      below: array-at(heading-below, it.level),
    )
    it
    fake-par
  }
  // 4.3 标题居中与自动换页
  show heading: it => {
    if (array-at(heading-pagebreak, it.level)) {
      // 如果打上了 no-auto-pagebreak 标签，则不自动换页
      if ("label" not in it.fields() or str(it.label) != "no-auto-pagebreak") {
        pagebreak(weak: true)
      }
    }
    if (array-at(heading-align, it.level) != auto) {
      set align(array-at(heading-align, it.level))
      it
    } else {
      it
    }
  }

  // 重置 footnote 计数器
  if reset-footnote {
    counter(footnote).update(0)
  }

  // 5.  处理页眉
  set page(..(if display-header {
    (
      header: {
        // needed by anti-matter
        if header-render == auto {
          heading-content(doctype: doctype, fonts: fonts)
        } else {
          header-render(loc)
        }
        v(header-vspace)

      }
    )
  } else {
    (
      header: {
        // 重置 footnote 计数器
        if reset-footnote {
          counter(footnote).update(0)
        }
      }
    )
  }))

  // 字数统计（正文 + 附录）
  //     typst query main.typ '<total-words>' 2>/dev/null --field value --one

  context [
    #metadata(state("total-words-cjk").final()) <total-words>
    #metadata(state("total-characters").final()) <total-chars>
  ]

  it
  // 正文结束标志，不可缺少
  // 这里放在附录后面，使得页码能正确计数
  fence()
}