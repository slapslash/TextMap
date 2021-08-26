extends Camera2D

var _scroll: bool = false
var _scroll_start: Vector2

"""
Node to enable zooming, scrolling (moving with right mouse button)
and the camera following the cursor, when reaching the screen extends.

If camera is not attached to the cursor, zooming and scrolling also works.

TODO: following the cursor doesn't work correctly by now. function reset_offset
is corresponding to this mechanic.
"""

func _ready():
	# center the camera to the cursor.
	offset = Global.cell_size / 2

	# TODO: drag margins need to be adjusted to the size of the cursor.
	# But only, if dragging is used sometimes.
	
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_WHEEL_DOWN:
				zoom *= 1.1
			elif event.button_index == BUTTON_WHEEL_UP:
				zoom *= 0.9
			elif event.button_index == BUTTON_RIGHT:
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

#func reset_offset():
#	if offset:
#		global_position = get_camera_screen_center()
#		offset = Vector2.ZERO
##		force_update_scroll()
##		align()
