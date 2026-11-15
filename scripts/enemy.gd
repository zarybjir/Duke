extends CharacterBody2D
## Společný základ všech nepřátel: zásah kyjem, skok na hlavu, zranění hráče.

signal killed(enemy: Node2D)

var dead := false
var facing := -1
var anim_t := 0.0
var hurtbox: Area2D
var hp := 1
var flash := 0.0


func _setup_body(size: Vector2, offset: Vector2) -> void:
	add_to_group("enemy")
	collision_layer = 4
	collision_mask = 1 | 16
	var cs := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = size
	cs.shape = rs
	cs.position = offset
	add_child(cs)
	hurtbox = Area2D.new()
	hurtbox.collision_layer = 0
	hurtbox.collision_mask = 2
	var hs := CollisionShape2D.new()
	var hr := RectangleShape2D.new()
	hr.size = size + Vector2(2, 2)
	hs.shape = hr
	hs.position = offset
	hurtbox.add_child(hs)
	add_child(hurtbox)


func _check_player() -> void:
	if dead:
		return
	for b in hurtbox.get_overlapping_bodies():
		if b.has_method("take_damage"):
			_touch(b)


func _touch(p: Variant) -> void:
	if p.dead:
		return
	if p.velocity.y > 10.0 and p.global_position.y < global_position.y - 5.0:
		p.bounce()
		damage(0)
	else:
		p.take_damage(global_position.x)


## Volá hráč při zásahu kyjem.
func hit(from_dir: int) -> void:
	if not dead:
		damage(from_dir)


## Ubere život; větší nepřátelé vydrží víc ran.
func damage(from_dir: int) -> void:
	hp -= 1
	if hp <= 0:
		die(from_dir)
	else:
		flash = 0.25
		velocity.x = from_dir * 90.0
		Sfx.play("hurt", 0.6)


func die(from_dir: int) -> void:
	dead = true
	killed.emit(self)
	Sfx.play("stomp")
	collision_layer = 0
	collision_mask = 0
	hurtbox.set_deferred("monitoring", false)
	velocity = Vector2(from_dir * 100.0, -180.0)


func _dead_physics(delta: float) -> void:
	velocity.y += 900.0 * delta
	position += velocity * delta
	rotation += 8.0 * delta * (1.0 if velocity.x >= 0.0 else -1.0)
	if position.y > 1200.0:
		queue_free()
