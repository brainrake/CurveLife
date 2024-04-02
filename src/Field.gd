class_name Field
extends Area2D

var polygon : PackedVector2Array
var visual : Polygon2D
var border : StaticBody2D
var line : Line2D

static var line_color := Color.GRAY

func _init(ps : PackedVector2Array):
  polygon = ps

  set_collision_layer_value(1, false)
  set_collision_layer_value(2, true)
  z_index = -1

  var shape = CollisionShape2D.new()
  shape.shape = ConvexPolygonShape2D.new()
  shape.shape.set_points(polygon)

  visual = Polygon2D.new()
  visual.polygon = polygon
  visual.color = Color.BLACK

  line = Line2D.new()
  line.points = polygon
  line.closed = true
  line.z_index = 10
  line.default_color = line_color


  border = StaticBody2D.new()

  for i in ps.size():
    var p : Vector2 = ps[i]
    var n : Vector2 = ps[(i + 1) % ps.size()]
    var c := CollisionShape2D.new()
    c.shape = WorldBoundaryShape2D.new()
    c.position = p.lerp(n, 0.5)
    c.shape.normal = c.position.direction_to(Vector2.ZERO)
    border.add_child(c)
    Util.set_collision(border, 2, [false, false, false])


  add_child(line)
  add_child(border)
  add_child(visual)
  add_child(shape)


func random_pos() -> Vector2:
  return Vector2.ZERO

func wrap(s : Snake):
  pass