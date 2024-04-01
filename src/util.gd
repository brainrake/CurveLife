class_name Util
extends Object

static func circle(r:float, s : int = 32):
  var arr : PackedVector2Array = []
  for i in s:
    var p : float = (float(i) / float(s)) * TAU
    arr.push_back(Vector2(cos(p), sin(p)) * r)
  return arr

static func circle_poly(r:float, s : int = 32):
  var poly := Polygon2D.new()
  poly.polygon = circle(r, s)
  poly.uv = circle(1.0, s)
  return poly

static func sort_children(n : Node, compare : Callable):
  var ls := n.get_children()
  ls.sort_custom(compare)

  for c in ls:
    n.remove_child(c)
  
  for c in ls:
    n.add_child(c)

static func rectangle(w : float, h : float) -> PackedVector2Array:
  w = w / 2.0
  h = h / 2.0
  return [
    Vector2(w, -h),
    Vector2(w, h),
    Vector2(-w, h),
    Vector2(-w, -h),
  ]

static func find(a : Array[Variant], f : Callable) -> Variant:
  for x in a:
    if f.call(x):
      return x
  return null

static func clear_children(n : Node):
  for c in n.get_children():
    n.remove_child(c)
    c.queue_free()

static func empty_tex(w : int, h : int) -> Texture2D:
  return ImageTexture.create_from_image(Image.create(w, h, false, Image.FORMAT_RGBA8))

static func set_collision(n : CollisionObject2D, layer : int, mask : Array[bool]):
  for i in 16:
    n.set_collision_layer_value(i + 1, (i + 1) == layer)
  for i in mask.size():
    n.set_collision_mask_value(i + 1, mask[i])