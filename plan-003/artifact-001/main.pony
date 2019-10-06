use "collections"

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    let pcs1 = PathCommands

    let x_o: F64 = 300
    let y_o: F64 = 300

    let line1 = Line(Point(200, 200)) .> add(Point(500, 200)) .> add(Point(300, 500)) .> close()

    let line2 = Line(Point(100, 150)) .> add(Point(600, 180)) .> add(Point(410, 530)) .> close()

    for a in Range[F64](0, Pi(2), Pi(1, 60) - 0.01) do
      let x = (a.cos() * 170) + x_o
      let y = (a.sin() * 170) + y_o

      let s = Segment(Point(x_o, y_o), Point(x, y))

      (let x': F64, let y': F64) = match line1.intersections(s)
      | let ips: Array[Point] =>
        try
          (ips(0)?.x, ips(0)?.y)
        else
          (x, y)
        end
      end

      pcs1.command(PathMove.abs(x_o, y_o))
      pcs1.command(PathLine.abs(x', y'))
    end

    let pcs2 = PathCommands

    for a in Range[F64](0, Pi(2), Pi(2, 180) - 0.02) do
      let x = (a.cos() * 600) + x_o + 31
      let y = (a.sin() * 600) + y_o + 47

      let s = Segment(Point(x_o + 31, y_o + 47), Point(x, y))

      (let sx': F64, let sy': F64) = match line1.intersections(s)
      | let ips: Array[Point] =>
        try
          (ips(0)?.x, ips(0)?.y)
        else
          (0, 0)
        end
      end

      (let ex': F64, let ey': F64) = match line2.intersections(s)
      | let ips: Array[Point] =>
        try
          (ips(0)?.x, ips(0)?.y)
        else
          (x, y)
        end
      end

      pcs2.command(PathMove.abs(sx', sy'))
      pcs2.command(PathLine.abs(ex', ey'))
    end

    svg.c(SVG.polyline([(80, 120); (640, 120); (640, 540)
      (80, 540); (80, 120)].values()))

    svg.c(SVG.path(pcs1))
    svg.c(SVG.path(pcs2))

    env.out.print(svg.render())


primitive Pi
  fun apply(numerator: F64 = 1, denominator: F64 = 1): F64 =>
    (3.145926535 * numerator) / denominator
