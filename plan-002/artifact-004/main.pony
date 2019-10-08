use "collections"
use "random"

primitive Doodle001
  fun apply(x_o: F64, y_o: F64, rand: Random, out: OutStream): (PathCommands, PathCommands) =>
    let width: USize = 500
    let distances = Array[F64].init(3, width)

    let p_pcs = PathCommands
    let n_pcs = PathCommands

    var dir: I8 = 1
    var dh: F64 = 0.05

    var loc: USize = width / 2
    var cur_height: F64 = 0
    var cur_pcs = p_pcs
    var max_height = cur_height
    var steps_left: USize = 0

    for _ in Range (0, 50) do
      let wave_frac = 10 - (rand.real() * 5)
      let wave_amp = rand.real() * 2
      let skip_steps = (200 / cur_height).usize()
      steps_left = ((50 + (rand.real() * 200))).usize()

      for i in Range(0, steps_left) do

        cur_height = cur_height + dh  + ((i.f64() / wave_frac).cos() * wave_amp)
        max_height = cur_height.max(max_height)

        try
          if cur_height > distances(loc)? then
            let sx = ((((loc.f64() / width.f64()) * Pi(2))).cos() * (distances(loc)? + 2)) + x_o + (dir.f64() * 2)
            let sy = (((loc.f64() / width.f64()) * Pi(2)).sin() * (distances(loc)? + 2)) + y_o + (dir.f64() * 2)
            let ex = (((loc.f64() / width.f64()) * Pi(2)).cos() * cur_height) + x_o + (dir.f64() * 2)
            let ey = (((loc.f64() / width.f64()) * Pi(2)).sin() * cur_height) + y_o + (dir.f64() * 2)
            if (i % skip_steps) == 0 then
              cur_pcs.command(PathMove.abs(sx, sy))
              cur_pcs.command(PathLine.abs(ex, ey))
            end
            distances(loc)? = cur_height
          end

          loc = (loc.isize() + dir.isize()).usize() % width
        end
      end

      dir = -dir
      cur_pcs = if dir == 1 then
        p_pcs
      else
        n_pcs
      end

      dh = rand.real() * 0.05
    end

    (p_pcs, n_pcs)

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()
    let rand = Rand

    // svg.c(SVG.circle(325, 325, 300))

    svg.c(Rect(25, 25, 600, 600))

    (let p, let n) = Doodle001(325, 310, rand, env.err)

    svg.c(SVG.path(p where stroke = "black"))
    svg.c(SVG.path(n where stroke = "black"))

    env.out.print(svg.render())

primitive Rect
  fun apply(sx: F64, sy: F64, ex: F64, ey: F64): SVGNode =>
    SVG.polyline([(sx, sy); (ex, sy); (ex, ey); (sx, ey); (sx, sy)].values())

primitive Pi
  fun apply(numerator: F64 = 1, denominator: F64 = 1): F64 =>
    (3.145926535 * numerator) / denominator
