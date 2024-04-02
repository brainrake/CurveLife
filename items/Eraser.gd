class_name Eraser
extends Power

func _init():
  icon = "eraser"
  super()

func apply(g : Game):
  for s in g.snakes:
    s.clear()
  pass
