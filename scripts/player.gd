extends CharacterBody2D
## Ugo – hlavní postava.
## Moderní prvky ovládání: coyote time, jump buffer, proměnlivá výška skoku,
## rychlejší pád, krátká nezranitelnost po zásahu, seskok z kmenů (dolů + skok).

signal hp_changed(hp: int)
signal died

const RUN_SPEED := 120.0
const ACCEL := 1000.0
const AIR_ACCEL := 750.0
const FRICTION := 1300.0
const GRAVITY := 900.0
const FALL_GRAVITY_MULT := 1.5
const MAX_FALL := 430.0
const JUMP_VELOCITY := -360.0
const JUMP_CUT := 0.45
const COYOTE_TIME := 0.1
const JUMP_BUFFER := 0.12
const ATTACK_TIME := 0.22
const ATTACK_COOLDOWN := 0.32
const INVULN_TIME := 1.2
const MAX_HP := 3

var hp := MAX_HP
var facing := 1
var dead := false
var controls := true
var fall_limit := 10000.0

var coyote := 0.0
var jump_buffer := 0.0
var jumping := false
var attack_timer := 0.0
var attack_cd := 0.0
var invuln := 0.0
var control_lock := 0.0
var drop_timer := 0.0
var on_oneway := false
var anim_t := 0.0
var squash := Vector2.ONE
var hitbox: Area2D
var hit_list: Array = []


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1 | 16
	floor_snap_length = 4.0
	var cs := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = Vector2(10, 14)
	cs.shape = rs
	cs.position = Vector2(0, 1)
	add_child(cs)

	hitbox = Area2D.new()
	hitbox.collision_layer = 0
	hitbox.collision_mask = 4
	var hs := CollisionShape2D.new()
	var hr := RectangleShape2D.new()
	hr.size = Vector2(18, 20)
	hs.shape = hr
	hitbox.add_child(hs)
	add_child(hitbox)


func _physics_process(delta: float) -> void:
	anim_t += delta
	invuln = maxf(invuln - delta, 0.0)
	squash = squash.lerp(Vector2.ONE, minf(delta * 12.0, 1.0))

	if dead:
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
		position += velocity * delta
		queue_redraw()
		return

	var dir := 0.0
	if controls and control_lock <= 0.0:
		dir = Input.get_axis("left", "right")
	control_lock = maxf(control_lock - delta, 0.0)

	# Gravitace – při pádu silnější, skok je pak "šťavnatější".
	if is_on_floor():
		coyote = COYOTE_TIME
		jumping = false
	else:
		var g := GRAVITY
		if velocity.y > 0.0:
			g *= FALL_GRAVITY_MULT
		velocity.y = minf(velocity.y + g * delta, MAX_FALL)
		coyote -= delta

	# Skok s bufferem (stisk těsně před dopadem se počítá).
	jump_buffer -= delta
	if controls and control_lock <= 0.0 and Input.is_action_just_pressed("jump"):
		jump_buffer = JUMP_BUFFER
	if jump_buffer > 0.0 and coyote > 0.0:
		if Input.is_action_pressed("down") and on_oneway:
			set_collision_mask_value(5, false)
			drop_timer = 0.25
			position.y += 2.0
		else:
			velocity.y = JUMP_VELOCITY
			jumping = true
			squash = Vector2(0.75, 1.3)
			Sfx.play("jump")
		jump_buffer = 0.0
		coyote = 0.0
	if jumping and velocity.y < 0.0 and not Input.is_action_pressed("jump"):
		velocity.y *= JUMP_CUT
		jumping = false

	if drop_timer > 0.0:
		drop_timer -= delta
		if drop_timer <= 0.0:
			set_collision_mask_value(5, true)

	# Vodorovný pohyb se zrychlením a třením.
	var accel := ACCEL if is_on_floor() else AIR_ACCEL
	if dir == 0.0 and is_on_floor():
		accel = FRICTION
	velocity.x = move_toward(velocity.x, dir * RUN_SPEED, accel * delta)
	if dir > 0.0:
		facing = 1
	elif dir < 0.0:
		facing = -1

	# Útok kyjem.
	attack_cd -= delta
	if controls and control_lock <= 0.0 and Input.is_action_just_pressed("attack") and attack_cd <= 0.0:
		attack_timer = ATTACK_TIME
		attack_cd = ATTACK_COOLDOWN
		hit_list.clear()
		Sfx.play("swing")
	hitbox.position = Vector2(facing * 13.0, -1.0)
	if attack_timer > 0.0:
		attack_timer -= delta
		for b in hitbox.get_overlapping_bodies():
			if b.has_method("hit") and not hit_list.has(b):
				hit_list.append(b)
				b.call("hit", facing)

	var was_on_floor := is_on_floor()
	move_and_slide()
	if not was_on_floor and is_on_floor():
		squash = Vector2(1.3, 0.75)
		Sfx.play("land")

	on_oneway = false
	if is_on_floor():
		for i in get_slide_collision_count():
			var o := get_slide_collision(i).get_collider()
			if o is Node and (o as Node).is_in_group("oneway"):
				on_oneway = true

	if global_position.y > fall_limit:
		hp = 0
		hp_changed.emit(hp)
		_die()

	queue_redraw()


func take_damage(src_x: float, from_spikes: bool = false) -> void:
	if dead or invuln > 0.0:
		return
	hp -= 1
	hp_changed.emit(hp)
	if hp <= 0:
		_die()
		return
	invuln = INVULN_TIME
	var away := 1.0 if global_position.x >= src_x else -1.0
	velocity = Vector2(away * 140.0, -300.0 if from_spikes else -200.0)
	jumping = false
	control_lock = 0.25
	Sfx.play("hurt")


func bounce() -> void:
	velocity.y = JUMP_VELOCITY * (1.0 if Input.is_action_pressed("jump") else 0.7)
	jumping = Input.is_action_pressed("jump")
	coyote = 0.0
	squash = Vector2(0.8, 1.25)


func _die() -> void:
	if dead:
		return
	dead = true
	collision_mask = 0
	velocity = Vector2(0, -280)
	Sfx.play("die")
	died.emit()


func respawn(pos: Vector2) -> void:
	dead = false
	hp = MAX_HP
	hp_changed.emit(hp)
	global_position = pos
	velocity = Vector2.ZERO
	collision_mask = 1 | 16
	invuln = 1.0
	control_lock = 0.2
	attack_timer = 0.0
	jumping = false
	queue_redraw()


func _draw() -> void:
	if not dead and invuln > 0.0 and int(invuln * 20.0) % 2 == 0:
		return
	var tex: Texture2D = Art.player_idle
	if dead or not is_on_floor():
		tex = Art.player_jump
	elif absf(velocity.x) > 10.0:
		tex = Art.player_run1 if int(anim_t * 10.0) % 2 == 0 else Art.player_run2
	var flip_y := -1.0 if dead else 1.0
	var base := Transform2D(0.0, Vector2(facing * squash.x, squash.y * flip_y), 0.0, Vector2(0, 8))
	draw_set_transform_matrix(base)
	draw_texture(tex, Vector2(-8, -16))
	var ang := -0.35
	if attack_timer > 0.0:
		var p := 1.0 - attack_timer / ATTACK_TIME
		ang = lerpf(-2.0, 2.1, ease(p, 0.4))
	draw_set_transform_matrix(base * Transform2D(ang, Vector2(4, -6)))
	draw_texture(Art.club, Vector2(-3, -10))
	draw_set_transform_matrix(Transform2D.IDENTITY)
