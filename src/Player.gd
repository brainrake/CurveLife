class_name Player
extends Node

signal changed_score(s : int)
signal changed_skin(s : int)

var index : int = -1
var map : ControlMap
var disabled : bool = false

var skin : int = -1

var score : int = 0

func show_controls() -> String:
  return map.show_short()
  
func show_skin() -> String:
  return Skins.get_material(skin).resource_name

func set_score(s : int):
  score = s
  changed_score.emit(score)

func set_skin(s : int):
  skin = s
  changed_skin.emit(skin)

func _init(i : int, m : ControlMap):
  index = i
  map = m

func input() -> float:
  if disabled: 
    return 0
  else:
    return Input.get_axis("left" + str(index), "right" + str(index))

func pressed() -> int:
  if Input.is_action_just_pressed("left" + str(index)):
    return -1
  elif Input.is_action_just_pressed("right" + str(index)):
    return 1
  else:
    return 0