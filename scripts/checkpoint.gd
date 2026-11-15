extends Area2D
## Kontrolní bod – pochodeň. Po zapálení se tady hráč po smrti oživí.

signal activated(cp: Node2D)

var active := false
var t := 0.0


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(14, 40)
	cs.shape = r
	cs.position = Vector2(0, -12)
	add_child(cs)
	body_entered.connect(_on_body_entered)


func _on_body_entered(b: Node2D) -> void:
	if not active and b.has_method("take_damage"):
		active = true
		activated.emit(self)
		Sfx.play("checkpoint")


func _process(delta: float) -> void:
	t += delta
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-2, -18, 4, 26), Color("6a3a1a"))
	draw_rect(Rect2(-1, -18, 1, 26), Color("a0662e"))
	draw_rect(Rect2(-4, -21, 8, 4), Color("2b1d14"))
	draw_rect(Rect2(-3, -20, 6, 2), Color("8a8a96"))
	if active:
		var f := sin(t * 18.0) * 0.8
		draw_circle(Vector2(0, -24 + f), 4.5, Color("d8402e"))
		draw_circle(Vector2(0.5, -25 + f), 3.3, Color("f08a30"))
		draw_circle(Vector2(0, -24.5), 1.8, Color("f0d050"))
	else:
		var y := fmod(t * 6.0, 10.0)
		draw_circle(Vector2(sin(t * 3.0), -23 - y), 1.5, Color(0.6, 0.6, 0.6, 1.0 - y / 10.0))
