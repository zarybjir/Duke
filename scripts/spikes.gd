extends Area2D
## Kamenné bodce – zraní a vyhodí hráče do vzduchu.


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(14, 7)
	cs.shape = r
	cs.position = Vector2(0, 4)
	add_child(cs)


func _physics_process(_delta: float) -> void:
	for b in get_overlapping_bodies():
		if b.has_method("take_damage"):
			b.call("take_damage", global_position.x, true)


func _draw() -> void:
	draw_texture(Art.spikes, Vector2(-8, -8))
