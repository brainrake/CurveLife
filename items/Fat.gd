class_name Fat
extends Powerdown

func _init():
  duration = 4
  icon = "fat"
  super()

func init(s : Snake):
  super.init(s)
  s.call_deferred("mult_size", 2)

func finish(s : Snake):
  super.finish(s)
  s.call_deferred("mult_size", 0.5)