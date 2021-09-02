extends Node2D

var font
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


func _ready():
	font = DynamicFont.new()
	font.font_data = load('res://fonts/monogram_extended.ttf')
	font.size = font_size

	cell_size = _set_cell_size()
	prints('using cell size:', cell_size)

	screen_size_pixels = screen_size_characters * cell_size
	matrix = load_matrix()

func _set_cell_size() -> Vector2:
	"""
	Depending on the Font, different characters could have different sizes.
	Iterate over the ASCII-table and use the biggest char as cell-size.
	Non-Monospaced Fonts will not look great anyhow.
	"""
	var cz = Vector2.ZERO
	for c in range(33, 127):
		var size = font.get_char_size(c)
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
	update()


func clear_cell():
	if not matrix.has(cell.y): return
	if cell.x in matrix[cell.y]:
		matrix[cell.y].erase(cell.x)
	if matrix[cell.y].empty():
		var _e = matrix.erase(cell.y)
	update()


func clear_left_cell():
	if not matrix.has(cell.y): return
	matrix[cell.y].erase(cell.x-1)
	if matrix[cell.y].empty():
		var _e = matrix.erase(cell.y)
	update()


func push_cells():
	"""
	Shift subsequent characters in the current row right
	until two emtpy cells are found.
	"""
	var upcoming = _upcoming_cells()
	# need to start from the back as n+1 is stored and would overwrite else.
	upcoming.invert()
	for u in upcoming:
		matrix[cell.y][u+1] = matrix[cell.y][u]
		matrix[cell.y].erase(u)
	update()

	
func pull_cells():
	"""
	Shift subsequent characters in the current row left
	until two emtpy cells are found.
	"""
	for u in _upcoming_cells():
		matrix[cell.y][u-1] = matrix[cell.y][u]
		matrix[cell.y].erase(u)
	update()


func _upcoming_cells() -> Array:
	var upcoming = []
	if matrix.has(cell.y):
		var pos = matrix[cell.y].keys()
		for i in range(cell.x, pos.max() + 1):
			if i in pos:
				upcoming.append(float(i))
			# if current cursor cell is empty and the next too,
			# it can be processed nonetheless.
			elif (not i+1 in pos) and (i != cell.x):
				# Found a two spaced gap, can stop now.
				break	
	return upcoming


func _draw():
	"""
	In fact, only a changed cell needs to be drawn, but for now the
	whole matrix is updated.
	"""
	for y in matrix:
		for x in matrix[y]:
			var to_draw = ord(matrix[y][x])
			var pos = Vector2(x, y) * cell_size + Vector2(0, font.get_ascent())
			font.draw_char(get_canvas_item(), pos, to_draw, -1, Color.azure)
	
func save_as_godot_scene():
	# TODO: font needs to be saved/copied too.
	var scene = Node2D.new()
	scene.name = 'TextMap'
	for y in matrix:
		for x in matrix[y]:
			var name_extension = '_' + str(y) + ',' + str(x)
			# pos of a label is the top left corner, which matches the matrix
			# coordinates. also the size should match cell_size ideally.
			var label = Label.new()
			label.set_position(Vector2(x, y) * cell_size)
			label.set("custom_fonts/font", font)
			label.text = matrix[y][x]
			label.name = matrix[y][x] + name_extension
			scene.add_child(label)
			label.owner = scene

			var body = StaticBody2D.new()
			var coll = CollisionShape2D.new()
			var shape = RectangleShape2D.new()
			body.position = cell_size / 2
			body.name = 'StaticBody2D' + name_extension
			label.add_child(body)
			body.owner = scene

			shape.extents = cell_size / 2

			coll.name = 'CollisionShape2D' + name_extension

			coll.shape = shape
			body.add_child(coll)
			coll.owner = scene

	var packed_scene = PackedScene.new()
	packed_scene.pack(scene)
	var _e = ResourceSaver.save("res://saved.tscn", packed_scene)

func save_matrix():
	var savefile = File.new()
	savefile.open("res://saved_matrix.txt", File.WRITE)
	savefile.store_string(to_json(matrix))
	savefile.close()

func load_matrix() -> Dictionary:
	var savefile = File.new()
	if not savefile.file_exists("res://saved_matrix.txt"):
		return {}
	savefile.open("res://saved_matrix.txt", File.READ)
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
