extends Node
## Řídí celou hru: titulní obrazovka, hraní, pauza, výsledky.

const LevelScript := preload("res://scripts/level.gd")
const HudScript := preload("res://scripts/hud.gd")
const BackgroundScript := preload("res://scripts/background.gd")
const Levels := preload("res://scripts/levels.gd")

enum State { TITLE, PLAYING, PAUSED, RESULTS }

var state := State.TITLE
var level: LevelScript = null
var level_index := 0
var world: Node
var hud: HudScript
var ui_layer: CanvasLayer
var menu: Control = null
var title_bg: CanvasLayer = null
var ui_theme: Theme

# Automatický test (spouští se v CI s parametrem --smoke).
var smoke := false
var smoke_time := 0.0
var smoke_step := 0
# Screenshoty (CI s parametrem --shots=<složka>).
var shots_dir := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	smoke = OS.get_cmdline_user_args().has("--smoke")
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shots="):
			shots_dir = a.substr(8)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	ui_theme = Theme.new()
	ui_theme.default_font_size = 12

	world = Node.new()
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world)

	var hud_layer := CanvasLayer.new()
	hud_layer.layer = 5
	add_child(hud_layer)
	hud = HudScript.new()
	hud_layer.add_child(hud)

	ui_layer = CanvasLayer.new()
	ui_layer.layer = 10
	add_child(ui_layer)

	show_title()
	if shots_dir != "":
		_take_shots()


func _process(delta: float) -> void:
	if smoke:
		_smoke(delta)
	if Input.is_action_just_pressed("pause"):
		if state == State.PLAYING:
			pause()
		elif state == State.PAUSED:
			resume()
	elif state == State.PAUSED and Input.is_action_just_pressed("ui_cancel"):
		resume()


# ---------------------------------------------------------------- obrazovky

func show_title() -> void:
	state = State.TITLE
	get_tree().paused = false
	_clear_level()
	if title_bg == null:
		title_bg = CanvasLayer.new()
		title_bg.layer = -10
		title_bg.add_child(BackgroundScript.new())
		add_child(title_bg)
	_show_menu("UGO", "Pravěký hlad", [
		["Hrát", start_game],
		["Ukončit hru", quit_game],
	], "A – skok    X / B – kyj    Start – pauza\nDolů + skok – seskok z kmene", false)


func start_game() -> void:
	level_index = 0
	start_level(level_index)


func start_level(index: int) -> void:
	_close_menu()
	_clear_level()
	if title_bg != null:
		title_bg.queue_free()
		title_bg = null
	get_tree().paused = false
	level = LevelScript.new()
	level.setup(Levels.LEVELS[index])
	level.completed.connect(_on_level_completed)
	world.add_child(level)
	hud.level = level
	level.player.control_lock = 0.25
	state = State.PLAYING


func pause() -> void:
	state = State.PAUSED
	get_tree().paused = true
	Sfx.play("select")
	_show_menu("Pauza", "", [
		["Pokračovat", resume],
		["Začít úroveň znovu", restart_level],
		["Hlavní menu", show_title],
		["Ukončit hru", quit_game],
	])


func resume() -> void:
	_close_menu()
	get_tree().paused = false
	state = State.PLAYING


func _on_level_completed(stats: Dictionary) -> void:
	state = State.RESULTS
	get_tree().paused = true
	var secs := int(stats["time"])
	var text := "Jídlo: %d / %d\nSkóre: %d\nPoražení nepřátelé: %d\nČas: %d:%02d\nSmrti: %d" % [
		stats["food"], stats["food_total"], stats["score"], stats["kills"],
		secs / 60, secs % 60, stats["deaths"]]
	var items: Array = []
	if level_index + 1 < Levels.LEVELS.size():
		items.append(["Další úroveň", next_level])
	else:
		text += "\n\nTo je zatím všechno – další úrovně brzy!"
	items.append(["Hrát znovu", restart_level])
	items.append(["Hlavní menu", show_title])
	_show_menu("Úroveň dokončena!", text, items)


func next_level() -> void:
	level_index += 1
	start_level(level_index)


func restart_level() -> void:
	start_level(level_index)


func quit_game() -> void:
	get_tree().quit()


# ---------------------------------------------------------------- pomocné

func _clear_level() -> void:
	hud.level = null
	if level != null and is_instance_valid(level):
		level.queue_free()
	level = null


