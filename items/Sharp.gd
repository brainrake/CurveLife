class_name Sharp
extends Powerup

func _init():
  duration = 4
  icon = "sharp"
  super()

func init(s : Snake):
  super.init(s)
  s.turn *= 2.0

func finish(s : Snake):
  super.finish(s)
  s.turn /= 2.0
