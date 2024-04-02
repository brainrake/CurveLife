class_name Item
extends Area2D
signal pickedup()
static var shader : Shader = preload("res://shade/item.gdshader")
static var radius = 50.0

var color : Color = Color.WHITE

var icon = "missing"

var stackable := true

var duration = 1.0

var picked : bool = false

var timer : Timer
var type : String

var sprite : Sprite2D
var mat : ShaderMaterial

func fade(t : float):
  sprite.material.set_shader_parameter("fade", t)

func spawn():
  var tween = get_tree().create_tween()
  tween.set_trans(Tween.TRANS_CUBIC)
  tween.tween_method(fade, 1.0, 0.0, 0.3)


func pick():
  picked = true
  # visible = false
  pickedup.emit()
  var tween = get_tree().create_tween()
  tween.set_trans(Tween.TRANS_CUBIC)
  tween.tween_method(fade, 0.0, 1.0, 0.2)
  tween.tween_callback(func(): visible = false)

func init(_s : Snake):
  if duration > 0:
    timer.start()
  pass

func finish(_s : Snake):
  pass

func get_type() -> String:
  var ls = get_script().resource_path.split("/")
  return ls[ls.size() - 1].split(".")[0]

func _init():
  type = get_type()
  
  z_index = 0

  timer = Timer.new()
  timer.wait_time = duration
  timer.one_shot = true
  add_child(timer)

  # var poly = Util.circle_poly(Item.radius, 32)
  # poly.color = color
  # add_child(poly)

  var shape = CollisionShape2D.new()
  shape.shape = CircleShape2D.new()
  shape.shape.radius = Item.radius
  add_child(shape)

  sprite = Sprite2D.new()
  sprite.texture = load("res://art/%s.png" % icon)
  sprite.texture_filter = TEXTURE_FILTER_NEAREST
  sprite.scale = Vector2.ONE * (radius * 2) / (64.0) * 1.0
  sprite.material = ShaderMaterial.new()
  sprite.material.shader = shader
  sprite.material.set_shader_parameter("color", color)
  sprite.material.set_shader_parameter("fade", 0.0)
  add_child(sprite)


func time_left() -> float:
  if timer.is_stopped(): return 0
  else:
    return timer.time_left / timer.wait_time