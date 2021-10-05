extends Viewport

var _tilemap: TileMap


func _ready():
	_set_size(len(Global.font.get_available_chars()))
	render_target_update_mode = Viewport.UPDATE_ALWAYS
	# as _draw is called on idle and the texture after _draw also isn't
	# available immediately, we need to wait some time.
	# TODO: force_draw() might be a better solution in godot 4.0
	yield(get_tree().create_timer(0.3), "timeout")
	var _tiles = _get_tile_textures()
	_tilemap = _prepare_tilemap(_tiles)
	
	
func _prepare_tilemap(tiles: Dictionary) -> TileMap:
	var set = TileSet.new()
	var shape = RectangleShape2D.new()
	shape.extents = Global.cell_size * 0.5
	var i = 0
	for chr in tiles.keys():
		set.create_tile(i)
		set.tile_set_name(i, chr)
		set.tile_set_texture(i, tiles[chr])
		set.tile_set_shape(i, 0, shape)
		set.tile_set_shape_offset(i, 0, Global.cell_size * 0.5)
		i += 1

	var map = TileMap.new()
	map.name = "SavedMap"
	map.cell_size = Global.cell_size
	map.tile_set = set
	return map


func _fill_tilemap():
	for y in Global.matrix:
		for x in Global.matrix[y]:
			var id = _tilemap.tile_set.find_tile_by_name(Global.matrix[y][x])
			_tilemap.set_cell(x, y, id)


func export_tilemap():
	_fill_tilemap()
	var scene = PackedScene.new()
	assert(scene.pack(_tilemap) == OK)
	assert(ResourceSaver.save(Global.project_path, scene) == OK)


func _get_tile_textures() -> Dictionary:
	var tiles = {}
	var dat: Image = get_texture().get_data()
	dat.flip_y()
	var x = 0
	for chr in Global.font.get_available_chars():
		var tile = dat.get_rect(Rect2(Vector2(x, 0), Global.cell_size))
		# convert to preserve transparency
		tile.convert(Image.FORMAT_RGBA8)
		if not tile.is_invisible():
			var tex = ImageTexture.new()
			# disable standard flags.
			tex.create_from_image(tile, 0)
			# filter characters, that are not visible (like space).
			tiles[chr] = tex
		x += Global.cell_size.x
	return tiles


func _set_size(n_characters):
	"""
	Set size of viewport, to fit the given amount of characters
	with the globally set font.
	"""
	size = Vector2(Global.cell_size.x * n_characters, Global.cell_size.y)


func _on_Inputs_export_tilemap():
	export_tilemap()
