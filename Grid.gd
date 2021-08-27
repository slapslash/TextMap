extends Node2D

onready var n_screens_around = 10

func _ready():
	print(OS.get_screen_size())
	print(ProjectSettings.get_setting("display/window/size/width"))
	
	ProjectSettings.set_setting("display/window/size/width", Global.cell_size.x * 20)
	print(ProjectSettings.get_setting("display/window/size/width"))

func _draw():
	var s = Global.screen_size_pixels
	var start: Vector2
	var end: Vector2
	for x in range(-n_screens_around * s.x, (n_screens_around + 2) * s.x, s.x):
		start = Vector2(x, -n_screens_around * s.y)
		end = Vector2(x, (n_screens_around + 1) * s.y)
		draw_line(start, end, Color.dimgray, 1.0, true)
	
	for y in range(-n_screens_around * s.y, (n_screens_around + 2) * s.y, s.y):
		start = Vector2(-n_screens_around * s.x, y)
		end = Vector2((n_screens_around + 1) * s.x, y)
		draw_line(start, end, Color.dimgray, 1.0, true)
	
	
