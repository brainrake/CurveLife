class_name Game
extends Node

static var width_range := Vector2(300, 1000)
static var item_wait := Vector2(3.0, 10.0)
static var launch_wait := 5
static var spawn_wait := 3

var width := 850

enum State {
  lobby,
  launching,
  game,
  end,
  over,
}

@onready var music := $Music
@onready var spawn_sound := $SpawnSound
@onready var pick_sound := $PickSound
@onready var dead_sound := $DeadSound
@onready var win_sound := $WinSound

var lowpass : AudioEffectLowPassFilter

var items : Array[Script] = [
  Cheese,
  Swap,
  Fly,
  Eraser,
  Thin,
  Speed,
  RedSpeed,
  Slow,
  RedSlow,
  Fat,
  Reverse,
  Sharp,

  # Cleaner,
]

var state : State = State.lobby

var players : Array[Player] = []
var snakes : Array[Snake] = []

var match_goal := 1

var field : Field

@onready var controls = $Controls
@onready var menu = $UI/Menu
@onready var leaderboard = $UI/Menu/Leaderboard
@onready var message = $UI/Menu/Panel/Message
@onready var ending = $UI/Menu/Ending
@onready var endboard = $UI/Menu/Ending/List/EndBoard
@onready var winner_label = $UI/Menu/Ending/List/Winner

@onready var level = $Level
@onready var camera = $Camera2D

@onready var launch_timer = $LaunchTimer
@onready var spawn_timer = $SpawnTimer
@onready var item_timer = $ItemTimer

var round_winner : Player
var match_winner : Player

func on_player_pickedup(p : Player, item : Item):
  if item is Powerdown:
    for s in snakes:
      if s.player.index != p.index:
        s.apply(item)
  elif item is Power:
    item.apply(self)

func spawn_snake(player : Player):
  var s = Snake.new(
    player,
    field.random_pos(),
    Vector2.UP.rotated(randf() * TAU),
    level
  )
  s.died.connect(on_player_died)
  s.pickedup.connect(on_player_pickedup)

  snakes.push_back(s)

func create_field(w : int):
  var z := 900.0 / (w + 50)
  camera.zoom = Vector2(z, z)
  field = CircleField.new(w * 0.5)
  # field = RectField.new(w, w)
  level.add_child(field)

func clear_level():
  remove_child(level)
  level.queue_free()
  level = Node2D.new()
  add_child(level)

  snakes = []
  match_winner = null
  round_winner = null


func init_level():
  clear_level()
  match_goal = max((players.size() - 1) * 10, 1)
  width = clamp(players.size() * 190, width_range.x, width_range.y)
  item_timer.wait_time = item_wait.x
  create_field(width * 2)

func get_match_winner() -> Player:
  for p in players:
    if p.score >= match_goal:
      return p
  return null

func get_round_winner() -> Player:
  for p in players:
    if not p.disabled:
      return p
  return null

func on_player_died(index : int):
  players[index].disabled = true
  print("player died %s" % index)
  dead_sound.play()
  var alive : int = 0
  for p in players:
    if not p.disabled:
      p.set_score(p.score + 1)
      alive += 1

  if alive == 1 or players.size() == 1:
    if state == State.game:
      round_winner = get_round_winner() if players.size() > 1 else players[0]
      call_deferred("change_state", State.end)

func spawn_item():
  if state == State.game or state == State.end:
    var item = items[randi_range(0, items.size() - 1)].new()
    item.position = field.random_pos()
    level.add_child(item)
    item.spawn()
    spawn_sound.play()
    item.pickedup.connect(func(): pick_sound.play())
    Util.set_collision(item, 3, [false, false, false])

    item_timer.wait_time = randf_range(item_wait.x, item_wait.y)

func sort_leaderboard(_score : int):
  Util.sort_children(leaderboard, PlayerLabel.descending)

func on_player_joined(p : Player):
  spawn_sound.play()
  match state:
    State.lobby:
      var label := PlayerLabel.instance()
      leaderboard.add_child(label)

      p.changed_skin.connect(label.update_skin)
      p.changed_score.connect(label.update_score)
      p.changed_score.connect(sort_leaderboard)
      label.update_label(p.show_controls())

      p.set_skin(Skins.get_skin())

      label.score.text = ":)"

      players.push_back(p)

      message.text = "waiting for players...\npress space to start"


