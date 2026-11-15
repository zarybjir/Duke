extends "res://scripts/enemy.gd"
## Pterodaktyl: létá sem a tam ve vlnovce.

var range_x := 48.0
var origin := Vector2.ZERO
var t := 0.0


func _ready() -> void:
	_setup_body(Vector2(20, 8), Vector2.ZERO)
	collision_mask = 0
	origin = position
	t = randf() * TAU


func _physics_process(delta: float) -> void:
	if dead:
		_dead_physics(delta)
		return
	t += delta
	anim_t += delta
	var nx := origin.x + sin(t * 0.9) * range_x
	facing = 1 if nx >= position.x else -1
	position = Vector2(nx, origin.y + sin(t * 2.6) * 6.0)
	_check_player()
	queue_redraw()


func _draw() -> void:
	var tex: Texture2D = Art.ptero1 if int(anim_t * 5.0) % 2 == 0 else Art.ptero2
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	var size := tex.get_size()
	draw_texture(tex, Vector2(-floorf(size.x * 0.5), -floorf(size.y * 0.5)))
