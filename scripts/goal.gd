extends Area2D
## Cíl úrovně – jeskyně. Stačí do ní vejít.

signal reached

var done := false


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(16, 20)
	cs.shape = r
	cs.position = Vector2(0, -2)
	add_child(cs)
	body_entered.connect(_on_body_entered)


func _on_body_entered(b: Node2D) -> void:
	if not done and b.has_method("take_damage"):
		done = true
		reached.emit()


func _draw() -> void:
	draw_colored_polygon(_half_disc(Vector2(0, 8), 30.0), Color("55555f"))
	draw_colored_polygon(_half_disc(Vector2(-2, 8), 26.0), Color("8a8a96"))
	draw_colored_polygon(_half_disc(Vector2(0, 8), 14.0), Color("1a120c"))
	draw_rect(Rect2(-22, -10, 3, 3), Color("b8b8c4"))
	draw_rect(Rect2(12, -16, 4, 2), Color("b8b8c4"))
	# Kostěná cedule nad vchodem.
	draw_rect(Rect2(-8, -26, 16, 3), Color("f2ead2"))
	draw_rect(Rect2(-10, -27, 3, 5), Color("f2ead2"))
	draw_rect(Rect2(7, -27, 3, 5), Color("f2ead2"))


func _half_disc(center: Vector2, radius: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 17:
		var a := PI + PI * float(i) / 16.0
		pts.append(center + Vector2(cos(a), sin(a)) * radius)
	return pts