func game_over():
  music.stop()
  win_sound.play()
  Util.clear_children(endboard)

  winner_label.text = "%s wins the game!" % match_winner.show_skin()

  for p in players:
    var l := PlayerLabel.instance()
    endboard.add_child(l)
    l.update_label(p.show_skin())
    l.update_skin(p.skin)
    l.update_score(p.score)

  Util.sort_children(endboard, PlayerLabel.descending)

  var i := 1
  for l in endboard.get_children():
    l.update_placement(i)
    i += 1

func change_state(s : State):
  ending.visible = s == State.over
  message.get_parent().visible = s == State.launching or s == State.end or s == State.lobby

  match state:
    State.lobby:
      match s:
        State.launching:
          for p in players:
            p.set_score(0)

  state = s
  match state:
    State.lobby:
      clear_level()
      message.text = "waiting for players..."

    State.launching:
      match_winner = get_match_winner()
      if match_winner:
        change_state(State.over)
      else:
        init_level()
        round_winner = null
        # launch_timer.start()
        # await launch_timer.timeout
        change_state(State.game)
    State.game:
      for p in players:
        spawn_snake(p)
        # p.set_score(0)
        p.disabled = false
      spawn_timer.start()
      await spawn_timer.timeout
      for snake in snakes:
        snake.start()


      item_timer.start()
      if not music.playing:
        music.play()
    State.end:
      launch_timer.start()
      await launch_timer.timeout
      change_state(State.launching)
    State.over:
      game_over()

func quit():
  get_tree().quit()

func reload():
  controls.erase_all()
  Skins.generate()
  get_tree().change_scene_to_packed(load("res://game.tscn"))

func lowpass_to(target : float, timer : Timer):
  var c = 10
  var t = 1.0 - (timer.time_left / timer.wait_time)
  var o = 1 - pow(2, -c * t )
  var i = pow(2, t * c - c)
  lowpass.cutoff_hz = lerpf((1.0 - target) * 20000, target * 20000, clamp(lerp(o, i, target), 0.03, 1))

func _ready():
  preload("res://art/cheese.png")
  preload("res://art/eraser.png")
  preload("res://art/fat.png")
  preload("res://art/fly.png")
  preload("res://art/missing.png")
  preload("res://art/reverse.png")
  preload("res://art/sharp.png")
  preload("res://art/slow.png")
  preload("res://art/speed.png")
  preload("res://art/swap.png")
  preload("res://art/thin.png")
  lowpass = AudioServer.get_bus_effect(1, 0)
  lowpass.cutoff_hz = 20000
  Skins.generate()
  controls.player_joined.connect(on_player_joined)
  item_timer.timeout.connect(spawn_item)
  launch_timer.wait_time = launch_wait
  spawn_timer.wait_time = spawn_wait
  change_state(State.lobby)

func _physics_process(delta:float):
  match state:
    State.game, State.end:
      if spawn_timer.is_stopped():
        for s in snakes:
          if not s.player.disabled:
            s.update(s.player.input(), delta)


func _process(_delta):
  # if Input.is_action_just_pressed("ui_cancel"):
  #   quit()

  match state:
    State.lobby:
      for p in players:
        var d := p.pressed()
        if d != 0:
          p.set_skin(Skins.get_skin(p.skin, d))
          pick_sound.play()

      if Input.is_action_just_pressed("ui_accept") and players.size() > 0:
        change_state(State.launching)
      elif Input.is_action_just_pressed("ui_cancel"):
        reload()

    State.launching:
      message.text = "round starts in %s" % ceil(launch_timer.time_left)
    State.game:
      lowpass_to(1.0, spawn_timer)

      # if not snakes[0].invincible_timer.is_stopped():
      #   lowpass_to(1.0, snakes[0].invincible_timer)

    State.end:
      lowpass_to(0.03, launch_timer)
      message.text = "%s wins!\nnext round starts in %s" % [round_winner.show_skin(), ceil(launch_timer.time_left)]
      field.line.material = Skins.get_material(round_winner.skin)
    State.over:
      if Input.is_action_just_pressed("ui_accept"):
        change_state(State.lobby)
      elif Input.is_action_just_pressed("ui_cancel"):
        reload()
