extends TileMap


var _drag_offset: Vector2 = Vector2.ZERO
var _drag_backup: Dictionary


func set_cell_character(character: String):
	set_cellv(Global.cell, tile_set.find_tile_by_name(character))


func clear_cell(c = null):
	if c == null: c = Global.cell
	set_cellv(c, -1)


func clear_left_cell(c = null):
	if c == null: c = Global.cell
	set_cell(c.x - 1, c.y, -1)


func push_cells(c = null):
	"""
	Shift subsequent characters in the current row right
	until two emtpy cells are found.
	"""
	if c == null: c = Global.cell
	var upcoming = get_upcoming_cells(c)
	# need to start from the back as n+1 is stored and would overwrite else.
	upcoming.invert()
	for x in upcoming:
		set_cell(x + 1, c.y, get_cell(x, c.y))
		set_cell(x, c.y, -1)


func get_upcoming_cells(c = null) -> Array:
	"""
	returns the x coordinates of upcoming not empty cells in current row
	until two empty cells are found.
	"""
	if c == null: c = Global.cell
	var upcoming = []
	var used = get_used_cells()
	var x = c.x
	while true:
		if Vector2(x, c.y) in used:
			upcoming.append(float(x))
		elif not Vector2(x + 1, c.y) in used and x != c.x:
			# Found a two spaced gap, can stop now.
			break
		x += 1
	return upcoming


func get_former_cells(c = null) -> Array:
	if c == null: c = Global.cell
	var former = []
	var used = get_used_cells()
	var x = c.x
	while true:
		if Vector2(x, c.y) in used:
			former.append(float(x))
		elif not Vector2(x - 1, c.y) in used and x != c.x:
			# Found a two spaced gap, can stop now.
			break
		x -= 1
	return former


func pull_cells(c = null):
	"""
	Shift subsequent characters in the current row left
	until two emtpy cells are found.
	"""
	if c == null: c = Global.cell
	for x in get_upcoming_cells(c):
		set_cell(x - 1, c.y, get_cell(x, c.y))
		set_cell(x, c.y, -1)		


func get_home() -> int:
	"""
	Returns the change in x coordinate to reach
	the beginning of the current row.
	"""
	var c = get_former_cells()
	if len(c):
		return c.min() - Global.cell.x
	return 0


func get_end() -> int:
	"""
	Returns the change in x coordinate to reach
	the end of the current row.
	"""
	var c = get_upcoming_cells()
	if len(c):
		return c.max() - Global.cell.x
	return 0


func start_dragging():
	_drag_backup = get_used_cells_with_ids()


func get_used_cells_with_ids() -> Dictionary:
	var ret = {}
	for c in get_used_cells():
		ret[c] = get_cellv(c)
	return ret


func show_backup():
	clear()
	for coord in _drag_backup:
		set_cellv(coord, _drag_backup[coord])

		
func drag_cells(cells: PoolVector2Array, offset: Vector2):
	"""
	Drag the given cells by the given offset.
	Also empty cells must be given.
	Call this function every time, offset changes.
	"""
	show_backup()
	for c in cells:
		# clear all origin and target cells.
		# yes, needs to be done before drawing again.
		set_cellv(c, -1)
		set_cellv(c + offset, -1)
	var move_to: Vector2
	for c in cells:
		move_to = c + offset
		# is there a character to move?
		if _drag_backup.has(c):
			set_cellv(move_to, _drag_backup[c])
