use "collections"

class Grid[T: Any val]
  let _cells: Array[Array[T]]

  new create(w: USize, h: USize, init: T) =>
    _cells = _cells.create()

    for i in Range(0, w) do
      let a = Array[T]
      for j in Range(0, h) do
        a.push(init)
      end
      _cells.push(a)
    end

  fun ref set(w: USize, h: USize, v: T) ? =>
    _cells(w)?(h)? = v

  fun get(w: USize, h: USize): T ? =>
    _cells(w)?(h)?
