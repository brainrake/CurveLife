class_name RedSpeed
extends Powerdown

func _init():
  duration = 3
  icon = "speed"
  super()

func init(s : Snake):
  super.init(s)
  s.speed *= 2.0

func finish(s : Snake):
  super.finish(s)
  s.speed /= 2.0
