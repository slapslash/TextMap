extends Camera2D

var _scroll: bool = false
var _scroll_start: Vector2
var _last_cell: Vector2

signal zoom_changed()

"""
Node to enable zooming, scrolling (moving with right mouse button)
and the camera following the cursor, when reaching the screen extends.

If camera is not attached to the cursor, zooming and scrolling also works.

TODO: following the cursor doesn't work correctly by now. function reset_offset
is corresponding to this mechanic.
"""

func _ready():
	if Settings.camera_offset == Vector2.ZERO:
		_initial_positioning()
	else:
		offset = Settings.camera_offset
	zoom = Settings.camera_zoom
	emit_signal("zoom_changed")


func _initial_positioning():
	"""
	position the camera, so that the first screen is centered.
	"""
	offset = (Settings.screen_size_pixels - get_viewport_rect().size) * 0.5


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_WHEEL_DOWN:
				_zoom_out()
			elif event.button_index == BUTTON_WHEEL_UP:
				_zoom_in()
			elif event.button_index == BUTTON_MIDDLE:
				if not _scroll:
					_scroll_start = get_global_mouse_position()
					_scroll = true

		elif _scroll:
			_scroll = false


func _zoom_in():
	var maxc = max(Settings.cell_size.x, Settings.cell_size.y)
	# maximum allowed size of cursor, which scales with zoom is 256x256
	if maxc / (zoom.x * 0.9) < 256:
		zoom *= 0.9
		emit_signal("zoom_changed")
		Settings.camera_zoom = zoom


func _zoom_out():
	var minc = min(Settings.cell_size.x, Settings.cell_size.y)
	# minimum allowed size of cursor, which scales with zoom is >0 (rounded)
	if minc / (zoom.x * 1.1) > 1:
		zoom *= 1.1
		emit_signal("zoom_changed")
		Settings.camera_zoom = zoom


func _process(_delta):
	if _scroll:
		var scroll_vector = _scroll_start - get_global_mouse_position()
		offset += scroll_vector
		Settings.camera_offset = offset

	if Settings.cell != _last_cell:
		_check_scroll_cursor_edge_screen()
		_last_cell = Settings.cell


func _check_scroll_cursor_edge_screen():
	"""
	check if cursor moved to edge of screen and move the workspace if so.
	"""
	var cursor_center_pos = Settings.cell * Settings.cell_size + Settings.cell_size * 0.5
	var screen_start = offset
	var screen_end = offset + get_viewport_rect().size * zoom

	if cursor_center_pos.x < screen_start.x + Settings.cell_size.x:
		offset.x += cursor_center_pos.x - screen_start.x - Settings.cell_size.x

	if cursor_center_pos.x > screen_end.x - Settings.cell_size.x:
		offset.x += cursor_center_pos.x - screen_end.x + Settings.cell_size.x

	if cursor_center_pos.y < screen_start.y + Settings.cell_size.y:
		offset.y += cursor_center_pos.y - screen_start.y - Settings.cell_size.y

	if cursor_center_pos.y > screen_end.y - Settings.cell_size.y:
		offset.y += cursor_center_pos.y - screen_end.y + Settings.cell_size.y
	Settings.camera_offset = offset


func _unhandled_key_input(event):
	if event.pressed:
		var scm = event.get_scancode_with_modifiers()
		match scm:
			285212689, 150994961: # Control+Right, Command+Right
				offset += Vector2(1, 0) * Settings.cell_size * zoom

			285212687, 150994959: # Control+Left, Command+Left
				offset += Vector2(-1, 0) * Settings.cell_size * zoom

			285212688, 150994960: # Control+Up, Command+Up
				offset += Vector2(0, -1) * Settings.cell_size * zoom

			285212690, 150994962: # Control+Down, Command+Down
				offset += Vector2(0, 1) * Settings.cell_size * zoom

			# Control+Add, Control+Keypad Add, Command+Plus
			268435517, 285212805, 134217771:
				_zoom_in()

			 # Control+Subtract, Control+Keypad Subtract, Command+Minus
			268435501, 285212803, 134217773:
				_zoom_out()
		Settings.camera_offset = offset
