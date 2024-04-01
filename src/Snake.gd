class_name Snake
extends Node2D

signal died(i : int)
signal pickedup(p : Player, item : Item)
signal finished(p : Player, item : Item)

static var base_radius := 10.0
static var base_speed := 200.0
static var base_turn := 2.5
static var base_hole_chance := 0.012

static var arc_width := 4
static var arc_spacing := 4

var font := preload("res://font/RubikMonoOne-Regular.ttf")

var skin_material : ShaderMaterial

var turn := 1.0            
var speed := 1.0
var size := 1.0
var min_distance := 2.0

var dead := false
var reversed := false
var flying := false
var rotating := false
var cleaning := false
var wrapping := false

var hole := false
var hole_chance := 1.0
var hole_distance := 0.0
var hole_size := 2.5

var length := 0.0
var last_length := 0.0

var body : StaticBody2D
var head : Area2D
var item_picker : CollisionShape2D

var last_pos := Vector2.ZERO
var last_segment : PackedVector2Array = []
var last_poly : ConvexPolygonShape2D
var last_shape : CollisionShape2D

var collider : Area2D
var placeholder_tex := Texture2D.new()

var player : Player

var invincible_timer : Timer

var spawning := true

var items : Array[Item] = []

func _ready():
  pass

func forward() -> Vector2:
  return transform.basis_xform(Vector2.UP)

func get_poly(a : PackedVector2Array, b : PackedVector2Array) -> PackedVector2Array:
  return [
    a[1],
    a[0],
    b[0],
    b[1]
  ]

func get_hole_chance():
  return base_hole_chance * hole_chance


func finish_item(item : Item):
  if not item.stackable:
    var same = items.filter(
      func(x : Item): 
        return x.type == item.type and x.get_instance_id() != item.get_instance_id())
    if same.is_empty():
      item.finish(self)
  else:
    item.finish(self)
  var index = items.find(item)
  if index != -1:
    items.remove_at(index)

func apply(item : Item):
  item.init(self)
  items.push_back(item)
  item.timer.timeout.connect(finish_item.bind(item))

func pickup(area : Area2D):
  if area is Item:
    var item : Item = area as Item
    if not item.picked:
      item.pick()

      if item is Powerup:
        apply(item)
      elif item is Powerdown:
        pickedup.emit(player, item)
      elif item is Power:
        pickedup.emit(player, item)


    
func radius() -> float:
  return max(size * base_radius, 1)


func get_segment(pos : Vector2, dir : Vector2) -> PackedVector2Array:
  var side = dir.rotated(PI * 0.5) * radius()
  var points : PackedVector2Array = [
    pos + side,
    pos - side,
  ]
  return points

func update_head():
  item_picker.shape.radius = radius()

func create_body() -> StaticBody2D:
  var b := StaticBody2D.new()
  b.z_index = 1
  Util.set_collision(b, 1, [false, false, false])
  return b


func _init(p : Player, pos : Vector2, dir : Vector2, parent : Node2D):
  z_index = 3
  player = p
  skin_material = Skins.get_material(player.skin)
  
  placeholder_tex = Util.empty_tex(2,2)

  position = pos
  rotation = dir.angle()

  body = create_body()

  head = Area2D.new()
  item_picker = CollisionShape2D.new()
  item_picker.shape = CircleShape2D.new()
  item_picker.shape.radius = radius()
  head.area_entered.connect(pickup)
  # head.body_shape_entered.connect(on_head_entered_body)
  head.add_child(item_picker)
  Util.set_collision(head, 3, [true, false, true])

  collider = Area2D.new()
  collider.body_entered.connect(on_body_entered)
  Util.set_collision(collider, 1, [true, true, false])

  update_head()

  add_child(head)

  invincible_timer = Timer.new()
  add_child(invincible_timer)
  invincible_timer.wait_time = 5
  invincible_timer.one_shot = true
  invincible_timer.timeout.connect(begin)

  parent.add_child(self)
  parent.add_child(body)
  parent.add_child(collider)

func get_uv() -> PackedVector2Array:
  return [
    Vector2(0, last_length),
    Vector2(1, last_length),
    Vector2(1, length),
    Vector2(0, length),
  ]

func start():
  invincible_timer.start()

func begin():
  spawning = false
  last_pos = position

func clear():
  get_parent().remove_child(body)
  body.queue_free()
  body = create_body()
  get_parent().add_child(body)

func finish_poly():
  if last_shape:
    collider.remove_child(last_shape)
    body.add_child(last_shape)
    last_shape = null


