class_name Slow
extends Powerup

func _init():
  duration = 4
  icon = "slow"
  super()

func init(s : Snake):
  super.init(s)
  s.speed /= 2.0

func finish(s : Snake):
  super.finish(s)
  s.speed *= 2.0