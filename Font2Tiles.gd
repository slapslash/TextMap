extends Viewport

onready var _parent_map = get_parent()


func _ready():
	assert(_parent_map is TileMap)
	_set_size(len(Settings.font.get_available_chars()))
	render_target_update_mode = Viewport.UPDATE_ALWAYS
	# as _draw is called on idle and the texture after _draw also isn't
	# available immediately, we need to wait some time.
	# TODO: force_draw() might be a better solution in godot 4.0
	yield(get_tree().create_timer(0.2), "timeout")
	var _tiles = _get_tile_textures()
	_init_tilemap(_tiles)

	
func _init_tilemap(tiles: Dictionary):
	var set = TileSet.new()
	var shape = RectangleShape2D.new()
	shape.extents = Settings.cell_size * 0.5
	var i = 0
	for chr in tiles.keys():
		set.create_tile(i)
		set.tile_set_name(i, chr)
		set.tile_set_texture(i, tiles[chr])

		# set collision shape
		if Settings.use_complex_collision:
			var bm = BitMap.new()
			bm.create_from_image_alpha(tiles[chr].get_data(), 0.1)
			# dilation avoids small pieces getting no collision.
			bm.grow_mask(1, Rect2(Vector2.ZERO, Settings.cell_size))
			var polygons = bm.opaque_to_polygons(Rect2(Vector2.ZERO, Settings.cell_size), 1.0)
			var shape_id = 0
			for p in polygons:
				var poly = ConvexPolygonShape2D.new()
				poly.points = p
				set.tile_set_shape(i, shape_id, poly)
			shape_id += 1
		else:
			set.tile_set_shape(i, 0, shape)
			set.tile_set_shape_offset(i, 0, Settings.cell_size * 0.5)

		i += 1

	_parent_map.cell_size = Settings.cell_size
	_parent_map.tile_set = set


func _get_tile_textures() -> Dictionary:
	var tiles = {}
	var dat: Image = get_texture().get_data()
	dat.flip_y()
	var x = 0
	for chr in Settings.font.get_available_chars():
		var tile = dat.get_rect(Rect2(Vector2(x, 0), Settings.cell_size))
		# convert to preserve transparency
		tile.convert(Image.FORMAT_RGBA8)
		# filter characters, that are not visible (like space).
		if not tile.is_invisible():
			var tex = ImageTexture.new()
			# disable standard flags.
			tex.create_from_image(tile, 0)
			tiles[chr] = tex
		x += Settings.cell_size.x
	return tiles


func _set_size(n_characters):
	"""
	Set size of viewport, to fit the given amount of characters
	with the globally set font.
	"""
	size = Vector2(Settings.cell_size.x * n_characters, Settings.cell_size.y)

