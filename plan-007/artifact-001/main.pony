use "collections"
use "debug"
use "random"

class WanderingCircle
  let _center: Point
  let _radius: F64

  new create(center: Point, radius: F64) =>
    _center = center
    _radius = radius

  fun points(num: USize, offset_angle: F64): Iterator[Point] =>
    let pts = Array[Point]

    for a in Range[F64](offset_angle, Pi(2) + offset_angle, Pi(2) / num.f64()) do
      let x = _center.x + (a.cos() * _radius)
      let y = _center.y + (a.sin() * _radius)
      pts.push(Point(x, y))
    end

    pts.values()

primitive Doodle001
  fun circle_it(min_point: Point, max_point: Point, rand: Rand): Iterator[Point] =>
    WanderingCircle(
      Point(RandIn(rand, min_point.x, max_point.x), RandIn(rand, min_point.y, max_point.y)),
      5 + (rand.real() * 20)).points((5 + rand.int(20)).usize(), rand.real() * Pi(2))

  fun apply(rand: Rand, orig: Point): SVGNode =>
    let pcs_black = PathCommands
    let pcs_red = PathCommands

    let p_s = Point(0, 200)
    let p_e = Point(700, 200)

    let make_c1 = {ref ()(t = this): Iterator[Point] => t.circle_it(Point(0, 0), Point(700, 100), rand)}
    let make_c2 = {ref ()(t = this): Iterator[Point] => t.circle_it(Point(0, 300), Point(700, 400), rand)}

    var c1: Iterator[Point] = make_c1()

    var c2: Iterator[Point] = make_c2()

    for p in PointRangeSpacing(p_s, p_e, 3) do
      if not c1.has_next() then
        c1 = make_c1()
      end
      let p1 = try
        c1.next()?
      else
        Point(0, 0)
      end

      if not c2.has_next() then
        c2 = make_c2()
      end
      let p2 = try
        c2.next()?
      else
        Point(0, 0)
      end

      for (pcs_c, pc) in [(pcs_black, p1); (pcs_red, p2)].values() do
        pcs_c.command(PathMove.abs(p.x + orig.x, p.y + orig.y))
        pcs_c.command(PathLine.abs(pc.x + orig.x , pc.y + orig.y))
      end

    end

    SVG.group([SVG.path(pcs_black where stroke = "black")
      SVG.path(pcs_red where stroke = "red")].values())

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    svg.c(Rect(0, 0, 750, 470))

    let rand = Rand

    svg.c(Doodle001(rand, Point(30, 30)))

    env.out.print(svg.render())
