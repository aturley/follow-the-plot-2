use "collections"
use "random"
use "itertools"

primitive SimpleLine
  fun apply(points: Array[Point], orig: Point): SVGNode =>
    let pcs = PathCommands

    let pit = points.values()

    try
      let p = pit.next()?
      pcs.command(PathMove.abs(p.x + orig.x, p.y + orig.y))
    end

    for p in pit do
      pcs.command(PathLine.abs(p.x + orig.x, p.y + orig.y))
    end

    SVG.path(pcs)

primitive WideLine
  fun apply(points: Array[Point], width: F64, spacing: F64, orig: Point):
    SVGNode
  =>
    let pcs = PathCommands

    let pit = points.values()

    try
      pit.next()?
    end

    for (p1, p2) in Iter[Point](points.values()).zip[Point](pit) do
      let dist = p1.dist(p2)
      let steps = (dist / spacing).usize()
      let dx = ((p2.x - p1.x) / dist) * spacing
      let dy = ((p2.y - p1.y) / dist) * spacing
      let norm_perp_dx = (p2.y - p1.y) / dist
      let norm_perp_dy = -(p2.x - p1.x) / dist

      var sx = p1.x + orig.x
      var sy = p1.y + orig.y
      var ex = sx + dx
      var ey = sy + dy

      pcs.command(PathMove.abs(ex, ey))

      for _ in Range(0, steps) do
        let w_sx = ex + ((width / 2) * norm_perp_dx)
        let w_sy = ey + ((width / 2) * norm_perp_dy)

        let w_ex = ex + ((width / 2) * (-norm_perp_dx))
        let w_ey = ey + ((width / 2) * (-norm_perp_dy))

        pcs.command(PathMove.abs(w_sx, w_sy))
        pcs.command(PathLine.abs(w_ex, w_ey))
        ex = ex + dx
        ey = ey + dy
      end
    end

    SVG.path(pcs)

primitive DashLine
  fun apply(points: Array[Point], spacing: F64, orig: Point):
    SVGNode
  =>
    let pcs = PathCommands

    let pit = points.values()

    try
      let p = pit.next()?
      pcs.command(PathMove.abs(p.x + orig.x, p.y + orig.y))
    end

    for (p1, p2) in Iter[Point](points.values()).zip[Point](pit) do
      let dist = p1.dist(p2)
      let steps = (dist / spacing).usize()
      let dx = ((p2.x - p1.x) / dist) * spacing
      let dy = ((p2.y - p1.y) / dist) * spacing

      var sx = p1.x + orig.x
      var sy = p1.y + orig.y
      var ex = sx + dx
      var ey = sy + dy

      pcs.command(PathMove.abs(ex, ey))

      var draw = false

      for _ in Range(0, steps) do
        if draw then
          pcs.command(PathLine.abs(ex, ey))
        else
          pcs.command(PathMove.abs(ex, ey))
        end
        ex = ex + dx
        ey = ey + dy
        draw = not draw
      end
    end

    SVG.path(pcs)

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    svg.c(Rect(10, 100, 450, 230))

    let points = [
      Point(10, 50)
      Point(40, 20)
      Point(70, 90)
      Point(130, 100)]

    svg.c(SimpleLine(points, Point(20, 100)))

    svg.c(DashLine(points, 5, Point(150, 100)))

    svg.c(WideLine(points, 5, 5, Point(300, 100)))

    env.out.print(svg.render())
