extends Node2D


func _draw():
	var x = 0
	for c in Settings.font.get_available_chars():
		var pos = Vector2(x, 0) * Settings.cell_size + Vector2(0, Settings.font.get_ascent())
		var _r = Settings.font.draw_char(get_canvas_item(), pos, ord(c), -1, Settings.text_color)
		x += 1
