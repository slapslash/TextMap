extends Node2D


func _ready():
	assert(Global.connect("draw_matrix", self, "update") == OK)


func _draw():
	"""
	In fact, only a changed cell needs to be drawn, but for now the
	whole matrix is updated.
	"""
	for y in Global.matrix:
		for x in Global.matrix[y]:
			var to_draw = ord(Global.matrix[y][x])
			var pos = Vector2(x, y) * Global.cell_size + Vector2(0, Global.font.get_ascent())
			var _r = Global.font.draw_char(get_canvas_item(), pos, to_draw, -1, Global.text_color)
