use "collections"
use "random"

primitive Doodle001
  fun apply(rand: Random, x_o: F64, y_o: F64, width: F64, height: F64,
    pens: USize): SVGNode
  =>
    var points = Array[Array[Point]]

    let initial_points = Array[Point]
    for _ in Range(0, pens) do
      initial_points.push(Point(-25, height / 2))
    end

    points.push(initial_points)

    var last_x: F64 = 0

    for s in RandomStepsTo(rand, 0, width, 3, 20) do
      let a = Array[Point]
      for p in RandomFixStepsTo(rand, 0, height, pens) do
        a.push(Point(s, p))
      end
      points.push(a)
      last_x = s
    end

    let final_points = Array[Point]
    for _ in Range(0, pens) do
      final_points.push(Point(last_x + 25, (height / 2)))
    end

    points.push(final_points)

    let pcs = PathCommands

    for i in Range(0, pens) do
      let ps_it = points.values()

      try
        let p = ps_it.next()?(i)?
        pcs.command(PathMove.abs(x_o + p.x, y_o + p.y))
      end

      for ps in ps_it do
        try
          let p = ps(i)?
          pcs.command(PathLine.abs(x_o + p.x, y_o + p.y))
        end
      end
    end

    SVG.path(pcs)

primitive Rect
  fun apply(sx: F64, sy: F64, ex: F64, ey: F64): SVGNode =>
    SVG.polyline([(sx, sy); (ex, sy); (ex, ey); (sx, ey); (sx, sy)].values())

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    let rand = Rand

    svg.c(Rect(50, 75, 650, 175))

    svg.c(Doodle001(rand, 100, 100, 500, 50, 50))

    env.out.print(svg.render())
