extends "res://scripts/enemy.gd"
## Malý dinosaurus: chodí sem a tam, na kraji plošiny se otočí.

const SPEED := 32.0


func _ready() -> void:
	_setup_body(Vector2(18, 13), Vector2(0, 1.5))


func _physics_process(delta: float) -> void:
	if dead:
		_dead_physics(delta)
		return
	anim_t += delta
	velocity.y = minf(velocity.y + 900.0 * delta, 400.0)
	velocity.x = facing * SPEED
	move_and_slide()
	if is_on_wall() or (is_on_floor() and not _ground_ahead()):
		facing = -facing
	_check_player()
	queue_redraw()


func _ground_ahead() -> bool:
	var space := get_world_2d().direct_space_state
	var from := global_position + Vector2(facing * 10.0, 0.0)
	var q := PhysicsRayQueryParameters2D.create(from, from + Vector2(0, 16), 1 | 16)
	return not space.intersect_ray(q).is_empty()


func _draw() -> void:
	var tex: Texture2D = Art.dino1 if int(anim_t * 6.0) % 2 == 0 else Art.dino2
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1))
	var size := tex.get_size()
	draw_texture(tex, Vector2(-floorf(size.x * 0.5), 8.0 - (size.y - 1)))
