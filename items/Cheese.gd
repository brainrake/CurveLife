class_name Cheese
extends Powerdown

func _init():
  duration = 4
  icon = "cheese"
  super()

func init(s : Snake):
  super.init(s)
  s.hole_chance += 10.0

func finish(s : Snake):
  super.finish(s)
  s.hole_chance -= 10.0