func _close_menu() -> void:
	if menu != null and is_instance_valid(menu):
		menu.queue_free()
	menu = null


func _show_menu(title: String, subtitle: String, items: Array, hint: String = "", dim: bool = true) -> void:
	_close_menu()
	menu = Control.new()
	menu.theme = ui_theme
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(menu)
	if dim:
		var shade := ColorRect.new()
		shade.color = Color(0, 0, 0, 0.55)
		shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		menu.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	center.add_child(box)

	var t := _label(title, 34 if not dim else 22)
	box.add_child(t)
	if subtitle != "":
		box.add_child(_label(subtitle, 12))
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 6)
	box.add_child(spacer)

	var first: Button = null
	for item in items:
		var b := Button.new()
		b.text = item[0]
		b.custom_minimum_size = Vector2(170, 0)
		b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var cb: Callable = item[1]
		b.pressed.connect(_on_menu_button.bind(cb))
		box.add_child(b)
		if first == null:
			first = b
	if hint != "":
		var h := _label(hint, 9)
		h.modulate = Color(1, 1, 1, 0.85)
		box.add_child(h)
	if first != null:
		first.call_deferred("grab_focus")


func _on_menu_button(cb: Callable) -> void:
	Sfx.play("select")
	cb.call()


func _label(text: String, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_outline_color", Color("2b1d14"))
	l.add_theme_constant_override("outline_size", 6 if size > 20 else 3)
	return l


# ---------------------------------------------------------------- smoke test

func _smoke(delta: float) -> void:
	smoke_time += delta
	match smoke_step:
		0:
			if smoke_time > 0.5:
				start_game()
				Input.action_press("right")
				smoke_step = 1
		1:
			# Běh doprava se skoky a útoky.
			var phase := fmod(smoke_time, 0.8)
			if phase < 0.3:
				Input.action_press("jump")
			else:
				Input.action_release("jump")
			if fmod(smoke_time, 0.5) < 0.05:
				Input.action_press("attack")
			else:
				Input.action_release("attack")
			if smoke_time > 3.0:
				var pk := get_tree().get_first_node_in_group("pickup")
				if pk != null:
					pk.call("collect")
				var en := get_tree().get_first_node_in_group("enemy")
				if en != null:
					en.call("hit", 1)
				smoke_step = 2
		2:
			if smoke_time > 4.0:
				level.player.invuln = 0.0
				level.player.hp = 1
				level.player.take_damage(level.player.global_position.x - 5.0)
				smoke_step = 3
		3:
			if smoke_time > 6.5:
				if level.player.dead:
					_smoke_fail("hráč se neoživil")
				pause()
				smoke_step = 4
		4:
			if smoke_time > 7.0:
				resume()
				level.finish()
				smoke_step = 5
		5:
			if smoke_time > 10.0:
				Input.action_release("right")
				if state != State.RESULTS:
					_smoke_fail("úroveň se nedokončila")
				print("SMOKE OK score=%d food=%d/%d deaths=%d x=%.0f" % [
					level.score, level.food, level.food_total, level.deaths, level.player.global_position.x])
				get_tree().quit(0)
				smoke_step = 6


func _smoke_fail(reason: String) -> void:
	print("SMOKE FAIL: " + reason)
	get_tree().quit(1)


# ---------------------------------------------------------------- screenshoty

func _take_shots() -> void:
	DirAccess.make_dir_recursive_absolute(shots_dir)
	await get_tree().create_timer(1.0).timeout
	_save_shot("1_menu")
	start_game()
	# Pozice hráče (sloupec dlaždice) pro jednotlivé snímky.
	var spots := [[8, "2_start"], [47, "3_propast"], [108, "4_pterodaktylove"], [198, "5_jeskyne"]]
	for spot in spots:
		level.player.global_position = Vector2(spot[0] * 16 + 8, 14 * 16 + 8)
		level.player.velocity = Vector2.ZERO
		level.camera.reset_smoothing()
		await get_tree().create_timer(1.2).timeout
		_save_shot(spot[1])
	pause()
	await get_tree().create_timer(0.5).timeout
	_save_shot("6_pauza")
	print("SHOTS OK")
	get_tree().quit(0)


func _save_shot(shot_name: String) -> void:
	var img := get_viewport().get_texture().get_image()
	img.resize(img.get_width() * 3, img.get_height() * 3, Image.INTERPOLATE_NEAREST)
	img.save_png(shots_dir.path_join(shot_name + ".png"))
