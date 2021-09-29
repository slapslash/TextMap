extends Node2D

var font: DynamicFont
var font_size: int = 32
var cell_size = Vector2(0, 0)
var cell = Vector2(0, 0)
var matrix: Dictionary # y,x
# size of a screen in characters. will affect grid... Is calculated
# from the cell size/ font size.
var screen_size_characters: Vector2 = Vector2(30, 8)
# size of a screen in pixels. Is calculated from the cell size/ font size
# and screen_size_characters.
var screen_size_pixels: Vector2
var show_grid: bool = true

var cursor_color: Color = Color.dimgray
var text_color: Color = Color.azure
var grid_color: Color = Color.dimgray
var selection_color: Color = Color.goldenrod
var mouse_color: Color = Color.goldenrod

var _drag_offset: Vector2 = Vector2.ZERO
var _matrix_backup: Dictionary

var matrix_path = "user://saved_matrix.txt"
var matrix_fallback_path = "res://saved_matrix.txt"

signal draw_matrix


func _ready():
	font = DynamicFont.new()
	font.font_data = load('res://fonts/monogram_extended.ttf')
	font.size = font_size
	cell_size = _set_cell_size()
	prints('using cell size:', cell_size)

	screen_size_pixels = screen_size_characters * cell_size
	matrix = load_matrix(matrix_path)
	if matrix.empty():
		print("matrix not found in user directory, loading default in res://")
		matrix = load_matrix(matrix_fallback_path)

func _set_cell_size() -> Vector2:
	"""
	Depending on the Font, different characters could have different sizes.
	Iterate over the available characters and use the biggest char as cell-size.
	Non-Monospaced Fonts will not look great anyhow.
	"""
	var cz = Vector2.ZERO
	for c in font.get_available_chars():
		var size = font.get_char_size(ord(c))
		if size.x > cz.x:
			cz.x = size.x
		if size.y > cz.y:
			cz.y = size.y
	return cz


func set_cell_character(character: String):
	if cell.y in matrix:
		matrix[cell.y][cell.x] = character
	else:
		matrix[cell.y] = {cell.x: character}
	emit_signal("draw_matrix")
	

func clear_cell(c = null):
	if c == null: c = cell
	if not matrix.has(c.y): return
	if c.x in matrix[c.y]:
		matrix[c.y].erase(c.x)
	if matrix[c.y].empty():
		var _e = matrix.erase(c.y)
	emit_signal("draw_matrix")


func clear_left_cell(c = null):
	if c == null: c = cell
	if not matrix.has(c.y): return
	matrix[c.y].erase(c.x-1)
	if matrix[c.y].empty():
		var _e = matrix.erase(c.y)
	emit_signal("draw_matrix")


func push_cells(c = null):
	"""
	Shift subsequent characters in the current row right
	until two emtpy cells are found.
	"""
	if c == null: c = cell
	var upcoming = get_upcoming_cells(c)
	# need to start from the back as n+1 is stored and would overwrite else.
	upcoming.invert()
	for u in upcoming:
		matrix[c.y][u+1] = matrix[c.y][u]
		matrix[c.y].erase(u)
	emit_signal("draw_matrix")


func pull_cells(c = null):
	"""
	Shift subsequent characters in the current row left
	until two emtpy cells are found.
	"""
	if c == null: c = cell
	for u in get_upcoming_cells(c):
		matrix[c.y][u-1] = matrix[c.y][u]
		matrix[c.y].erase(u)
	emit_signal("draw_matrix")


func start_dragging():
	_matrix_backup = matrix.duplicate()


func drag_cells(cells: PoolVector2Array, offset: Vector2):
	"""
	Drag the given cells by the given offset.
	Also empty cells must be given.
	Call this function every time, offset changes.
	"""
	matrix = _matrix_backup.duplicate(true)
	for c in cells:
		# clear all origin and target cells.
		clear_cell(c)
		clear_cell(c + offset)
	for c in cells:
		var move_to = c + offset
		# is there a character to move?
		if c.y in _matrix_backup and c.x in _matrix_backup[c.y]:
			# do we need to create the row first?
			if move_to.y in matrix:
				matrix[move_to.y][move_to.x] = _matrix_backup[c.y][c.x]
			else:
				matrix[move_to.y] = {move_to.x: _matrix_backup[c.y][c.x]}
	emit_signal("draw_matrix")


func get_upcoming_cells(c = null) -> Array:
	if c == null: c = cell
	var upcoming = []
	if matrix.has(c.y):
		var pos = matrix[c.y].keys()
		for i in range(c.x, pos.max() + 1):
			if i in pos:
				upcoming.append(float(i))
			# if current cursor cell is empty and the next too,
			# it can be processed nonetheless.
			elif (not i+1 in pos) and (i != c.x):
				# Found a two spaced gap, can stop now.
				break
	return upcoming


func get_former_cells(c = null) -> Array:
	if c == null: c = cell
	var former = []
	if matrix.has(c.y):
		var pos = matrix[c.y].keys()
		for i in range(c.x, pos.min() - 1, -1):
			if i in pos:
				former.append(float(i))
			# if current cursor cell is empty and the next too,
			# it can be processed nonetheless.
			elif (not i-1 in pos) and (i != c.x):
				# Found a two spaced gap, can stop now.
				break
	return former


func get_home() -> int:
	"""
	Returns the change in x coordinate to reach
	the beginning of the current row.
	"""
	var c = get_former_cells()
	if len(c):
		return c.min() - cell.x
	return 0

func get_end() -> int:
	"""
	Returns the change in x coordinate to reach
	the end of the current row.
	"""
	var c = get_upcoming_cells()
	if len(c):
		return c.max() - cell.x
	return 0

func get_cell_from_mouse_pos() -> Vector2:
	"""
	Get the current cell from the global mouse position.
	The approximation of which is the current cell
	is based on the custom cursor and its extends.
	"""
	var mpos = get_global_mouse_position()
	var x = round((mpos.x - Global.cell_size.x / 2) / Global.cell_size.x)
	var y = round((mpos.y - Global.cell_size.y / 2) / Global.cell_size.y)
	return Vector2(x, y)


func save_matrix():
	var savefile = File.new()
	savefile.open(matrix_path, File.WRITE)
	savefile.store_string(to_json(matrix))
	savefile.close()


func load_matrix(path: String) -> Dictionary:
	var savefile = File.new()
	if not savefile.file_exists(path):
		return {}
	savefile.open(path, File.READ)
	var txt = savefile.get_as_text()
	savefile.close()
	if not txt:
		return {}

	var mat = parse_json(txt)
	if not mat:
		return {}
	
	# convert the json-parsed datatypes to those we need.
	var ret = {}
	for y in mat:
		ret[float(y)] = {}
		for x in mat[y]:
			ret[float(y)][float(x)] = str(mat[y][x])
	return ret


func get_unique_symbols_in_matrix() -> Array:
	"""
	Returns sorted (ascending) array with the unique ascii/unicodes of the 
	characters that are used in the matrix.
	"""
	var uniques = []
	for y in Global.matrix:
		for x in Global.matrix[y]:
			var code = ord(Global.matrix[y][x])
			if not code in uniques:
				uniques.append(code)
	uniques.sort()
	return uniques

