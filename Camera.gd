extends Camera2D

var _scroll: bool = false
var _scroll_start: Vector2
var _last_cell: Vector2

signal zoom_changed(current_zoom_level)

"""
Node to enable zooming, scrolling (moving with right mouse button)
and the camera following the cursor, when reaching the screen extends.

If camera is not attached to the cursor, zooming and scrolling also works.

TODO: following the cursor doesn't work correctly by now. function reset_offset
is corresponding to this mechanic.
"""

func _ready():
	# TODO: drag margins need to be adjusted to the size of the cursor.
	# But only, if dragging is used sometime in the future.
	_initial_positioning()
	emit_signal("zoom_changed", zoom.x)


func _initial_positioning():
	"""
	position the camera, so that the first screen is centered.
	"""
	offset = (Global.screen_size_pixels - get_viewport_rect().size) * 0.5


func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_WHEEL_DOWN and zoom.x < 10:
				zoom *= 1.1
				emit_signal("zoom_changed", zoom.x)
			elif event.button_index == BUTTON_WHEEL_UP and zoom.x > 0.1:
				zoom *= 0.9
				emit_signal("zoom_changed", zoom.x)
			elif event.button_index == BUTTON_MIDDLE:
				if not _scroll:
					_scroll_start = get_global_mouse_position()
					_scroll = true

		elif _scroll:
			_scroll = false


func _process(_delta):
	if _scroll:
		var scroll_vector = _scroll_start - get_global_mouse_position()
		offset += scroll_vector

	if Global.cell != _last_cell:
		_check_scroll_cursor_edge_screen()
		_last_cell = Global.cell


func _check_scroll_cursor_edge_screen():
	"""
	check if cursor moved to edge of screen and move the workspace if so.
	"""
	var cursor_center_pos = Global.cell * Global.cell_size + Global.cell_size * 0.5
	var screen_start = offset
	var screen_end = offset + get_viewport_rect().size * zoom

	if cursor_center_pos.x < screen_start.x + Global.cell_size.x:
		offset.x += cursor_center_pos.x - screen_start.x - Global.cell_size.x

	if cursor_center_pos.x > screen_end.x - Global.cell_size.x:
		offset.x += cursor_center_pos.x - screen_end.x + Global.cell_size.x

	if cursor_center_pos.y < screen_start.y + Global.cell_size.y:
		offset.y += cursor_center_pos.y - screen_start.y - Global.cell_size.y

	if cursor_center_pos.y > screen_end.y - Global.cell_size.y:
		offset.y += cursor_center_pos.y - screen_end.y + Global.cell_size.y


func _unhandled_key_input(event):
	if event.pressed:
		var scm = event.get_scancode_with_modifiers()
		match scm:
			285212689, 150994961: # Control+Right, Command+Right
				offset += Vector2(1, 0) * Global.cell_size * zoom

			285212687, 150994959: # Control+Left, Command+Left
				offset += Vector2(-1, 0) * Global.cell_size * zoom

			285212688, 150994960: # Control+Up, Command+Up
				offset += Vector2(0, -1) * Global.cell_size * zoom

			285212690, 150994962: # Control+Down, Command+Down
				offset += Vector2(0, 1) * Global.cell_size * zoom

			# Control+Add, Control+Keypad Add, Command+Plus
			268435517, 285212805, 134217771:
				if zoom.x > 0.1:
					zoom *= 0.9
					emit_signal("zoom_changed", zoom.x)
				get_tree().set_input_as_handled()

			 # Control+Subtract, Control+Keypad Subtract, Command+Minus
			268435501, 285212803, 134217773:
				if zoom.x < 10:
					zoom *= 1.1
					emit_signal("zoom_changed", zoom.x)
			
