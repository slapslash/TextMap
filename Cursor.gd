extends Polygon2D


signal cursor_pos_changed

func _ready():
	_init_cursor()
	update_position()


func _init_cursor():
	polygon = Global.get_cell_polygon().polygon
	# set cursor behind the text
	z_index = -1
	color = Global.cursor_color


func update_position():
	global_position = Global.cell_size * Global.cell
	emit_signal("cursor_pos_changed")

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var mpos = Global.get_cell_from_mouse_pos()
			Global.cell = mpos
			update_position()
