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
	# TODO: drag margins need to be adjusted to the size of the cursor.
	# But only, if dragging is used sometime in the future.
	_initial_zoom_and_positioning()

func _initial_zoom_and_positioning():
	"""
	zoom out a litte bit, that a whole screen is visible and
	position the camera, so that this screen is centered.
	"""
	var rect = get_camera_viewport_rect()
	zoom = Vector2(1.1, 1.1)
	var zoomed_rect = get_camera_viewport_rect()
	var diff = zoomed_rect.size - rect.size
	offset = -diff / 2

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

func get_camera_viewport_rect() -> Rect2:
	"""
	returns the actual visible rect of the camera including the zoom.
	"""
	var cameraPos = get_camera_screen_center()
	var viewportRect = get_viewport_rect().size * zoom
	var pos_x = cameraPos.x - viewportRect.x / 2
	var pos_y = cameraPos.y - viewportRect.y / 2
	return Rect2(Vector2(pos_x, pos_y), viewportRect)
