class_name Thin
extends Powerup

func _init():
  duration = 8
  icon = "thin"
  super()

func init(s : Snake):
  super.init(s)
  s.call_deferred("mult_size", 0.5)

func finish(s : Snake):
  super.finish(s)
  s.call_deferred("mult_size", 2)