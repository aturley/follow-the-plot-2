use "collections"
use "debug"
use "random"

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    let rand = Rand

    svg.c(Rect(50, 50, 800, 550))

    let points = Array[Point]

    let radius: F64 = 200

    for a in Range[F64](Pi(1, 8), Pi((2 * 8) - 1, 8), Pi(1, 8)) do
      points.push(Point(a.cos() * radius, a.sin() * radius))
    end

    svg.c(WideLine(points, 10, 5, Point(300, 300), RotatingMarker(Pi(1, 20))))

    let points2 = [Point(0, 0); Point(450, 0)]

    svg.c(WideLine(points2, 40, 2, Point(300, 300), RotatingMarker(Pi(1, 20))))

    let points3 = [Point(30, 0); Point(450, 0)]

    svg.c(WideLine(points3, 40, 2, Point(300, 330), RotatingMarker(-Pi(1, 20))))

    env.out.print(svg.render())
