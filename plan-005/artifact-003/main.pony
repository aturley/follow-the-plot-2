use "collections"
use "random"

primitive SkewGrid
  fun apply(p1: Point, p2: Point, p3: Point, p4: Point, steps: USize):
    SVGNode
  =>
    """
    p1 - top left
    p2 - top right
    p3 - lower left
    p4 - bottom right
    """

    let pcs = PathCommands

    // pcs.command(PathMove.abs(p1.x, p1.y))

    // for p in [p2; p3; p4; p1].values() do
    //   pcs.command(PathLine.abs(p.x, p.y))
    // end

    var x1 = p1.x
    var y1 = p1.y
    var x2 = p2.x
    var y2 = p2.y

    let dx1h = (p4.x - p1.x) / (steps.f64())
    let dy1h = (p4.y - p1.y) / (steps.f64())

    let dx2h = (p3.x - p2.x) / (steps.f64())
    let dy2h = (p3.y - p2.y) / (steps.f64())

    for _ in Range(0, steps + 1) do
      pcs.command(PathMove.abs(x1, y1))
      pcs.command(PathLine.abs(x2, y2))

      x1 = x1 + dx1h
      y1 = y1 + dy1h
      x2 = x2 + dx2h
      y2 = y2 + dy2h
    end

    x1 = p1.x
    y1 = p1.y
    x2 = p4.x
    y2 = p4.y

    let dx1v = (p2.x - p1.x) / (steps.f64())
    let dy1v = (p2.y - p1.y) / (steps.f64())

    let dx2v = (p3.x - p4.x) / (steps.f64())
    let dy2v = (p3.y - p4.y) / (steps.f64())

    for _ in Range(0, steps + 1) do
      pcs.command(PathMove.abs(x1, y1))
      pcs.command(PathLine.abs(x2, y2))

      x1 = x1 + dx1v
      y1 = y1 + dy1v
      x2 = x2 + dx2v
      y2 = y2 + dy2v
    end

    SVG.path(pcs)

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()
    let rand = Rand

    svg.c(Rect(0, 0, 490, 400))

    let x_o = F64(50)
    let y_o = F64(50)

    let grid = Grid[Point](5, 4, Point(0, 0))

    for i in Range(0, 5) do
      for j in Range(0, 4) do
        try
          grid.set(i, j,
            Point(
              RandIn(rand, -30, 30) + (100 * i.f64()) + x_o,
              RandIn(rand, -30, 30) + (100 * j.f64()) + y_o
            ))?
        end
      end
    end

    for i in Range(0, 4) do
      for j in Range(0, 3) do
        try
          svg.c(SkewGrid(
            grid.get(i, j)?,
            grid.get(i + 1, j)?,
            grid.get(i + 1, j + 1)?,
            grid.get(i, j + 1)?,
            RandIn(rand, 10, 40).usize()))
        end
      end
    end

    env.out.print(svg.render())
