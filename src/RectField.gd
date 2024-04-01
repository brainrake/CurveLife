class_name RectField
extends Field

var width : int
var height : int

func _init(w : int, h : int):
  width = w
  height = h
  super(Util.rectangle(w, h))

func random_pos() -> Vector2:
  return (
    (Vector2(randf(), randf()) * 2.0 - Vector2.ONE) 
    * (Vector2(width, height) - Vector2.ONE * Item.radius * 2)
  ) * 0.5 