#let tarea(
  course: none,
  title: none,
  professor: none,
  date: none,
  authors: (),
  doc,
) = {
  let fontsize = 12pt

  let margin = 2.54cm
  let margin_side_ratio = 2%
  let caratula_margin_ratio = 2%

  let escudos_ratio = 70%

  // Temp fix for 'lang: es' not working on datetime()
  let months = ("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre")

  //================================ {General} =================================
  set page(
    paper: "a4",
    margin: (
      rest: margin,
      inside: margin + margin_side_ratio,
      outside: margin - margin_side_ratio,
    ),
    // header: align(right + horizon)[
    //   _ #title _
    // ],
    // numbering: "1",
    // columns: 2,
  )
  set text(
    size: fontsize,
    lang: "es",
    region: "pe",
  )
  set par(
    first-line-indent: 1.2em,
    spacing: 2em,
    leading: 0.65em,
    justify: true,
  )
  set heading(
    numbering: "1.",
  )
  set document()

  //=============================== {Overrides} ================================
  show outline.entry.where(
    level: 1
  ): set block(above: 1.4em)

  show heading.where(
    level: 1
  ): set block(below: 1em)

  set list(
    indent: 1.2em,
    spacing: 0.85em,
  )

  set enum(
    indent: 1.2em,
    spacing: 0.85em,
  )

  // TODO: https://discord.com/channels/1054443721975922748/1388236879115321404
  set enum(
    full: true,
    numbering: (..nums) => {
      let default_exp = "1."
      let numbers = nums.pos()
      if numbers.len() == 1 {
        numbering("1.", ..numbers)
      } else if numbers.len() == 2 {
        numbering("a)", numbers.at(1))
      } else if numbers.len() == 3 {
        numbering("(i)", numbers.at(2))
      } else {
        numbering(default_exp, numbers.at(numbers.len()-1))
      }
    }
  )

  // show heading: it => [
  //   #set align(center)
  //   #set text(13pt, weight: "regular")
  //   #block(smallcaps(it.body))
  // ]
  //
  // show heading.where(
  //   level: 2
  // ): it => text(
  //   size: 11pt,
  //   weight: "regular",
  //   style: "italic",
  //   it.body + [.],
  // )

  //================================ {Caratula} ================================
  page(
    margin: (
      rest: margin + caratula_margin_ratio,
    )
  )[
    #place(
      float: true,
      auto,
      scope: "parent",
      clearance: 2em,
    )[
      #set par(first-line-indent: 0em)

      #text(fontsize*1.35)[
        UNIVERSIDAD NACIONAL DE SAN ANTONIO ABAD DEL CUSCO
      ]

      #text(fontsize*1.4)[
        FACULTAD DE INGENIERÍA ELÉCTRICA, ELECTRÓNICA, INFORMÁTICA Y MECÁNICA
      ]

      #text(fontsize*1.26)[
        ESCUELA PROFESIONAL DE INGENIERÍA INFORMÁTICA Y DE SISTEMAS
      ]

      #grid(
        columns: (1fr, 1fr),
        figure(
          image("./escudos/unsaac_logo.png", width: escudos_ratio),
        ),
        figure(
          image("./escudos/facultad_logo.png", width: escudos_ratio)
        )
      )

      #text(fontsize*1.35)[
        #course
      ]

      #v(1em)
      #text(fontsize*1.35)[
        *#title*
      ]

      #v(1.5em)
      #text(fontsize*1.1)[
        #align(left)[
          #set par(justify: false)

          #if professor != none [
            DOCENTE: #h(1fr) #professor
          ]

          #if authors.len() > 1 [
            INTEGRANTES:

            #grid(
              columns: (7fr, 1fr),
              row-gutter: 1em,
              align: right,

              ..authors.map(author => (
                author.name,
                [(#author.id)]
              )).flatten(),
            )
          ] else if authors.len() == 1 [
            #let (name, id) = authors.at(0)
            ALUMNO: #h(7fr) #name #h(1fr) (#id)
          ]
        ]
      ]


      #v(1fr)
      // # NOTE: bottom is not what puts it near foot of page
      #text(fontsize*1.2)[
        Perú \
        #if date != none {
          date
        } else {
          let today = datetime.today()
          [ #months.at(today.month()-1) del #today.year() ]
        }
      ]
    ]
  ]
  pagebreak()

  //============================= {Document Body} ==============================
  doc
}

//============================== {Other modules} ===============================
#let src_block(title, content) = {
  let stroke = black + 0.5pt
  let radius = 5pt
  // let font = (font: "Fira Code", size: 10pt)
  let font = (size: 9pt)
  set text(..font)
  show raw: set text(..font)
  block(stroke: stroke, radius: radius, clip: true, fill: rgb("#f2f2f2"))[
    #if title != none {
        block(
          stroke: stroke,
          inset: 0.5em,
          below: 0em,
          radius: (top-left: radius, bottom-right: radius),
          clip: true,
          fill: rgb("#d8d8d8"),
          title
        )
    }
    #block(
      width: 100%,
      inset: (rest: 0.5em),
      clip: true,
      content
    )
  ]
}

/// This uses a hack, path handling may be improved in the future
/// https://forum.typst.app/t/why-are-paths-always-relative-to-the-current-file/306/5
#let src_file(..path, lang: "txt") = {
  let filename = path.at(0)
  src_block(
    filename,
    raw(read(..path), lang: lang)
  )
}

