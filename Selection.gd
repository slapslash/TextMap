extends	Node2D

var _start = null
var _end = null
var _drag_start = null
var _drag_offset: Vector2 = Vector2.ZERO
var _select_from_mouse: bool = false

var selected_cells: PoolVector2Array

func _process(_delta):
	update()

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				var mpos = Global.get_cell_from_mouse_pos()
				if not mpos in selected_cells:
					# start a new selection
					_start = mpos
					_end = null
					_select_from_mouse = true
				else:
					_drag_start = mpos
					Global.start_dragging()

		elif not event.pressed:
			if event.button_index == BUTTON_LEFT:
				if _select_from_mouse:
					# after the releasing LMB, the current selection will
					# not change anymore, if mouse is moved.
					_select_from_mouse = false
				else:
					# if select from mouse is already false, LMB has been
					# released again and if or if not selection had been
					# interacted with: reset it.
					_start = null
					_end = null
					_drag_start = null
					_drag_offset = Vector2.ZERO
				_set_selected_cells()

				
	elif event is InputEventMouseMotion:
		if _select_from_mouse:
			# change selection if mouse is moved and LMB still held.
			var mpos = Global.get_cell_from_mouse_pos()
			if mpos != _end or _end == null:
				_end = mpos
		elif _drag_start != null:
			var offset = Global.get_cell_from_mouse_pos() - _drag_start
			if offset != _drag_offset:
				_drag_offset = offset
				Global.drag_cells(selected_cells, _drag_offset)

func _set_selected_cells():
	selected_cells = PoolVector2Array()
	if _start == null or _end == null:
		return
	for x in range(min(_start.x, _end.x), max(_start.x, _end.x) + 1):
		for y in range(min(_start.y, _end.y), max(_start.y, _end.y) + 1):
			selected_cells.push_back(Vector2(x, y))


func get_rect(cell_size: Vector2) -> Rect2:
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
	var rec = get_rect(Global.cell_size)
	var col = Color.goldenrod
	col.a = 0.6
	draw_rect(rec, col)
