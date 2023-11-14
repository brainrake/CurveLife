extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	%SpinBox.value = get_node("/root/Global").num_players
	%PlayButton.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_button_pressed():
	get_node("/root/Global").num_players = %SpinBox.value
	get_tree().change_scene_to_file("res://Game.tscn")
