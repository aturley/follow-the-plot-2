use "collections"
use "debug"
use "random"

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    let rand = Rand

    svg.c(Rect(20, 200, 700, 460))

    let points = [
      Point(20, 100)
      Point(80, 40)
      Point(140, 180)
      Point(260, 200)]

    svg.c(SimpleLine(points, Point(20, 200)))

    for _ in Range(0, 5) do
      svg.c(SimpleLine(points, Point(220, 200), DashMarker(10, RandomEnds(10, rand, DashMarker(2)))))
    end

    for _ in Range(0, 5) do
      svg.c(SimpleLine(points, Point(420, 200), DashMarker(10, RandomEnds(10, rand))))
    end

    env.out.print(svg.render())
