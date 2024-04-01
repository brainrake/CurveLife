class_name Cleaner
extends Powerup

func _init():
  duration = 4
  stackable = false
  icon = "missing"
  super()

func init(s : Snake):
  super.init(s)
  s.cleaning = true

func finish(s : Snake):
  super.finish(s)
  s.cleaning = false