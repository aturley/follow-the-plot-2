use "collections"
use "itertools"
use "random"

trait Marker
  fun ref line(p: Point)
  fun ref move(p: Point)
  fun ref draw(): PathCommands

class BasicMarker is Marker
  var _pcs: PathCommands

  new create() =>
    _pcs = PathCommands

  fun ref move(p: Point) =>
    _pcs.command(PathMove.abs(p.x, p.y))

  fun ref line(p: Point) =>
    _pcs.command(PathLine.abs(p.x, p.y))

  fun ref draw(): PathCommands =>
    _pcs = PathCommands

class DashMarker is Marker
  let _spacing: F64
  let _marker: Marker
  var _p_last: Point

  new create(spacing: F64, marker: Marker = BasicMarker) =>
    _spacing = spacing
    _marker = marker
    _p_last = Point(0, 0)

  fun ref move(p: Point) =>
    _marker.move(p)
    _p_last = p

  fun ref line(p: Point) =>
    var drawing = false

    for ip in PointRangeSpacing(_p_last, p, _spacing) do
      if drawing then
        _marker.line(Point(ip.x, ip.y))
      else
        _marker.move(Point(ip.x, ip.y))
      end
      drawing = not drawing
    end

    _p_last = p

  fun ref draw(): PathCommands =>
    _marker.draw()

class RandomEnds is Marker
  let _radius: F64
  let _rand: Random
  let _marker: Marker

  new create(radius: F64, rand: Random, marker: Marker = BasicMarker) =>
    _radius = radius
    _rand = rand
    _marker = marker

  fun ref move(p: Point) =>
    _marker.move(_randomize_point(p))

  fun ref line(p: Point) =>
    _marker.line(_randomize_point(p))

  fun ref draw(): PathCommands =>
    _marker.draw()

  fun ref _randomize_point(p: Point): Point =>
    let r = _rand.real() * _radius
    let a = _rand.real() * Pi(2)
    Point(p.x + (r * a.cos()), p.y + (r * a.sin()))

primitive SimpleLine
  fun apply(points: Array[Point], orig: Point, marker: Marker = BasicMarker):
    SVGNode
  =>
    let pit = points.values()

    try
      let p = pit.next()?
      marker.move(Point(p.x + orig.x, p.y + orig.y))
    end

    for p in pit do
      marker.line(Point(p.x + orig.x, p.y + orig.y))
    end

    SVG.path(marker.draw())

primitive SimpleDisconnectedLine
  fun apply(points: Array[Point], orig: Point, marker: Marker = BasicMarker):
    SVGNode
  =>
    let pit = points.values()

    try
      pit.next()?
      for (p1, p2) in Iter[Point](points.values()).zip[Point](pit) do
        marker.move(Point(p1.x + orig.x, p1.y + orig.y))
        marker.line(Point(p2.x + orig.x, p2.y + orig.y))
      end
    end

    SVG.path(marker.draw())

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
      let norm_perp_dx = (p2.y - p1.y) / dist
      let norm_perp_dy = -(p2.x - p1.x) / dist

      for p in PointRangeSpacing(p1, p2, spacing) do
        let w_sx = p.x + orig.x + ((width / 2) * norm_perp_dx)
        let w_sy = p.y + orig.y + ((width / 2) * norm_perp_dy)

        let w_ex = p.x + orig.x + ((width / 2) * (-norm_perp_dx))
        let w_ey = p.y + orig.y + ((width / 2) * (-norm_perp_dy))

        pcs.command(PathMove.abs(w_sx, w_sy))
        pcs.command(PathLine.abs(w_ex, w_ey))
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
    end

    for (p1, p2) in Iter[Point](points.values()).zip[Point](pit) do
      var draw = false

      for p in PointRangeSpacing(p1, p2, spacing) do
        if draw then
          pcs.command(PathLine.abs(p.x + orig.x, p.y + orig.y))
        else
          pcs.command(PathMove.abs(p.x + orig.x, p.y + orig.y))
        end
        draw = not draw
      end
    end

    SVG.path(pcs)

primitive WideLineAccumulating
  fun apply(points: Array[Point], width: F64, spacing: F64, orig: Point):
    SVGNode
  =>
    let pcs = PathCommands

    let pit = points.values()
    var cur_seg = try
      let p1 = pit.next()?
      let p2 = pit.next()?
      (p1, p2)
    else
      return SVG.path(pcs)
    end

    var cur_p = cur_seg._1

    try
      repeat

        let p1 = cur_seg._1
        let p2 = cur_seg._2

        let dist = p1.dist(p2)
        let norm_perp_dx = (p2.y - p1.y) / dist
        let norm_perp_dy = -(p2.x - p1.x) / dist


        let w_sx = cur_p.x + orig.x + ((width / 2) * norm_perp_dx)
        let w_sy = cur_p.y + orig.y + ((width / 2) * norm_perp_dy)

        let w_ex = cur_p.x + orig.x + ((width / 2) * (-norm_perp_dx))
        let w_ey = cur_p.y + orig.y + ((width / 2) * (-norm_perp_dy))

        pcs.command(PathMove.abs(w_sx, w_sy))
        pcs.command(PathLine.abs(w_ex, w_ey))


        if cur_p.dist(cur_seg._2) < spacing then
          var dist_rem = spacing

          repeat
            let traveled = cur_p.dist(cur_seg._2)
            dist_rem = dist_rem - traveled
            cur_seg = (cur_seg._2, pit.next()?)
            cur_p = cur_seg._1
          until dist_rem < cur_p.dist(cur_seg._2) end
          let dist' = cur_seg._2.dist(cur_seg._1)
          let dx_n = (cur_seg._2.x - cur_seg._1.x) / dist'
          let dy_n = (cur_seg._2.y - cur_seg._1.y) / dist'

          cur_p = Point(cur_p.x + (dx_n * dist_rem), cur_p.y + (dy_n * dist_rem))
        else
          let dist' = cur_seg._2.dist(cur_seg._1)
          let dx = ((cur_seg._2.x - cur_seg._1.x) / dist') * spacing
          let dy = ((cur_seg._2.y - cur_seg._1.y) / dist') * spacing

          cur_p = Point(cur_p.x + dx, cur_p.y + dy)
        end
      until (not pit.has_next()) and (cur_p.dist(cur_seg._2) < spacing) end
    end

    SVG.path(pcs)

class PointRangeSteps
  let _dx: F64
  let _dy: F64

  var _x: F64
  var _y: F64

  let _ex: F64

  new create(p1: Point, p2: Point, steps: USize) =>
    _dx = (p2.x - p1.x) / steps.f64()
    _dy = (p2.y - p1.y) / steps.f64()

    _x = p1.x
    _y = p1.y

    _ex = p2.x

  fun ref next(): Point ? =>
    if _x <= _ex then
      let p = Point(_x, _y)
      _x = _x + _dx
      _y = _y + _dy
      p
    else
      error
    end

  fun ref has_next(): Bool =>
    _x <= _ex

class PointRangeSpacing
  let _dx: F64
  let _dy: F64

  var _x: F64
  var _y: F64

  let _ex: F64

  new create(p1: Point, p2: Point, spacing: F64) =>
    let dist = p2.dist(p1)
    _dx = ((p2.x - p1.x) / dist) * spacing
    _dy = ((p2.y - p1.y) / dist) * spacing

    _x = p1.x
    _y = p1.y

    _ex = p2.x

  fun ref next(): Point ? =>
    if _x <= _ex then
      let p = Point(_x, _y)
      _x = _x + _dx
      _y = _y + _dy
      p
    else
      error
    end

  fun ref has_next(): Bool =>
    _x <= _ex
