use "collections"
use "random"

primitive Doodle001
  fun apply(x_o: F64, y_o: F64, rand: Random): Array[SVGNode] =>
    let paths = Array[SVGNode]

    let points = Array[(F64, F64)]

    for _ in Range(0, 1000) do
      points.push((rand.real() * 700, rand.real() * 500))
    end

    for j in Range(0, 10) do
      let pcs = PathCommands

      try
        let shuf = points.clone()
        rand.shuffle[(F64, F64)](shuf)

        let a = shuf(0)?
        let b = shuf(1)?
        let c = shuf(2)?

        let delta_a_b_x = (a._1 - b._1) / 20
        let delta_a_b_y = (a._2 - b._2) / 20

        let delta_a_c_x = (a._1 - c._1) / 20
        let delta_a_c_y = (a._2 - c._2) / 20

        var sx = b._1
        var sy = b._2

        var ex = c._1
        var ey = c._2

        for _ in Range(0, 20) do
          pcs.command(PathMove.abs(x_o + sx, y_o + sy))
          pcs.command(PathLine.abs(x_o + ex, y_o + ey))

          sx = sx + delta_a_b_x
          sy = sy + delta_a_b_y
          ex = ex + delta_a_c_x
          ey = ey + delta_a_c_y
        end

        pcs.command(PathMove.abs(x_o + a._1, y_o + a._2))
        pcs.command(PathLine.abs(x_o + b._1, y_o + b._2))
        pcs.command(PathLine.abs(x_o + c._1, y_o + c._2))
        pcs.command(PathLine.abs(x_o + a._1, y_o + a._2))

        paths.push(SVG.path(pcs))

      end
    end

    paths

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    let rand = Rand

    svg.c(SVG.polyline([(30, 30); (750, 30); (750, 570)
      (30, 570); (30, 30)].values()))

    for p in Doodle001(50, 50, rand).values() do
      svg.c(p)
    end

    env.out.print(svg.render())
