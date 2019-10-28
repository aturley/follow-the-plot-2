primitive Rect
  fun apply(sx: F64, sy: F64, ex: F64, ey: F64): SVGNode =>
    SVG.polyline([(sx, sy); (ex, sy); (ex, ey); (sx, ey); (sx, sy)].values())
