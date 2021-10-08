extends TileMap

export var layer_name: String = Global.LAYER_TERRAIN

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
	shape.extents = Global.cell_size * 0.5
	set.create_tile(0)
	set.tile_set_name(0, "terrain")
	set.tile_set_texture(0, Global.get_cell_texture(Global.terrain_color))
	set.tile_set_shape(0, 0, shape)
	set.tile_set_shape_offset(0, 0, Global.cell_size * 0.5)

	cell_size = Global.cell_size
	tile_set = set


func _on_TextMap_switch_layer(to_layer_name):
	if to_layer_name == layer_name:
		set_process_unhandled_input(true)
	else:
		set_process_unhandled_input(false)

