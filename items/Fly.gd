class_name Fly
extends Powerup

func _init():
  stackable = false
  duration = 5.1
  icon = "fly"
  super()

func init(s : Snake):
  super.init(s)
  s.flying = true
  s.call_deferred("finish_poly")

func finish(s : Snake):
  super.finish(s)
  s.flying = false
  s.call_deferred("finish_poly")