class_name Swap
extends Power

func _init():
  icon = "swap"
  super()

func apply(g : Game):
  var alive := g.snakes.filter(func(s : Snake) : return not s.player.disabled)
  if alive.size() < 2: return
  var shift = 1#randi_range(1, alive.size() - 2)
  var i = 0
  for s in alive:
    s.call_deferred("teleport", alive[(i + shift) % alive.size()].position, alive[(i + shift) % alive.size()].rotation)
    i += 1