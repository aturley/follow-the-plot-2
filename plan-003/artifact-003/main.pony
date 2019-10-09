use "collections"
use "random"

primitive TriangleField
  fun apply(w: F64, h: F64, min_step: F64, max_step: F64, rand: Random): Array[(Point, Point, Point)] =>
    let points = Array[Point]
    let triangles = Array[(Point, Point, Point)]

    var step: F64 = 0
    var loc: F64 = 0

    while true do
      step = max_step - (rand.real() * (max_step - min_step))
      loc = loc + step

      if loc > w then
        break
      end

      let r = rand.real() * h
      let p = Point(loc, r)

      if points.size() > 5 then
        try
          (let p1, let p2) = _find_closest(p, points)?
          triangles.push((p, p1, p2))
        end
      end

      points.push(p)
    end

    triangles

    fun _find_closest(point: Point, ps: Array[Point]): (Point, Point) ? =>
      var p1 = ps(0)?
      var d1 = p1.dist(point)
      var p2 = ps(1)?
      var d2 = p2.dist(point)

      for p in ps.values() do
        if p.dist(point) < d1 then
          p2 = p1
          d2 = d1
          p1 = p
          d1 = p.dist(point)
        elseif p.dist(point) < d2 then
          p2 = p
          d2 = p.dist(point)
        end
      end

      (p1, p2)

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    let rand = Rand

    let ts = TriangleField(700, 200, 5, 10, rand)

    let lines = Array[Line]

    for (p1, p2, p3) in ts.values() do
      lines.push(Line(p1) .> add(p2) .> add(p3) .> add(p1))
    end

    let pcss = Array[PathCommands]

    for (i, l) in lines.pairs() do
      let pcs = PathCommands
      let x = rand.real() * 700
      let y = rand.real() * 200
      for a in Range[F64](0, Pi(2), Pi(2) / 500) do
        let ex = (a.cos() * 700) + x
        let ey = (a.sin() * 200) + y

        match l.intersections(Segment(Point(x, y), Point(ex, ey)))
        | let ps: Array[Point] if ps.size() == 2 =>
          try
            pcs.command(PathMove.abs(ps(0)?.x, ps(0)?.y))
            pcs.command(PathLine.abs(ps(1)?.x, ps(1)?.y))
          end
        end

      end

      pcss.push(pcs)
    end

    svg.c(Rect(0, 0, 700, 220))

    for z in pcss.values() do
      svg.c(SVG.path(z))
    end

    env.out.print(svg.render())

primitive Pi
  fun apply(numerator: F64 = 1, denominator: F64 = 1): F64 =>
    (3.145926535 * numerator) / denominator

primitive Rect
  fun apply(sx: F64, sy: F64, ex: F64, ey: F64): SVGNode =>
    SVG.polyline([(sx, sy); (ex, sy); (ex, ey); (sx, ey); (sx, sy)].values())