func mult_size(value : float):
  finish_poly()
  size *= value
  last_segment = get_segment(position, forward())
  

func add_poly():
  if last_segment.is_empty():
    return

  var new_segment := get_segment(position, forward())

  var last = [
    last_segment[0] + forward() * 0.01,
    last_segment[1] + forward() * 0.01
  ]
  var points := get_poly(last, new_segment)

  var seg := ConvexPolygonShape2D.new()
  seg.set_points(points)
  var shape := CollisionShape2D.new()
  shape.shape = seg

  finish_poly()

  if shape:
    collider.add_child(shape)
    last_shape = shape
    last_poly = last_shape.shape

  var poly = Polygon2D.new()
  poly.polygon = get_poly(last_segment, new_segment)
  poly.material = skin_material
  poly.texture = placeholder_tex
  poly.uv = get_uv()

  shape.add_child(poly)


func update_poly(segment : PackedVector2Array):
  if last_poly == null or segment.is_empty():
    return
  # var segment = get_segment(pos, dir)
  last_poly.points[2] = segment[0]
  last_poly.points[3] = segment[1]
  last_poly.set_points(last_poly.points)

  # var poly = visual.get_child(visual.get_child_count() - 1)
  # poly.polygon[2] = segment[0]
  # poly.polygon[3] = segment[1]

  # poly.uv[2] = Vector2(1, length)
  # poly.uv[3] = Vector2(0, length)

func distance_traveled() -> float:
  return last_pos.distance_to(position)

func is_flying() -> bool:
  return not invincible_timer.is_stopped() or flying

func update(input : float, delta : float):
  if dead: return
  rotation += (turn * base_turn) * (input * (-1 if reversed else 1)) * delta
  position += forward() * (speed * base_speed) * delta



  var segment = get_segment(position, forward())
  
  update_head()

  var stopped_hole := false

  if not is_flying():
    if not hole:
      if randf() < get_hole_chance():
        hole = true
        hole_distance = 0
    else:
      hole_distance += distance_traveled()
      if hole_distance > (ceil(size) * base_radius) * hole_size * 2.0:
        hole = false
        stopped_hole = true
        add_poly()

    if not hole and not stopped_hole:		
      if rotating:
        if input == 0:
          rotating = false
          add_poly() # update_poly(segment)
        else:
          add_poly()
      else:
        if input != 0:
          rotating = true
          add_poly()
        else:
          add_poly() # update_poly(segment)

  last_length = length
  length += distance_traveled()

  last_segment = segment
  last_pos = position

func die():
  dead = true
  died.emit(player.index)

func teleport(pos : Vector2, rot : float):
  invincible_timer.start()
  finish_poly()
  position = pos
  rotation = rot

# cleaner item
# func on_head_entered_body(_body_rid: RID, owner_body: Node2D, body_shape_index: int, _local_shape_index: int):
#   if cleaning and owner_body.get_instance_id() != body.get_instance_id():
#     var body_shape_owner = owner_body.shape_find_owner(body_shape_index)
#     var shape = owner_body.shape_owner_get_owner(body_shape_owner)

#     shape.get_parent().remove_child(shape)
#     shape.queue_free()

func on_body_entered(b : CollisionObject2D):
  if not hole:
    if not wrapping or not b.get_collision_layer_value(2):
      die()
  pass

func show_time(i : int, c : Color, t : float):
  var offset = - PI * 0.5
  draw_arc(
    Vector2.ZERO, radius() + arc_width * 2 + i * (arc_width + arc_spacing), 
    offset, offset + TAU * t, 
    32, c,
    arc_width, false
  )

func _draw():
  if spawning:
    var font_size := 24
    draw_string(font, Vector2.UP * radius() * 2.5 + Vector2.LEFT * (font_size * 1.1), player.map.show_dir(), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Skins.colors.colors[player.skin])

  for i in items.size():
    var item : Item = items[i]
    var c = Skins.color.green 
    if item is Powerdown:
      c = Skins.color.red
    show_time(i, c, item.time_left())

  if not invincible_timer.is_stopped():
    show_time(items.size(), Color.WHITE, invincible_timer.time_left / invincible_timer.wait_time)

  draw_circle(Vector2.ZERO, radius(), Skins.colors.colors[player.skin])

  if reversed:
    draw_circle(Vector2.ZERO, radius() * 0.65, Color.BLACK)


func mult(field : String, value : float):
  self[field] *= value

func _process(_delta : float):
  queue_redraw()