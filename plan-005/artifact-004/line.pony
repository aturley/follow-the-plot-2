class val Point
  let x: F64
  let y: F64

  new val create(x': F64, y': F64) =>
    x = x'
    y = y'

  fun sx(x': F64): Point =>
    Point(x', y)

  fun sy(y': F64): Point =>
    Point(x, y')

  fun string(): String iso^ =>
    ("(" + x.string() + "," + y.string() + ")").clone()

  fun in_rect(p1: Point, p2: Point): Bool =>
    let f: F64 = 0.001
    ((x + f) >= p1.x.min(p2.x)) and ((x - f) <= p1.x.max(p2.x)) and
      ((y + f) >= p1.y.min(p2.y)) and ((y - f) <= p1.y.max(p2.y))

  fun dist(that: Point): F64 =>
    let dx = x - that.x
    let dy = y - that.y

    ((dx * dx) + (dy * dy)).sqrt()

class val PointComparable
  let _origin: Point
  let point: Point
  let dist: F64

  new val create(o: Point, p: Point) =>
    _origin = o
    point = p
    dist = p.dist(o)

  fun eq(that: PointComparable): Bool =>
    dist == that.dist

  fun lt(that: PointComparable): Bool =>
    dist < that.dist

class val InfSlope
  let x: F64

  new val create(x': F64) =>
    x = x'

  fun string(): String iso^ =>
    ("Inf(" + x.string() + ")").clone()

class val Segment
  let p1: Point
  let p2: Point

  new val create(p1': Point, p2': Point) =>
    p1 = p1'
    p2 = p2'

  fun slope(): (F64 | InfSlope) =>
    let dx = p1.x - p2.x

    if dx != 0 then
      (p1.y - p2.y) / dx
    else
      InfSlope(p1.x)
    end

  fun y_int(): (F64 | None) =>
    //   y = m*x+b
    //   (y1 - y0)/(x1 - x0) = m
    //   y1 - y0 = m * (x1 - x0)
    // y-intercept is at x0 = 0
    //   y0      = y1 - (m *  x1)

    match slope()
    | let m: F64 =>
      p1.y - (p1.x * m)
    end

  fun val intersection(that: Segment): (Point | None) =>
    //   y = m*x+b
    //
    //   y1 = m1*x1+b1
    //   y2 = m2*x2+b2
    // intersect when x1 = x2, y1 = y2.
    //   m1 * x + b1 = m2 * x + b2
    //   m1 * x      = m2 * x + b2 - b1
    //   m1 * x - (m2 * x) = b2 - b1
    //   x * (m1 - m2)     = b2 - b1
    //   x                 = (b2 - b1) / (m1 - m2)
    match (slope(), that.slope(), y_int(), that.y_int())
    | (let m1: F64, let m2: F64, let b1: F64, let b2: F64) if m1 != m2 =>
      let x = (b2 - b1) / (m1 - m2)
      let y = (m1 * x) + b1
      let p = Point(x, y)

      if p.in_rect(p1, p2) and p.in_rect(that.p1, that.p2) then
        p
      end
    | (let m1: F64, let m2: F64, let b1: F64, let b2: F64) => // m1 == m2
      match (Segment(p1, that.p1).slope(), Segment(p1, that.p2).slope())
      | (let mm1: F64, let mm2: F64) if mm1 == mm2 =>
        // they are co-linear

        if that.p1.in_rect(p1, p2) then
          that.p1
        elseif that.p2.in_rect(p1, p2) then
          that.p2
        end
      end
    | (let m1: InfSlope, let m2: InfSlope, None, None) if m1.x == m2.x =>
      // they are co-linear with infinite slope
      if that.p1.in_rect(p1, p2) then
        that.p1
      elseif that.p2.in_rect(p1, p2) then
        that.p2
      end
    | (let m1: InfSlope, let m2: F64, None, let b2: F64) =>
      let x = m1.x
      let y = (m2 * x) + b2
      let p = Point(x, y)
      if p.in_rect(that.p1, that.p2) and p.in_rect(p1, p2) then
        p
      end
    | (let m1: F64, let m2: InfSlope, let b1: F64, None) =>
      that.intersection(this)
    end

class Line
  let _segments: Array[Segment]
  var _start_point: (None | Point)

  new create(p: Point) =>
    _segments = Array[Segment]
    _start_point = p

  fun ref add(p: Point) =>
    match _start_point
    | None =>
      try
        _segments.push(Segment(_segments(_segments.size() - 1)?.p2, p))
      end
    | let sp: Point =>
      _segments.push(Segment(sp, p))
      _start_point = None
    end

  fun ref start(p: Point) =>
    _start_point = p

  fun intersections(seg: Segment): Array[Point] =>
    let intersects = Array[Point]

    for s in _segments.values() do
      match seg.intersection(s)
      | (let p: Point) =>
        intersects.push(p)
      end
    end

    intersects

  fun segments(): Iterator[Segment] =>
    _segments.values()
