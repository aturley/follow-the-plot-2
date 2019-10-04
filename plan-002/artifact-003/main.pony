use "collections"
use "random"

// (angle, distance)
type RadialPoint is (F64, F64)

primitive Pi
  fun apply(n: F64 = 1, d: F64 = 1): F64 => (3.1415926535 * n) / d

primitive Doodle001
  fun apply(x_o: F64, y_o: F64, rand: Random): Array[SVGNode] =>
    let nodes = Array[SVGNode]

    for i in Range[F64](0, 16) do
      let start_out: F64 = 50 + (rand.real() * 100)
      let start_len = 150 + (rand.real() * 100)
      let start_angle = rand.real() * Pi(2)
      let end_angle = start_angle + (rand.real() * Pi())

      let out_velocity = -1 * (rand.real() * 2)
      let len_velocity = -1 * (rand.real() * 2)

      var out = start_out
      var len = start_len

      let pcs = PathCommands

      let r_x_o = x_o + ((i / 4).f64() * 4)
      let r_y_o = y_o + ((i % 4).f64() * 4)

      for a in Range[F64](start_angle, end_angle, 0.01 + (rand.real() * 0.05)) do
        let sx = a.cos() * out
        let sy = a.sin() * out
        let ex = a.cos() * len
        let ey = a.sin() * len

        pcs.command(PathMove.abs(sx + r_x_o, sy + r_y_o))
        pcs.command(PathLine.abs(ex + r_x_o, ey + r_y_o))

        out = (out + (out_velocity * rand.real())).max(2)
        len = (len + (len_velocity * rand.real()))
      end

      nodes.push(SVG.path(pcs))
    end

    nodes

primitive Doodle002
  fun apply(x_o: F64, y_o: F64, rand: Random): Array[SVGNode] =>
    let nodes = Array[SVGNode]

    for _ in Range(0, 5) do
      let blocks:USize = (rand.int_unbiased[USize](2) * 2) + 1
      let arm = Array[(F64, F64)]

      var arm_pos: F64 = 0

      for i in Range[F64](0, blocks.f64()) do
        let s = arm_pos + (rand.real() * (50 + (5 * i)))
        let e = s + (rand.real() * (50 + (5 * i)))
        arm.push((s, e))
        arm_pos = e
      end

      let pcs = PathCommands

      let start_angle = rand.real() * Pi(2)
      let end_angle = start_angle + (rand.real() * Pi(2))
      let angle_step = 0.02 + (rand.real() * 0.05)

      for a in Range[F64](start_angle, end_angle, angle_step) do
        for (s, e) in arm.values() do
          let sx = (a.cos() * s) + x_o
          let sy = (a.sin() * s) + y_o
          let ex = (a.cos() * e) + x_o
          let ey = (a.sin() * e) + y_o

          pcs .> command(PathMove.abs(sx, sy)) .> command(PathLine.abs(ex, ey))
        end
      end

      nodes.push(SVG.path(pcs))
    end

    nodes

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()

    let rand = Rand

    svg.c(SVG.polyline([(30, 30); (730, 30); (730, 500)
      (30, 500); (30, 30)].values()))

    for n in Doodle001(250, 250, rand).values() do
      svg.c(n)
    end

    for n in Doodle002(500, 250, rand).values() do
      svg.c(n)
    end

    env.out.print(svg.render())
