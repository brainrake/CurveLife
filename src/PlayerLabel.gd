class_name PlayerLabel
extends HBoxContainer

static var player_label := preload("res://node/PlayerLabel.tscn")

@onready var skin : ColorRect = $Control/ColorRect
@onready var score : Label = $Control/Score
@onready var label : Label = $Label
@onready var placement : Label = $Placement

var score_value : int = 0

func update_placement(i : int):
  placement.text = "%s." % i

func update_skin(index : int):
  skin.material = Skins.get_material(index)

func update_score(s : int):
  score_value = s
  score.text = str(s)

func update_label(t : String):
  label.text = t

static func descending(a : PlayerLabel, b : PlayerLabel) -> bool:
  return a.score_value > b.score_value

static func instance() -> PlayerLabel:
  return player_label.instantiate()
