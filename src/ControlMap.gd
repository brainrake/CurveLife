class_name ControlMap
extends Resource

static var possible_actions : Array[StringName] = [
	&"left",
	&"right",
]

var left : int
var right : int
var axis : int
var device : int

func _init(l : int, r : int, a : int = -1, d : int = -1):
  left = l
  right = r
  axis = a
  device = d

func show() -> String:
  if device == -1:
    return "%s-%s" % [button_string(left), button_string(right)]
  else:
    return "j%s R / A-B" % [device]

func button_string(code : int) -> String:
  match code:
    KEY_LEFT:
      return "<"
    KEY_RIGHT:
      return ">"
    _:
      return OS.get_keycode_string(code)

func show_short() -> String:
  if device == -1:
    return "%s-%s" % [button_string(left), button_string(right)]
  else:
    return "(%s)" % [device]

func show_dir() -> String:
  if device == -1:
    return "%s^%s" % [button_string(left), button_string(right)]
  else:
    return "(%s)" % [device]
