use "collections"
use "debug"
use "random"

primitive DayBox
  fun apply(w: F64, h: F64, num: USize, spacing: F64, top: Point): Line =>
    let line = Line(top)

    for i in Range(0, num) do
      let spacing' = (w + spacing) * i.f64()
      line .> start(Point(top.x + spacing', top.y))
        .> add(Point(top.x + w + spacing', top.y))
        .> add(Point(top.x + w + spacing', top.y + h))
        .> add(Point(top.x + spacing', top.y + h))
        .> add(Point(top.x + spacing', top.y))
    end

    line

primitive DrawWeekLines
  fun apply(w: F64, h: F64, top: Point, day_box: Line): PathCommands =>
    let pcs = PathCommands

    var spacing: F64 = 1
    var next_x: F64 = top.x
    let run_distance: F64 = 250
    var breaker: F64 = run_distance + top.x

    for i in Range[F64](0, 10000) do
      let sx = next_x
      let sy = top.y
      let ex = next_x
      let ey = top.y + h

      spacing = spacing * 1.015

      if next_x > breaker then
        spacing = 1
        next_x = breaker
        breaker = breaker + run_distance
      end

      next_x = next_x + spacing

      if sx > w then
        break
      end

      match day_box.intersections(Segment(Point(sx, sy), Point(ex, ey)))
      | let ps: Array[Point] =>
        try
          if ps.size() == 2 then
            pcs.command(PathMove.abs(sx, sy))
            pcs.command(PathLine.abs(ps(0)?.x, ps(0)?.y))
            pcs.command(PathMove.abs(ps(1)?.x, ps(1)?.y))
            pcs.command(PathLine.abs(ex, ey))
          else
            pcs.command(PathMove.abs(sx, sy))
            pcs.command(PathLine.abs(ex, ey))
          end
        end
      end
    end

    pcs

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    svg.c(SVG.polyline([(15, 10); (860, 10); (860, 510)
      (15, 510); (15, 10)].values()))

    let rand = Rand

    let days_in_months = [as USize: 31; 29; 31; 30; 31; 30; 31; 31; 30; 31; 30; 31]

    for (i, m) in days_in_months.pairs() do
      let day_box = DayBox(20, 20, m, 5, Point(30, 30 + (40 * i.f64())))
      let pcs = DrawWeekLines(850, 40 , Point(25, 20 + (40 * i.f64())), day_box)

      svg.c(SVG.path(pcs))
    end

    env.out.print(svg.render())
