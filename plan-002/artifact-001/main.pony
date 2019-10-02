use "collections"
use "random"

// (angle, distance)
type RadialPoint is (F64, F64)

class RadialControls
  let _points: Array[RadialPoint]

  new create() =>
    _points = _points.create()

  fun ref add(p: RadialPoint) =>
    _points.push(p)

  fun interpolate_from_angle(angle: F64): (F64 | None) =>
    var prev: (None | RadialPoint) = None
    var next: (None | RadialPoint) = None

    for (a, d) in _points.values() do
      match (prev, next)
      | (None, None) =>
        next = (a, d)
      | (None, _) =>
        prev = next = (a, d)
      | (_, _) =>
        prev = next = (a, d)
      end

      if (a > angle) then
        match (prev, next)
        | (let next': RadialPoint, let prev': RadialPoint) =>
          let d_a = next'._1 - prev'._1

          if (d_a == 0) then
            return None
          end

          let d_r = next'._2 - prev'._2

          let progress = (angle - prev'._1) / d_a

          return prev'._2 + (progress * d_r)
        else
          return None
        end
      end
    end

class Ribbon
  let _rc1: RadialControls
  let _rc2: RadialControls

  new create(rc1: RadialControls, rc2: RadialControls) =>
    _rc1 = rc1
    _rc2 = rc2

  fun interpolate_from_angle(angle: F64): (None | ((F64, F64), (F64, F64))) =>
    match (_rc1.interpolate_from_angle(angle), _rc2.interpolate_from_angle(angle))
    | (let d1: F64, let d2: F64) =>
      let x1 = angle.cos() * d1
      let y1 = angle.sin() * d1
      let x2 = angle.cos() * d2
      let y2 = angle.sin() * d2
      ((x1, y1), (x2, y2))
    end

primitive Pi
  fun apply(): F64 => 3.1415926535

  fun frac(n: F64, d: F64): F64 => (apply() * n) / d

primitive Pi2
  fun apply(): F64 => 3.1415926535 * 2

  fun frac(n: F64, d: F64): F64 => (apply() * n) / d

primitive GenerateRibbon
  fun apply(start_radius: F64,
    min_r_step: F64, max_r_step: F64,
    start_angle: F64, end_angle: F64,
    min_a_step: F64, max_a_step: F64,
    rand: Rand):
    RadialControls
  =>
    let rc = RadialControls

    var r = start_radius
    var a = start_angle

    let delta_r = max_r_step - min_r_step
    let delta_a = max_a_step - min_a_step

    rc.add((a, r))

    repeat
      r = r + (max_r_step - (delta_r * rand.real()))
      a = a + (max_a_step - (delta_a * rand.real()))
      rc.add((a, r))
    until a > end_angle end

    rc

actor Main
  new create(env: Env) =>
    let num_ribbons: USize = 4

    let rand = Rand

    let ribbons = Array[Ribbon]

    for _ in Range(0, num_ribbons) do
      let rc3 = GenerateRibbon(50,
        -5, 5,
        0, Pi2() * 2,
        0.1, 0.5,
        rand)

      let rc4 = GenerateRibbon(100,
        -10, 10,
        0, Pi2() * 2,
        0.1, 0.5,
        rand)

      ribbons.push(Ribbon(rc3, rc4))
    end

    let svg = SVG.svg()

    svg.c(SVG.polyline([(30, 30); (570, 30); (570, 570)
      (30, 570); (30, 30)].values()))

    for x in Range[F64](0, 300, 150) do
      for y in Range[F64](0, 300, 150) do

        for ribbon in ribbons.values() do
          let pcs = PathCommands

          let center_x: F64 = 200 + x + (20 * rand.real())
          let center_y: F64 = 200 + y + (20 * rand.real())

          for a in Range[F64](Pi2() * rand.real(),
            Pi2() + (Pi2() * rand.real()), 0.05)
          do
            match ribbon.interpolate_from_angle(a)
            | ((let x1: F64, let y1: F64), (let x2: F64, let y2: F64)) =>
              pcs.command(PathMove.abs(center_x + x1, center_y + y1))
              pcs.command(PathLine.abs(center_x + x2, center_y + y2))
            end
          end
          svg.c(SVG.path(pcs))
        end

      end
    end

    env.out.print(svg.render())

