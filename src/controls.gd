class_name Controls
extends Node

signal player_joined(p : Player)

func controller_map(device : int):
  return ControlMap.new(JOY_BUTTON_A, JOY_BUTTON_B, JOY_AXIS_RIGHT_X, device)

var maps = [
  ControlMap.new(KEY_Q, KEY_W),
  ControlMap.new(KEY_A, KEY_S),
  ControlMap.new(KEY_Z, KEY_X),
  ControlMap.new(KEY_F, KEY_G),
  ControlMap.new(KEY_J, KEY_K),
  ControlMap.new(KEY_LEFT, KEY_RIGHT),
  ControlMap.new(KEY_O, KEY_P),
  ControlMap.new(KEY_N, KEY_M),
  controller_map(0),
  controller_map(1),
  controller_map(2),
  controller_map(3),
  controller_map(4),
  controller_map(5),
  controller_map(6),
  controller_map(7),
]


func player_exists(map : ControlMap):
  for c in get_children():
    if map.device != -1:
      if c.map.device == map.device:
        return true
    else:
      if c.map.left == map.left:
        return true
  return false

func add_player(index : int, map : ControlMap):
  print("player added %s %s" % [index, map.show()])
  var p = Player.new(index, map)
  add_child(p)
  player_joined.emit(p)
  pass

func add_joy_axis_action(index : int, label : String, axis : int, polarity : int, device : int):
  var id = str(index)
  var ev = InputEventJoypadMotion.new()
  ev.device = device
  ev.axis = axis
  ev.axis_value = polarity
  InputMap.action_add_event(label + id, ev)

func add_joy_button_action(index : int, label : String, button : int, device : int):
  var id = str(index)
  var ev = InputEventJoypadButton.new()
  ev.button_index = button
  ev.device = device
  InputMap.action_add_event(label + id, ev)

func add_joy_move_axis_action(index : int, map : ControlMap):
  var id = str(index)
  InputMap.add_action("left" + id, 0.1)
  InputMap.add_action("right" + id, 0.1)

  add_joy_axis_action(index, "left", map.axis, -1, map.device)
  add_joy_axis_action(index, "right", map.axis, 1, map.device)
  add_joy_button_action(index, "left", map.left, map.device)
  add_joy_button_action(index, "right", map.right, map.device)

func add_key_action(index : int, label : String, key : int):
  var id = str(index)
  InputMap.add_action(label + id)
  var ev = InputEventKey.new()
  ev.physical_keycode = key
  InputMap.action_add_event(label + id, ev)

func add_key_move_axis_action(index : int, map : ControlMap):
  add_key_action(index, "left", map.left)
  add_key_action(index, "right", map.right)

func erase_player(index : int):
  for a in ControlMap.possible_actions:
    if InputMap.has_action(a + str(index)):
      InputMap.erase_action(a + str(index))

  for p in get_children():
    if p.index == index:
      p.disabled = true
      remove_child(p)
      return

func erase_all():
  for c in get_children():
    erase_player(c.index)

func try_register_joy(map : ControlMap):
  var index := get_child_count()
  if not player_exists(map):
    add_joy_move_axis_action(index, map)
    add_player(index, map)

func try_register_key(map : ControlMap):
  var index := get_child_count()
  if not player_exists(map):
    add_key_move_axis_action(index, map)
    add_player(index, map)


func map_from_joy_button(button : int, device : int) -> ControlMap:
  for m in maps:
    if m.device == device and (m.left == button or m.right == button):
      return m
  return null



func map_from_button(button : int) -> ControlMap:
  for m in maps:
    if m.left == button or m.right == button:
      return m
  return null

func map_from_axis(axis : int) -> ControlMap:
  for m in maps:
    if m.axis == axis:
      return m
  return null

func _input(e):
  if e is InputEventKey:
    if e.is_pressed():
      var m = map_from_button(e.physical_keycode)
      if m != null:
        try_register_key(m)
  elif e is InputEventJoypadButton:
    if Input.get_joy_name(e.device).contains("Touchpad"):
      return
    var m = map_from_joy_button(e.button_index, e.device)
    if m != null:
      try_register_joy(m)
  # elif e is InputEventJoypadMotion:
  #   var m = map_from_button(e.axis)
  #   if m != null:
  #     try_register_joy(m)

# func on_joy_connection_changed(device_id, connected):
#   if connected:
#     print("[joy] connected #", device_id, " ", Input.get_joy_name(device_id))
#     pass
#   else:
#     print("[joy] disconnected #", device_id, " ", Input.get_joy_name(device_id))
#     pass

# func _ready():
#   Input.joy_connection_changed.connect(on_joy_connection_changed)
#   pass
