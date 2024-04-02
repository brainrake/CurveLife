class_name Reverse
extends Powerdown

func _init():
  duration = 4
  stackable = false
  icon = "reverse"
  super()

func init(s : Snake):
  super.init(s)
  s.reversed = true

func finish(s : Snake):
  super.finish(s)
  s.reversed = false