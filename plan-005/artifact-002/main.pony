use "collections"
use "random"

primitive Doodle001
  fun apply(x_o: F64, y_o: F64, width: USize, height: USize, rand: Random,
    scale: F64): SVGNode
  =>
    let g = Grid[(F64, F64)](width, height, (0, 0))
    let circles = Array[SVGNode]

    let pcs = PathCommands

    for w in Range(0, width) do
      for h in Range(0, height) do
        try
          g.set(w, h, (rand.real(), rand.real()))?
        end
      end
    end

    for w in Range(0, width) do
      for h in Range(0, height) do
        try
          (let x, let y) = g.get(w, h)?
          circles.push(
            SVG.circle(((w.f64() + x) * scale) + x_o,
              ((h.f64() + y) * scale) + y_o, 5))

          for (dw, dh) in
            [as (F64, F64): (0, 1); (0, -1); (1, 0); (-1, 0)].values()
          do
            try
              let w2 = (w.f64() + dw).usize()
              let h2 = (h.f64() + dh).usize()
              (let x2, let y2) = g.get(w2, h2)?
              if Point(x, y).dist(Point(x2 + dw, y2 + dh)) > 1.3 then
                pcs.command(PathMove.abs(((w.f64() + x) * scale) + x_o,
                  ((h.f64() + y) * scale) + y_o))
                pcs.command(PathLine.abs(((w2.f64() + x2) * scale) + x_o,
                  ((h2.f64() + y2) * scale) + y_o))
              end
            end
          end
        end
      end
    end

    circles .> push(SVG.path(pcs))

    SVG.group(circles.values())

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()
    let rand = Rand

    svg.c(Rect(0, 0, 340, 240))

    // for n in Doodle001(20, 20, 15, 10, rand, 20).values() do
    //   svg.c(n)
    // end

    svg.c(Doodle001(20, 20, 15, 10, rand, 20))

    env.out.print(svg.render())
