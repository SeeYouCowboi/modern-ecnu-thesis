#import "style.typ": 字号
#import "@preview/anti-matter:0.1.1": step, core
// 展示一个标题
#let heading-display(it) = {
  if it != none {
    if it.has("numbering") and it.numbering != none {
      numbering(it.numbering, ..counter(heading).at(it.location()))
      [ ]
    }
    it.body
  } else {
    ""
  }
}

// 获取当前激活的 heading，参数 prev 用于标志优先使用之前页面的 heading
#let active-heading(level: 1, prev: true) = {
  // 之前页面的标题
  let prev-headings = query(selector(heading.where(level: level)).before(here()))
  // 当前页面的标题
  let cur-headings = query(selector(heading.where(level: level)).after(here()))
  .filter(it => it.location().page() == here().page())
  if prev-headings.len() == 0 and cur-headings.len() == 0 {
    return none
  } else {
    if prev {
      if prev-headings.len() != 0 {
        return prev-headings.last()
      } else {
        return cur-headings.first()
      }
    } else {
      if cur-headings.len() != 0 {
        return cur-headings.first()
      } else {
        return prev-headings.last()
      }
    }
  }
}

// 获取当前页面的标题
#let current-heading(level: 1) = {
  // 当前页面的标题
  let cur-headings = query(selector(heading.where(level: level)).after(here()))
  .filter(it => it.location().page() == here().page())
  if cur-headings.len() != 0 {
    return cur-headings.first()
  } else {
    return none
  }
}

// 页眉内容
#let heading-content(doctype: "master", fonts: (:), stroke-width: 0.5pt) = {
  if doctype == "bachelor" {
    set text(font: fonts.黑体, size: 字号.五号)
    set align(center)
    let title = state("title")
    stack(context title.get(), v(0.5em), line(length: 100%, stroke: stroke-width + black))
    step()
  } else {
    step()
    context {
      let outerpage = core.outer-counter().get().at(0)
      let innerpage = core.inner-counter().get().at(0)
      let page = if innerpage == 0 { outerpage } else { innerpage }
      // 获取当前页面的一级标题
      let cur-heading = current-heading(level: 1)
      let first-level-heading = if cur-heading != none { heading-display(cur-heading) } else { heading-display(active-heading(level: 1)) }
      let docinfo = "华东师范大学" + if doctype == "master" { "硕士" } else { "博士" } + "学位论文"
      set text(font: fonts.宋体, size: 字号.五号)
      stack(
        if calc.rem(page, 2) == 1 {
          first-level-heading + h(1fr) + docinfo
        } else {
          docinfo + h(1fr) + first-level-heading
        },
        v(0.5em),
        line(length: 100%, stroke: stroke-width + black),
        v(0.15em),
        line(length: 100%, stroke: stroke-width + black),
      )

    }
  }
}