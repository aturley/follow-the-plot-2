use "collections"
use "random"

// (angle, radius)
type RadialPoint is (F64, F64)

class GeneratorInf[T: Any val]
  var _v: T
  let _fn: {ref (T): T}

  new create(init: T, fn: {ref (T): T}) =>
    _v = init
    _fn = fn

  fun ref next(): T =>
    let old_v = _v = _fn(_v)
    old_v

  fun has_next(): Bool =>
    true

primitive Doodle001
  fun apply(x_o: F64, y_o: F64, rand: Random): SVGNode =>
    let pcs = PathCommands

    pcs.command(PathMove.abs(x_o, y_o))

    for (a, r) in GeneratorInf[(F64, F64)]((0, 0), {(x) => (x._1 + 0.1, x._2 + 0.1)}) do
      if a > 100 then
        break
      end

      let x = (a.cos() * r) + (rand.real() * 3)
      let y = (a.sin() * r) + (rand.real() * 3)

      pcs.command(PathLine.abs(x_o + x, y_o + y))

    end

    SVG.path(pcs)

primitive Doodle002
  fun apply(x_o: F64, y_o: F64, rand: Random): SVGNode =>
    let pcs = PathCommands

    pcs.command(PathMove.abs(x_o, y_o))

    for (a, r) in GeneratorInf[(F64, F64)]((0, 0), {ref (x) => (x._1 + (-0.03 + (0.1 * rand.real())), x._2 + 0.02)}) do
      if a > 100 then
        break
      end

      let x = (a.cos() * r) + (rand.real() * 3)
      let y = (a.sin() * r) + (rand.real() * 3)

      pcs.command(PathLine.abs(x_o + x, y_o + y))

    end

    SVG.path(pcs)

primitive Doodle003
  fun apply(x_o: F64, y_o: F64): SVGNode =>
    let pcs = PathCommands
    for (h, x) in GeneratorInf[(F64, F64)]((0, 0), {(arg) => (arg._1 + 0.1, arg._2 + (arg._1.cos().abs() * 5))}) do
      if x > 400 then
        break
      end

      pcs.command(PathMove.abs(x_o + x, y_o - (h * 5)))
      pcs.command(PathLine.abs(x_o + x, y_o + 10 + (h * 5)))
    end

    SVG.path(pcs)

primitive Doodle004
  fun apply(x_o: F64, y_o: F64): SVGNode =>
    let pcs = PathCommands
    for (_, a) in GeneratorInf[(F64, F64)]((0, 0), {(arg) => (arg._1 + 0.1, arg._2 + (arg._1.cos().abs() * 0.05))}) do
      if a > Pi(2) then
        break
      end

      let x1 = x_o + (a.cos() * 50)
      let y1 = y_o + (a.sin() * 50)

      let x2 = x_o + (a.cos() * 100)
      let y2 = y_o + (a.sin() * 100)

      pcs.command(PathMove.abs(x1, y1))
      pcs.command(PathLine.abs(x2, y2))
    end

    SVG.path(pcs)

actor Main
  new create(env: Env) =>
    let svg = SVG.svg()
    let rand = Rand

    svg.c(SVG.polyline([(30, 30); (730, 30); (730, 500)
      (30, 500); (30, 30)].values()))

    svg.c(Doodle001(200, 200, rand))

    svg.c(Doodle002(400, 200, rand))

    svg.c(Doodle003(50, 370))

    svg.c(Doodle004(600, 200))

    env.out.print(svg.render())

primitive Pi
  fun apply(numerator: F64 = 1, denominator: F64 = 1): F64 =>
    (3.145926535 * numerator) / denominator
