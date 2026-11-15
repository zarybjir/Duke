extends Node2D
## Postaví úroveň z textových dat (levels.gd): dlaždice, kolize, předměty, nepřátele.

signal completed(stats: Dictionary)

const TILE := 16
const PlayerScript := preload("res://scripts/player.gd")
const DinoScript := preload("res://scripts/dino.gd")
const PteroScript := preload("res://scripts/ptero.gd")
const PickupScript := preload("res://scripts/pickup.gd")
const CheckpointScript := preload("res://scripts/checkpoint.gd")
const GoalScript := preload("res://scripts/goal.gd")
const SpikesScript := preload("res://scripts/spikes.gd")
const BackgroundScript := preload("res://scripts/background.gd")

const SCORE := {"a": 10, "m": 50, "o": 200}

var level_name := ""
var rows: PackedStringArray = PackedStringArray()
var width := 0
var height := 0

var player: PlayerScript
var camera: Camera2D
var spawn_point := Vector2(32, 32)
var score := 0
var food := 0
var food_total := 0
var kills := 0
var deaths := 0
var time := 0.0
var finished := false
var decorations: Array = []


## Volá se před přidáním do stromu scény.
func setup(data: Dictionary) -> void:
	level_name = data["name"]
	for r in data["rows"]:
		rows.append(r)
	height = rows.size()
	for r in rows:
		width = maxi(width, r.length())


func _ready() -> void:
	var bg_layer := CanvasLayer.new()
	bg_layer.layer = -10
	add_child(bg_layer)
	bg_layer.add_child(BackgroundScript.new())
	_build()
	_spawn_player()


func _process(delta: float) -> void:
	if not finished:
		time += delta
	if camera != null and player != null:
		# Kamera se mírně dívá dopředu ve směru pohybu.
		camera.offset.x = lerpf(camera.offset.x, player.facing * 28.0, minf(delta * 2.5, 1.0))


func cell(x: int, y: int) -> String:
	if y < 0 or y >= height or x < 0:
		return " "
	var r: String = rows[y]
	if x >= r.length():
		return " "
	return r[x]


func _is_solid(c: String) -> bool:
	return c == "#" or c == "="


func _build() -> void:
	var solid := StaticBody2D.new()
	solid.collision_layer = 1
	solid.collision_mask = 0
	add_child(solid)
	# Neviditelné stěny na krajích úrovně.
	_add_rect(solid, Rect2(-TILE, -TILE * 10, TILE, (height + 20) * TILE))
	_add_rect(solid, Rect2(width * TILE, -TILE * 10, TILE, (height + 20) * TILE))

	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for y in height:
		var x := 0
		while x < width:
			var c := cell(x, y)
			if _is_solid(c):
				var start := x
				while x < width and _is_solid(cell(x, y)):
					if c == "#" and not _is_solid(cell(x, y - 1)) and cell(x, y - 1) != "-":
						_maybe_decorate(rng, x, y)
					x += 1
				_add_rect(solid, Rect2(start * TILE, y * TILE, (x - start) * TILE, TILE))
			elif c == "-":
				var start2 := x
				while x < width and cell(x, y) == "-":
					x += 1
				var plat := StaticBody2D.new()
				plat.collision_layer = 16
				plat.collision_mask = 0
				plat.add_to_group("oneway")
				add_child(plat)
				var cs := _add_rect(plat, Rect2(start2 * TILE, y * TILE, (x - start2) * TILE, 6))
				cs.one_way_collision = true
			else:
				_spawn(c, x, y)
				x += 1
	queue_redraw()


func _add_rect(body: Node, r: Rect2) -> CollisionShape2D:
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = r.size
	cs.shape = shape
	cs.position = r.get_center()
	body.add_child(cs)
	return cs


func _maybe_decorate(rng: RandomNumberGenerator, x: int, y: int) -> void:
	var roll := rng.randf()
	var tex: Texture2D = null
	if roll < 0.25:
		tex = Art.tuft
	elif roll < 0.33:
		tex = Art.flower
	elif roll < 0.37:
		tex = Art.bone
	if tex != null:
		var s := tex.get_size()
		decorations.append([tex, Vector2(x * TILE + rng.randi_range(0, int(TILE - s.x)), y * TILE - s.y + 1)])


func _spawn(c: String, x: int, y: int) -> void:
	var pos := Vector2(x * TILE + TILE * 0.5, y * TILE + TILE * 0.5)
	match c:
		"P":
			spawn_point = pos
		"C":
			var cp := CheckpointScript.new()
			cp.position = pos
			cp.activated.connect(_on_checkpoint)
			add_child(cp)
		"E":
			var goal := GoalScript.new()
			goal.position = pos
			goal.reached.connect(_on_goal)
			add_child(goal)
		"^":
			var sp := SpikesScript.new()
			sp.position = pos
			add_child(sp)
		"a", "m", "o":
			var pk := PickupScript.new()
			pk.kind = c
			pk.position = pos
			pk.collected.connect(_on_collected)
			food_total += 1
			add_child(pk)
		"d":
			var dino := DinoScript.new()
			dino.position = pos
			dino.killed.connect(_on_killed)
			add_child(dino)
		"f":
			var ptero := PteroScript.new()
			ptero.position = pos
			ptero.killed.connect(_on_killed)
			add_child(ptero)


func _spawn_player() -> void:
	player = PlayerScript.new()
	player.position = spawn_point
	player.fall_limit = height * TILE + 48.0
	player.died.connect(_on_player_died)
	add_child(player)
	camera = Camera2D.new()
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = width * TILE
	camera.limit_bottom = height * TILE
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	player.add_child(camera)
	camera.make_current()


func _draw() -> void:
	for y in height:
		for x in width:
			var c := cell(x, y)
			var p := Vector2(x * TILE, y * TILE)
			if c == "#":
				var above := cell(x, y - 1)
				draw_texture(Art.tile_dirt if _is_solid(above) else Art.tile_grass, p)
			elif c == "=":
				draw_texture(Art.tile_stone, p)
			elif c == "-":
				draw_texture(Art.tile_log, p)
	for d in decorations:
		draw_texture(d[0], d[1])


func popup(text: String, pos: Vector2, color: Color = Color.WHITE) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 8)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 3)
	l.position = pos + Vector2(-10, -16)
	l.z_index = 10
	add_child(l)
	var tw := l.create_tween()
	tw.tween_property(l, "position:y", l.position.y - 18.0, 0.7)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.7)
	tw.tween_callback(l.queue_free)


func _on_collected(kind: String, pos: Vector2) -> void:
	var pts: int = SCORE.get(kind, 10)
	score += pts
	food += 1
	popup("+%d" % pts, pos, Color("f0d050"))


func _on_killed(enemy: Node2D) -> void:
	score += 100
	kills += 1
	popup("+100", enemy.global_position, Color("ffb070"))


func _on_checkpoint(cp: Node2D) -> void:
	spawn_point = cp.global_position
	popup("Kontrolní bod!", cp.global_position + Vector2(-14, -16), Color("9ad85a"))


func _on_player_died() -> void:
	deaths += 1
	await get_tree().create_timer(1.3, false).timeout
	if finished or not is_instance_valid(player):
		return
	player.respawn(spawn_point)
	camera.reset_smoothing()


func _on_goal() -> void:
	finish()


func finish() -> void:
	if finished:
		return
	finished = true
	player.controls = false
	Sfx.play("win")
	await get_tree().create_timer(1.2, false).timeout
	completed.emit({
		"name": level_name,
		"score": score,
		"food": food,
		"food_total": food_total,
		"kills": kills,
		"deaths": deaths,
		"time": time,
	})
