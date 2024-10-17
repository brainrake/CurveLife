class_name CircleField
extends Field

var radius : float

func _init(r : float):
  radius = r
  super(Util.circle(r, 256))

func random_pos() -> Vector2:
  var p = randf() * TAU
  return Vector2(cos(p), sin(p)) * (radius - Item.radius) * randf()
