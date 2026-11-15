extends Control
## Horní lišta: srdíčka, jídlo, skóre, čas.

var level: Node2D = null
var food_label: Label
var score_label: Label
var time_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	food_label = _label(Vector2(44, 3))
	time_label = _label(Vector2(200, 3))
	score_label = _label(Vector2(380, 3))


func _label(pos: Vector2) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", 10)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 4)
	add_child(l)
	return l


func _process(_delta: float) -> void:
	visible = level != null and is_instance_valid(level)
	if not visible:
		return
	var lv = level
	food_label.text = "Jídlo %d/%d" % [lv.food, lv.food_total]
	var secs := int(lv.time)
	time_label.text = "%d:%02d" % [secs / 60, secs % 60]
	score_label.text = "Skóre %d" % lv.score
	queue_redraw()


func _draw() -> void:
	if level == null or not is_instance_valid(level):
		return
	var lv = level
	if lv.player == null:
		return
	var hp: int = lv.player.hp
	for i in 3:
		var tex: Texture2D = Art.heart if i < hp else Art.heart_empty
		draw_texture(tex, Vector2(6 + i * 11, 7))
