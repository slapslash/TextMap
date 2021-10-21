extends	Node2D

var _start = null
var _end = null
var _drag_keys_start: bool = false
var _drag_keys_offset: Vector2 = Vector2.ZERO
var _drag_mouse_start = null
var _drag_mouse_offset: Vector2 = Vector2.ZERO

var _change_selection_by_mouse: bool = false
var _selected_cells: PoolVector2Array

onready var parent_tilemap = $"/root/TextMap/Project/TextLayer"

func _process(_delta):
	update()


func are_cells_selected() -> bool:
	return not _selected_cells.empty()


func get_selected_cells() -> PoolVector2Array:
	return _selected_cells


func clear():
	"""
	Abort/clear selection without affecting the cells.
	"""
	_start = null
	_end = null
	_drag_mouse_start = null
	_drag_mouse_offset = Vector2.ZERO
	_drag_keys_start = false
	_drag_keys_offset = Vector2.ZERO
	_set_selected_cells()


func clear_selected_cells():
	"""
	Clear the cells in selection and pull subsequent cells.
	Cursor will be set to the most top left cell in selection.
	"""
	var sel = _selected_cells
	var new_cursor_pos = sel[0]
	# start from behind, to get cell pulling right.
	sel.invert()
	for c in sel:
		parent_tilemap.clear_cell(c)
		parent_tilemap.pull_cells(c)
	Global.cell = new_cursor_pos


func on_selection_by_key(add_x: int, add_y: int):
	"""
	Call this, if selection should be altered/started from keyboard input.
	Typically Shift+Arrow keys.
	Relies on current cell has not yet been changed due to arrow movement.
	"""
	if _start == null:
		# start new selection
		_start = Global.cell
	if _end == null:
		_end = Global.cell + Vector2(add_x, add_y)
	else:
		_end += Vector2(add_x, add_y)
	_set_selected_cells()


func on_drag_by_key(add_x: int, add_y: int):
	if _start == null:
		# no selection active
		return
	if not _drag_keys_start:
		parent_tilemap.start_dragging()
		_drag_keys_start = true
	_drag_keys_offset += Vector2(add_x, add_y)
	parent_tilemap.drag_cells(_selected_cells, _drag_keys_offset)


func on_left_mouse_button_pressed(at_cell: Vector2):
	if not at_cell in _selected_cells:
		# start a new selection
		_drag_keys_start = false
		_drag_keys_offset = Vector2.ZERO
		_start = at_cell
		_end = null
		_change_selection_by_mouse = true
	else:
		_drag_mouse_start = at_cell
		parent_tilemap.start_dragging()


func on_left_mouse_button_released():
	if _change_selection_by_mouse:
		# after the releasing LMB, the current selection will
		# not change anymore, if mouse is moved.
		_change_selection_by_mouse = false
	else:
		# if select from mouse is already false, LMB has been
		# released again and if or if not selection had been
		# interacted with: reset it.
		clear()
	_set_selected_cells()


func on_mouse_motion():
	if _change_selection_by_mouse:
		# change selection if mouse is moved and LMB still held.
		var mpos = Global.get_cell_from_mouse_pos()
		if mpos != _end or _end == null:
			_end = mpos
	elif _drag_mouse_start != null:
		var offset = Global.get_cell_from_mouse_pos() - _drag_mouse_start
		if offset != _drag_mouse_offset:
			_drag_mouse_offset = offset
			parent_tilemap.drag_cells(_selected_cells, _drag_mouse_offset)


func _set_selected_cells():
	"""
	Cells between _start and _end coordinates (cells) will be added to the
	selection array.
	The most top-left cell will be the first and the most bottom-right will
	be the last cell in the array. This should not change, as other
	functions rely on this.
	"""
	_selected_cells = PoolVector2Array()
	if _start == null or _end == null:
		return
	for x in range(min(_start.x, _end.x), max(_start.x, _end.x) + 1):
		for y in range(min(_start.y, _end.y), max(_start.y, _end.y) + 1):
			_selected_cells.push_back(Vector2(x, y))


func _get_rect(cell_size: Vector2) -> Rect2:
	"""
	returns Rect2 calculated from the cells of selection projected to
	the given cell_size. Rect2 will be in pixels.
	"""
	if _start == null or _end == null or _start == _end:
		return Rect2(Vector2.ZERO, Vector2.ZERO)	
	var pos = Vector2(min(_start.x, _end.x), min(_start.y, _end.y))
	var stop = Vector2(max(_start.x, _end.x), max(_start.y, _end.y))
	var rec = Rect2(pos * cell_size, (stop - pos).abs() * cell_size + cell_size)
	return rec


func _draw():
	var rec = _get_rect(Global.cell_size)
	var col = Global.selection_color
	col.a = 0.6
	draw_rect(rec, col)
