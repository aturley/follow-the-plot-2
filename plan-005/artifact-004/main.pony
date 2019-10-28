use "collections"
use "debug"
use "random"

primitive Doodle001
  fun apply(box_width: F64, box_height: F64, boxes_w: USize, boxes_h: USize,
    edge_offset: F64, center_a: Point, center_b: Point, rand: Random,
    orig: Point): SVGNode
  =>
    let pcs_a = PathCommands
    let pcs_b = PathCommands

    let lines_a = Array[Line]
    let lines_b = Array[Line]

    for w in Range[F64](0, boxes_w.f64()) do
      for h in Range[F64](0, boxes_h.f64()) do
        let line = Line(Point(orig.x + edge_offset + (box_width * w), orig.y + edge_offset + (box_height * h)))
        line.add(Point(orig.x + (-edge_offset) + (box_width * (w + 1)), orig.y + edge_offset +(box_height * h)))
        line.add(Point(orig.x + (-edge_offset) + (box_width * (w + 1)), orig.y + (-edge_offset) + (box_height * (h + 1))))
        line.add(Point(orig.x + edge_offset + (box_width * w), orig.y + (-edge_offset) + (box_height * (h + 1))))
        line.add(Point(orig.x + edge_offset + (box_width * w), orig.y + edge_offset + (box_height * h)))

        if rand.real() > 0.5 then
          lines_a.push(line)
        else
          lines_b.push(line)
        end
      end
    end

    for (l, center, pcs) in [(lines_a, center_a, pcs_a); (lines_b, center_b, pcs_b)].values() do
      for a in Range[F64](0, Pi(2), Pi(2) / 1000) do
        let sx = center.x + orig.x
        let sy = center.y + orig.x
        let ex = (a.cos() * 5000) + center.x + orig.x
        let ey = (a.sin() * 5000) + center.y + orig.x
        for lines in l.values() do
          match lines.intersections(Segment(Point(sx, sy), Point(ex, ey)))
          | let isect: Array[Point] if isect.size() == 2 =>
            try
              pcs.command(PathMove.abs(isect(0)?.x, isect(0)?.y))
              pcs.command(PathLine.abs(isect(1)?.x, isect(1)?.y))
            end
          end
        end
      end
    end

    SVG.group([SVG.path(pcs_b); SVG.path(pcs_a where stroke = "red")].values())

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    svg.c(Rect(20, 20, 760, 410))

    let rand = Rand

    svg.c(Doodle001(50, 50, 14, 7, 3, Point(500, 500), Point(300, 500),
      rand, Point(40, 40)))

    env.out.print(svg.render())
