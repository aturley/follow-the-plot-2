use "collections"
use "random"

primitive RandIn
  fun apply(rand: Random, min: F64, max: F64): F64 =>
    let d = max - min
    min + (rand.real() * d)

class RandomRange
  """
  An iterator that returns `count` random values using the supplied `Random`.
  """

  let _rand: Random
  var _remaining: USize

  new create(rand: Random, count: USize) =>
    _rand = rand
    _remaining = count

  fun ref next(): F64 ? =>
    if _remaining > 0 then
      _remaining = _remaining - 1
      _rand.real()
    else
      error
    end

  fun ref has_next(): Bool =>
    _remaining > 0

class RandomStepsTo
  """
  An iterator that returns random incrementing values from `start` to `stop`,
  where the step range is between the values of `min_step` and `max_step`. The
  `start` value is included, the `stop` value is excluded.
  """

  let _rand: Random
  let _start: F64
  let _stop: F64
  let _min_step: F64
  let _max_step: F64
  var _cur: F64

  new create(rand: Random, start: F64, stop: F64, min_step: F64, max_step: F64)
  =>
    _rand = rand
    _start = start
    _stop = stop
    _min_step = min_step
    _max_step = max_step
    _cur = start

  fun ref next(): F64 ? =>
    if _cur < _stop  then
      _cur = _cur + RandIn(_rand, _min_step, _max_step)
    else
      error
    end

  fun ref has_next(): Bool =>
    _cur < _stop

class RandomFixStepsTo
  """
  An iterator that returns random incrementing values from `start` to `stop`.
  There will always be `steps` number of values returned, in increasing order.
  """

  let _iterator: Iterator[F64]

  new create(rand: Random, start: F64, stop: F64, steps: USize) =>
    let items = Array[F64]
    items.push(start)

    for _ in Range(0, steps - 2) do
      items.push(RandIn(rand, start, stop))
    end

    items.push(stop)

    Sort[Array[F64], F64](items)

    _iterator = items.values()

  fun ref next(): F64 ? =>
    _iterator.next()?

  fun ref has_next(): Bool =>
    _iterator.has_next()

class RandomExclusiveFixStepsTo
  """
  An iterator that returns random incrementing values between `start` and
  `stop`. There will always be `steps` number of values returned, in increasing order.
  """

  let _iterator: Iterator[F64]

  new create(rand: Random, start: F64, stop: F64, steps: USize) =>
    let items = Array[F64]

    for _ in Range(0, steps) do
      items.push(RandIn(rand, start, stop))
    end

    Sort[Array[F64], F64](items)

    _iterator = items.values()

  fun ref next(): F64 ? =>
    _iterator.next()?

  fun ref has_next(): Bool =>
    _iterator.has_next()
