use "collections"
use "random"
use "itertools"

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    svg.c(Rect(50, 50, 550, 550))

    // let points = [
    //   Point(10, 50)
    //   Point(40, 20)
    //   Point(70, 90)
    //   Point(130, 100)]

    let points = Array[Point]

    for i in Range(1, 4000) do
      let a = Pi(20 * i.f64()) / 1000
      let d = 5 + (i.f64() / 20)
      let x = a.cos() * d
      let y = a.sin() * d
      points.push(Point(x, y))
    end

    svg.c(WideLineAccumulating(points, 5, 5, Point(300, 300)))

    env.out.print(svg.render())
