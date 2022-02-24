extends TileMap

const layer_name: String = Global.LAYER_TERRAIN

var _paint: bool = false
var _delete: bool = false

func _ready():
	_init_tilemap()


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				_paint = true
				set_cellv(Global.get_cell_from_mouse_pos(), 0)
			elif event.button_index == BUTTON_RIGHT:
				_delete = true
				set_cellv(Global.get_cell_from_mouse_pos(), -1)
		else:
			_paint = false
			_delete = false
	
	elif event is InputEventMouseMotion:
		if _paint:
			set_cellv(Global.get_cell_from_mouse_pos(), 0)
		elif _delete:
			set_cellv(Global.get_cell_from_mouse_pos(), -1)


func _init_tilemap():
	var set = TileSet.new()
	var shape = RectangleShape2D.new()
	shape.extents = Settings.cell_size_terrain * 0.5
	set.create_tile(0)
	set.tile_set_name(0, "terrain")
	set.tile_set_texture(0, get_cell_texture(Settings.terrain_color))
	set.tile_set_shape(0, 0, shape)
	set.tile_set_shape_offset(0, 0, Settings.cell_size_terrain * 0.5)

	cell_size = Settings.cell_size_terrain
	tile_set = set


func get_cell_texture(col: Color) -> ImageTexture:
	"""
	return a ImageTexture with the same size as a cell and the given color.
	"""
	var tex = ImageTexture.new()
	var img = Image.new()
	img.create(Settings.cell_size_terrain.x, Settings.cell_size_terrain.y, false, Image.FORMAT_RGBAF)
	img.fill(col)
	tex.create_from_image(img)
	return tex


func _on_TextMap_switch_layer(to_layer_name):
	if to_layer_name == layer_name:
		set_process_unhandled_input(true)
	else:
		set_process_unhandled_input(false)

