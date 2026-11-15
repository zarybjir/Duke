extends Node2D
## Pravěké pozadí s paralaxou: obloha, slunce, sopka, kopce, džungle.

var t := 0.0


func _process(delta: float) -> void:
	t += delta
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	var cx := t * 25.0
	var cam := get_viewport().get_camera_2d()
	if cam != null:
		cx = cam.get_screen_center_position().x

	draw_texture(Art.sky, Vector2.ZERO)
	draw_circle(Vector2(370, 70), 30.0, Color(1, 0.95, 0.7, 0.18))
	draw_circle(Vector2(370, 70), 25.0, Color(1, 0.95, 0.7, 0.3))
	draw_circle(Vector2(370, 70), 20.0, Color("fff2b0"))
	draw_circle(Vector2(366, 66), 14.0, Color("fffbe0"))

	# Mraky
	for i in 5:
		var x := fposmod(i * 140.0 - cx * 0.05 - t * 4.0, 700.0) - 110.0
		var y := 30.0 + float((i * 37) % 60)
		var sh := Color("c8d4e8")
		draw_circle(Vector2(x, y + 2), 10.0, sh)
		draw_circle(Vector2(x + 26, y + 2), 9.0, sh)
		draw_rect(Rect2(x, y + 2, 26, 9), sh)
		var c := Color("f6f9fd")
		draw_circle(Vector2(x, y), 10.0, c)
		draw_circle(Vector2(x + 12, y - 4), 13.0, c)
		draw_circle(Vector2(x + 26, y), 9.0, c)
		draw_rect(Rect2(x, y, 26, 7), c)

	# Vzdálené hory se sopkou
	_layer(cx * 0.1, 600.0, size, Color("a993b8"), Color("bfaacb"), func(px: float) -> float: return 150.0 - 45.0 * absf(sin(px / 600.0 * PI * 3.0)))
	var vx := 260.0 - fposmod(cx * 0.1, 600.0)
	for k in 3:
		var ox := vx + k * 600.0 - 600.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(ox - 90, 200), Vector2(ox - 18, 92), Vector2(ox + 18, 92), Vector2(ox + 90, 200)]),
			Color("8f7aa0"))
		draw_colored_polygon(PackedVector2Array([
			Vector2(ox - 90, 200), Vector2(ox - 18, 92), Vector2(ox - 6, 92), Vector2(ox - 40, 200)]),
			Color("a08ab2"))
		draw_rect(Rect2(ox - 18, 90, 36, 4), Color("d8402e"))
		draw_rect(Rect2(ox - 12, 89, 22, 2), Color("f08a30"))
		# Lávové stružky
		draw_line(Vector2(ox - 4, 93), Vector2(ox - 10, 120), Color("d8402e"), 2.0)
		draw_line(Vector2(ox + 8, 93), Vector2(ox + 16, 112), Color("c03828"), 2.0)
		for j in 4:
			var s := fmod(t * 0.4 + j * 0.25, 1.0)
			draw_circle(Vector2(ox + sin(s * 6.0 + j) * 6.0 + s * 20.0, 86.0 - s * 70.0),
				6.0 + s * 12.0, Color(0.55, 0.5, 0.55, 0.6 * (1.0 - s)))

	# Kopce
	_layer(cx * 0.3, 480.0, size, Color("7fa865"), Color("9cc47a"), func(px: float) -> float: return 210.0 - 22.0 * sin(px / 480.0 * TAU * 2.0) - 10.0 * sin(px / 480.0 * TAU * 5.0))
	# Palmy za džunglí
	var pstart := -fposmod(cx * 0.5, 480.0)
	for k in 3:
		for j in 4:
			var px := pstart + k * 480.0 + j * 120.0 + float((j * 53) % 40)
			if px > -60.0 and px < size.x + 60.0:
				_palm(Vector2(px, 250.0), 50.0 + float((j * 17) % 25), Color("3c6a36"))
	# Džungle
	_layer(cx * 0.55, 480.0, size, Color("4a7a3e"), Color("5e9450"), func(px: float) -> float: return 245.0 - 12.0 * absf(sin(px / 480.0 * PI * 22.0)) - 8.0 * sin(px / 480.0 * TAU * 3.0))


## Nakreslí jednu vrstvu krajiny, která se opakuje s periodou `period`.
func _layer(offset: float, period: float, size: Vector2, color: Color, rim: Color, height: Callable) -> void:
	var start := -fposmod(offset, period)
	var pts := PackedVector2Array()
	pts.append(Vector2(0, size.y))
	var x := 0.0
	while x <= size.x + 8.0:
		var px := fposmod(x - start, period)
		var h: float = height.call(px)
		pts.append(Vector2(x, h))
		x += 8.0
	var top := pts.slice(1)
	pts.append(Vector2(size.x + 8.0, size.y))
	draw_colored_polygon(pts, color)
	draw_polyline(top, rim, 2.0)


func _palm(base: Vector2, h: float, color: Color) -> void:
	var top := base + Vector2(10.0, -h)
	var prev := base
	for i in range(1, 9):
		var t := float(i) / 8.0
		var p := base.lerp(top, t) + Vector2(sin(t * PI) * -6.0, 0.0)
		draw_line(prev, p, color, 4.0 - t * 1.5)
		prev = p
	for a in [-2.6, -2.0, -1.2, -0.6, 0.0, -3.1]:
		var pts := PackedVector2Array()
		for i in 7:
			var t := float(i) / 6.0
			var dir := Vector2(cos(a), sin(a))
			pts.append(prev + dir * t * 26.0 + Vector2(0, t * t * 14.0))
		draw_polyline(pts, color, 3.0)
