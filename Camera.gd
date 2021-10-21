extends Camera2D

var _scroll: bool = false
var _scroll_start: Vector2

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
#			reset_offset()

func _process(_delta):
	if _scroll:
		var scroll_vector = _scroll_start - get_global_mouse_position()
		offset += scroll_vector


func _unhandled_key_input(event):
	if event.pressed:
		var scm = event.get_scancode_with_modifiers()
		match scm:
			285212689: # Control+Right
				offset += Vector2(1, 0) * Global.cell_size * zoom

			285212687: # Control+Left
				offset += Vector2(-1, 0) * Global.cell_size * zoom

			285212688: # Control+Up
				offset += Vector2(0, -1) * Global.cell_size * zoom

			285212690: # Control+Down
				offset += Vector2(0, 1) * Global.cell_size * zoom

#func reset_offset():
#	if offset:
#		global_position = get_camera_screen_center()
#		offset = Vector2.ZERO
##		force_update_scroll()
##		align()
