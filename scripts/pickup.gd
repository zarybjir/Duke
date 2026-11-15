extends Area2D
## Jídlo ke sbírání: a = bobule, m = maso, o = vejce (bonus).

signal collected(kind: String, pos: Vector2)

var kind := "a"
var t := 0.0
var taken := false
var tex: Texture2D


func _ready() -> void:
	add_to_group("pickup")
	collision_layer = 8
	collision_mask = 2
	var cs := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 7.0
	cs.shape = c
	add_child(cs)
	match kind:
		"m":
			tex = Art.meat
		"o":
			tex = Art.egg
		_:
			tex = Art.berry
	t = randf() * TAU
	body_entered.connect(_on_body_entered)


func _on_body_entered(b: Node2D) -> void:
	if b.has_method("take_damage"):
		collect()


func collect() -> void:
	if taken:
		return
	taken = true
	collected.emit(kind, global_position)
	Sfx.play("bonus" if kind == "o" else "pickup")
	queue_free()


func _process(delta: float) -> void:
	t += delta
	queue_redraw()


func _draw() -> void:
	var size := tex.get_size()
	draw_texture(tex, Vector2(-size.x * 0.5, -size.y * 0.5 + sin(t * 3.0) * 1.5).round())
