use "collections"

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    let w: USize = 20
    let h: USize = 20

    let grid = Grid[(F64, F64)](w, h, (0, 0))

    let pcs = PathCommands

    let a = Point(300, 300)

    for i in Range(0, w) do
      for j in Range(0, h) do
        try
          let x = i.f64() * 20
          let y = j.f64() * 20

          let d = Point(x, y).dist(a)

          let f = if d == 0 then
            0
          else
            100 / d
          end

          let x' = x + ((a.x - x) * f)
          let y' = y + ((a.y - y) * f)

          grid.set(i, j, (x', y'))?
        end
      end
    end

    for i in Range(0, w) do
      for j in Range(0, h) do
        try
          (let sx, let sy) = grid.get(i, j)?
          (let ex1, let ey1) = grid.get(i, j + 1)?
          pcs.command(PathMove.abs(sx, sy))
          pcs.command(PathLine.abs(ex1, ey1))
          // env.err.print(" ".join([as Stringable: "i="; i; "j="; j; "sx="; sx; "sy="; sy; "ex1="; ex1; "ex2="; ey1].values()))
        end
        try
          (let sx, let sy) = grid.get(i, j)?
          (let ex2, let ey2) = grid.get(i + 1, j)?
          pcs.command(PathMove.abs(sx, sy))
          pcs.command(PathLine.abs(ex2, ey2))
        end
      end
    end

    svg.c(Rect(20, 20, 400, 400))

    svg.c(SVG.path(pcs))

    env.out.print(svg.render())
