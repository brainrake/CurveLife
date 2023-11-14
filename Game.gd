extends Node2D

enum GameState {Countdown, Running, Ended}

@export var game_state = GameState.Countdown

var load_time
var winner

var colors = [
	Color("red"),
	Color("green"),
	Color("blue"),
	Color("cyan"),
	Color("yellow"),
	Color("magenta"),
	Color("gray"),
	Color("lightgray")
]

func _make_player(number, total):
	var player = %Player.duplicate()
	player.name = "Player" + str(number)
	player.visible = true
	player.transform = player.transform.translated(Vector2(0,50)).rotated(TAU * number / total)
	player.get_node("Body").default_color = colors[number]
	player.speed = 0.0;
	player.control_left = "player" + str(number) + "_left"
	player.control_right = "player" + str(number) + "_right"
	return player

# Called when the node enters the scene tree for the first time.
func _ready():
	load_time = Time.get_unix_time_from_system()
	var num_players = get_node("/root/Global").num_players
	for i in range(0, num_players):
		$Field.add_child(_make_player(i, num_players))
	$Field.remove_child($Field/Player)

func is_game_over():
	var num_players = get_node("/root/Global").num_players
	var winner = null
	for i in range(0, num_players):
		if not $Field.get_node("Player"+str(i)).dead:
			if winner == null:
				winner = i
			else:
				return
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var num_players = get_node("/root/Global").num_players
	if game_state == GameState.Countdown:
		# print(Time.get_unix_time_from_system() - load_time)
		if Time.get_unix_time_from_system() - load_time >= 1:
			game_state = GameState.Running
			$Countdown.visible = false
			for i in range(0, num_players):
				get_node("Field/Player"+str(i)).speed = 20
	elif game_state == GameState.Running:
		if is_game_over():
			game_state = GameState.Ended
			%GameOver.set_visible(true)
			%GameOverButton.grab_focus()
	elif game_state == GameState.Ended:
		pass

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Menu.tscn")

func _on_field_collider_area_exited(area):
	print("exited area: " + area.get_parent().name + area.name + " ")
	if area.get_parent().name.begins_with("Player"):
		area.get_parent().dead = true


func _on_field_collider_body_exited(body):
	print("exited body: " + body.get_parent().name + body.name + " ")
	pass # Replace with function body.


func _on_field_collider_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	print("exited area_shape: " + area.get_parent().name + area.name + " ")
	pass # Replace with function body.
