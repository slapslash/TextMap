extends Node2D

onready var n_screens_around = 30


func _draw():
	if Global.show_grid:
		var s = Global.screen_size_pixels
		var start: Vector2
		var end: Vector2
		for i in range(-n_screens_around, (n_screens_around + 2)):
			start = Vector2(i * s.x, -n_screens_around * s.y)
			end = Vector2(i * s.x, (n_screens_around + 1) * s.y)
			draw_line(start, end, Global.grid_color, 1.0, true)
			
			start = Vector2(-n_screens_around * s.x, i * s.y)
			end = Vector2((n_screens_around + 1) * s.x, i * s.y)
			draw_line(start, end, Global.grid_color, 1.0, true)

