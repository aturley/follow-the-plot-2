use "collections"
use "random"

primitive Doodle001
  fun apply(rand: Random, x_o: F64, y_o: F64, height: F64,
    pens: USize): SVGNode
  =>
    var points = Array[Array[Point]]

    for s in RandomStepsTo(rand, 0, Pi(2), 0.025, 0.5) do
      let a = Array[Point]
      for p in RandomExclusiveFixStepsTo(rand, 0, height, pens) do
        a.push(Point((p + 10) * s.cos(), (p + 10) * s.sin()))
      end
      points.push(a)
    end

    try
      points.pop()?
    end

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

      try
        let first = points(0)?(i)?

        pcs.command(PathLine.abs(x_o + first.x, y_o + first.y))
      end
    end

    SVG.path(pcs)

primitive Rect
  fun apply(sx: F64, sy: F64, ex: F64, ey: F64): SVGNode =>
    SVG.polyline([(sx, sy); (ex, sy); (ex, ey); (sx, ey); (sx, sy)].values())

primitive Pi
  fun apply(numerator: F64 = 1, denominator: F64 = 1): F64 =>
    (3.145926535 * numerator) / denominator

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    let rand = Rand

    // svg.c(Rect(50, 75, 650, 175))

    svg.c(Doodle001(rand, 300, 300, 250, 125))

    env.out.print(svg.render())
