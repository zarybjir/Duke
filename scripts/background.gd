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

	var top := Color("5fa8d8")
	var bottom := Color("f8d9a0")
	draw_polygon(
		PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0), size, Vector2(0, size.y)]),
		PackedColorArray([top, top, bottom, bottom]))
	draw_circle(Vector2(370, 70), 26.0, Color(1, 0.95, 0.7, 0.35))
	draw_circle(Vector2(370, 70), 20.0, Color("fff2b0"))

	# Mraky
	for i in 5:
		var x := fposmod(i * 140.0 - cx * 0.05 - t * 4.0, 700.0) - 110.0
		var y := 30.0 + float((i * 37) % 60)
		var c := Color("f2f6fb")
		draw_circle(Vector2(x, y), 10.0, c)
		draw_circle(Vector2(x + 12, y - 4), 13.0, c)
		draw_circle(Vector2(x + 26, y), 9.0, c)
		draw_rect(Rect2(x, y, 26, 9), c)

	# Vzdálené hory se sopkou
	_layer(cx * 0.1, 600.0, size, Color("a993b8"), func(px: float) -> float: return 150.0 - 45.0 * absf(sin(px / 600.0 * PI * 3.0)))
	var vx := 260.0 - fposmod(cx * 0.1, 600.0)
	for k in 3:
		var ox := vx + k * 600.0 - 600.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(ox - 90, 200), Vector2(ox - 18, 92), Vector2(ox + 18, 92), Vector2(ox + 90, 200)]),
			Color("8f7aa0"))
		draw_rect(Rect2(ox - 18, 90, 36, 4), Color("d8402e"))
		for j in 4:
			var s := fmod(t * 0.4 + j * 0.25, 1.0)
			draw_circle(Vector2(ox + sin(s * 6.0 + j) * 6.0 + s * 20.0, 86.0 - s * 70.0),
				6.0 + s * 12.0, Color(0.55, 0.5, 0.55, 0.6 * (1.0 - s)))

	# Kopce
	_layer(cx * 0.3, 480.0, size, Color("7fa865"), func(px: float) -> float: return 210.0 - 22.0 * sin(px / 480.0 * TAU * 2.0) - 10.0 * sin(px / 480.0 * TAU * 5.0))
	# Džungle
	_layer(cx * 0.55, 480.0, size, Color("4a7a3e"), func(px: float) -> float: return 245.0 - 12.0 * absf(sin(px / 480.0 * PI * 22.0)) - 8.0 * sin(px / 480.0 * TAU * 3.0))


## Nakreslí jednu vrstvu krajiny, která se opakuje s periodou `period`.
func _layer(offset: float, period: float, size: Vector2, color: Color, height: Callable) -> void:
	var start := -fposmod(offset, period)
	var pts := PackedVector2Array()
	pts.append(Vector2(0, size.y))
	var x := 0.0
	while x <= size.x + 8.0:
		var px := fposmod(x - start, period)
		var h: float = height.call(px)
		pts.append(Vector2(x, h))
		x += 8.0
	pts.append(Vector2(size.x + 8.0, size.y))
	draw_colored_polygon(pts, color)
