use "collections"
use "random"

interface XY
  fun xy(): (F64, F64)

class Agent[State: Any val]
  var _x: F64
  var _y: F64
  var _state: State
  let _step_fn: {ref (F64, F64, State): (F64, F64, State)} ref

  new create(x: F64, y: F64, state: State,
    step_fn: {ref (F64, F64, State): (F64, F64, State)} ref)
  =>
    _x = x
    _y = y
    _state = state
    _step_fn = step_fn

  fun ref step() =>
    (_x, _y, _state) = _step_fn(_x, _y, _state)

  fun string(): String iso^ =>
    ",".join([_x; _y].values())

  fun xy(): (F64, F64) =>
    (_x, _y)

primitive Doodle001
  fun apply(x_offset: F64, y_offset: F64): SVGNode =>
    let a1 = Agent[None](x_offset, y_offset + 10, None, {(x, y, _) => (x, y + 10, None)})
    let a2 = Agent[None](x_offset + 10, y_offset + 10, None, {(x, y, _) => (x + 10, y + 10, None)})

    let pcs = PathCommands

    for _ in Range(0, 5) do
      (let a1_x, let a1_y) = a1.xy()
      (let a2_x, let a2_y) = a2.xy()
      pcs
        .> command(PathMove.abs(a1_x, a1_y))
        .> command(PathLine.abs(a2_x, a2_y))
      a1.step()
      a2.step()
    end

    SVG.path(pcs)

primitive Doodle002
  fun apply(x_offset: F64, y_offset: F64, rand: Rand): SVGNode =>
    let a1 = Agent[None](x_offset, y_offset, None,
      {(x, y, _) =>
        (x, y_offset + (100 * rand.real()), None)})
    let a2 = Agent[None](x_offset + 100, y_offset, None,
      {(x, y, _) =>
        (x_offset + (100 * rand.real()), y, None)})
    let a3 = Agent[None](x_offset + 100, y_offset + 100, None,
      {(x, y, _) =>
        (x, y_offset + (100 * rand.real()), None)})
    let a4 = Agent[None](x_offset, y_offset + 100, None,
      {(x, y, _) =>
        (x_offset + (100 * rand.real()), y, None)})

    let pcs = PathCommands

    for _ in Range(0, 20) do
      (let a1_x, let a1_y) = a1.xy()
      (let a2_x, let a2_y) = a2.xy()
      (let a3_x, let a3_y) = a3.xy()
      (let a4_x, let a4_y) = a4.xy()
      pcs
        .> command(PathMove.abs(a1_x, a1_y))
        .> command(PathLine.abs(a2_x, a2_y))
        .> command(PathLine.abs(a3_x, a3_y))
        .> command(PathLine.abs(a4_x, a4_y))
        .> command(PathLine.abs(a1_x, a1_y))
      a1.step()
      a2.step()
      a3.step()
      a4.step()
    end

    SVG.path(pcs)

primitive LineOfXY
  fun apply(xys: Iterator[XY box], pcs: PathCommands = PathCommands):
    PathCommands
  =>
    try
      (let mx, let my) = xys.next()?.xy()

      pcs.command(PathMove.abs(mx, my))

      for xy in xys do
        (let x, let y) = xy.xy()
        pcs.command(PathLine.abs(x, y))
      end
    end

    pcs

class val Mouse
  var _x: F64
  var _y: F64

  new val create(x': F64, y': F64) =>
    _x = x'
    _y = y'

  fun xy(): (F64, F64) =>
    (_x, _y)

  fun move_to_fren(fren: Mouse): Mouse =>
    (let fx, let fy) = fren.xy()
    let dx = fx - _x
    let dy = fy - _y

    Mouse(_x + (0.1 * dx), _y + (0.1 * dy))

primitive Doodle003
  fun apply(x_off: F64, y_off: F64): SVGNode =>
    var m1 = Mouse(x_off, y_off)
    var m2 = Mouse(x_off, y_off + 200)
    let x: F64 = ((200 * 200) - (100 * 100))
    var m3 = Mouse(x_off + x.sqrt(),  y_off + 100)

    let pcs = LineOfXY([m1; m2; m3; m1].values())

    for _ in Range(0, 20) do
      (m1, m2, m3) = (m1.move_to_fren(m2), m2.move_to_fren(m3),
        m3.move_to_fren(m1))
      LineOfXY([m1; m2; m3; m1].values(), pcs)
    end

    SVG.path(pcs)

primitive Doodle004
  fun apply(x_offset: F64, y_offset: F64, step: F64, iters: USize): SVGNode =>
    let a1 = Agent[F64](x_offset, y_offset, 0,
      {(x, y, pos) =>
        (x + (pos.cos() * 10).abs(), y, pos + step)})

    let a2 = Agent[F64](x_offset, y_offset + 30, 0,
      {(x, y, pos) =>
        (x + (pos.sin() * 10).abs(), y, pos + step)})

    let pcs = PathCommands

    for _ in Range(0, iters) do
      LineOfXY([a1; a2].values(), pcs)
      a1.step()
      a2.step()
    end

    SVG.path(pcs)

actor Main
  new create(env: Env) =>

    let rand = Rand

    let svg = SVG.svg()

    svg.c(Doodle001(100, 100))
    svg.c(Doodle002(300, 100, rand))
    svg.c(Doodle003(500, 100))
    svg.c(Doodle004(100, 350, 0.05, 90))
    svg.c(Doodle004(100, 400, 0.1, 90))
    svg.c(SVG.polyline([(50, 50); (750, 50); (750, 500); (50, 500); (50, 50)].values()))

    env.out.print(svg.render())
