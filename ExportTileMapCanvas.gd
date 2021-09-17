extends Node2D


func _draw():
	var x = 0
	for c in Global.font.get_available_chars():
		var pos = Vector2(x, 0) * Global.cell_size + Vector2(0, Global.font.get_ascent())
		var _r = Global.font.draw_char(get_canvas_item(), pos, ord(c), -1, Global.text_color)
		x += 1
