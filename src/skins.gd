class_name Skins
extends Node

static var colors : Gradient = preload("res://shade/colors.tres")
static var snake_shader : Shader = preload("res://shade/snake.gdshader")

static var skins : Array[ShaderMaterial]

static var available_colors : Array[int]

static var color_names : Array[String]= [
  "red",
  "orange",
  "yellow",
  "green",
  "cyan",
  "blue",
  "purple",
  "pink",
  "white",
  "gray",
]

static var color : Dictionary

# static func get_color_by_name(n : String) -> Color:
#   var i = color_names.find(n)
#   if i > -1:
#     return colors.colors[i]
#   else:
#     return Color.MAGENTA

static func generate():
  available_colors = []
  skins = []
  for i in colors.colors.size():
    var c := colors.colors[i]
    var image := Image.create(2, 2, false, Image.FORMAT_RGBA8)
    image.fill(c)

    var m = ShaderMaterial.new()
    m.shader = snake_shader
    m.set_shader_parameter("tex", ImageTexture.create_from_image(image))
    m.resource_name = color_names[i]
    
    available_colors.push_back(skins.size())
    skins.push_back(m)

    color[color_names[i]] = c
  

static func get_skin(previous : int = -1, dir : int = 1) -> int:
  if previous != -1:
    available_colors.push_back(previous)
    available_colors.sort()
    var index = available_colors.find(previous)
    return available_colors.pop_at((index + dir) % available_colors.size())
  else:
    return available_colors.pop_front()

static func get_material(index : int) -> ShaderMaterial:
  return skins[index]