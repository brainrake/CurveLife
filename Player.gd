extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


@export var dead := false

# Movement speed in pixels per second.
@export var speed := 0.0
# Rotation speed in radians per second.
@export var angular_speed := 2.0
# Line width
@export var width := 2.0

# Controls
@export var control_left := ""
@export var control_right := ""

func make_segment(distance, angle, width):
#	print("D:", distance, " A:", angle, " W:",width)
	return [
		Vector2(-width/2, 0.1),
		Vector2(width/2, 0.1),
		(Vector2(0, distance) + Vector2(width/2, 0).rotated(angle)),
		(Vector2(0, distance) - Vector2(width/2, 0).rotated(angle)),
	]

func _physics_process(delta):
	if dead:
		return
	if ! speed > 0:
		return

	var old_origin = Vector2($Head.transform.origin)
	var old_rotation = $Head.rotation
	var old_head_shape = $Head/CollisionShape2D.shape

	var rotate_direction = Input.get_action_strength(control_right) - Input.get_action_strength(control_left)
	var angle = rotate_direction * angular_speed * delta
	var new_rotation = $Head.rotation + angle
	var velocity = $Head.transform.y * speed
	var new_origin = old_origin + velocity * delta

	var new_head_shape = ConvexPolygonShape2D.new()
	var point_cloud = make_segment(speed * delta, angle, width)
	new_head_shape.set_point_cloud(point_cloud)

	if old_head_shape != null:
		var new_body_part = CollisionShape2D.new()
		new_body_part.shape = old_head_shape;
		new_body_part.transform.origin = old_origin
		new_body_part.rotation = old_rotation
		$Body/StaticBody2D.add_child(new_body_part)

	$Head.rotation = new_rotation
	$Head.transform.origin = new_origin
	$Head/CollisionShape2D.set_shape(new_head_shape)


	var points = $Body.points
	points.append($Head.transform.get_origin())
	$Body.points = points

#	if points.size() >= 3:
#		var new_shape = CollisionShape2D.new()
#		$Body/StaticBody2D.add_child(new_shape)
#		var rect = RectangleShape2D.new()
#		var i = points.size() - 2
#		new_shape.position = (points[i] + points[i + 1]) / 2
#		new_shape.rotation = points[i].direction_to(points[i + 1]).angle()
#		var length = points[i].distance_to(points[i + 1])
#		var width = 2
#		rect.extents = Vector2(length / 2, width/2)
#		new_shape.shape = rect


func _on_head_body_entered(body):
	print (self.name + " collided with " + body.get_parent().get_parent().name + " " + body.get_parent().name)
	dead = true
