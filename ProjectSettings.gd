extends Node

# SETTINGS, THAT GET SAVED.
var camera_zoom: Vector2 = Vector2.ONE
var camera_offset: Vector2 = Vector2.ZERO
var font_path = "res://fonts/monogram_extended.ttf"
var font_size: int = 128
var cell: Vector2 = Vector2.ZERO
# size of a screen in characters. will affect grid.
var screen_size_characters: Vector2 = Vector2(32, 9)
var show_grid: bool = true
var cursor_color: Color = Color.dimgray
var text_color: Color = Color.azure
var grid_color: Color = Color.dimgray
var selection_color: Color = Color.goldenrod
var mouse_color: Color = Color.goldenrod
# used to determine cells, that will be drawn as non walkable terrain.
var terrain_color: Color = Color.azure
# set size of terrain tiles besed on cell size used for text.
var terrain_size_factor: Vector2 = Vector2(1.0, 0.5)
# var background_color: Color = Color(0.3, 0.3, 0.3, 1.0) # standard godot.
var background_color: Color = Color(0.1, 0.1, 0.1, 1.0)
# complex collision will wrap a collision polygon around every single character,
# representing the individual shape of every character.
# simple collision will just create a rectangle collision shape with the size of a cell.
var use_complex_collision: bool = true

# SETTINGS, THAT GET CALCULATED AND NOT SAVED
var font: DynamicFont
# helper variable to remember cell size for text layer.
var cell_size_font: Vector2
# helper variable to remember cell size for terrain layer.
var cell_size_terrain: Vector2
# current cell size, will change when switching layer. 
var cell_size = Vector2(0, 0)
# size of a screen in pixels. Is calculated from the cell size/ font size
# and screen_size_characters.
var screen_size_pixels: Vector2


func loads():
	var config = ConfigFile.new()
	if config.load(Global.get_project_settings_path()) == OK:
		for p in get_script().get_script_property_list():
			if not p["name"] in ["font", "cell_size", "screen_size_pixels"]:
				set(p["name"], config.get_value("project_settings", p["name"]))
	_setup_properties()
	VisualServer.set_default_clear_color(background_color)
	
func _setup_properties():
	font = DynamicFont.new()
	font.font_data = load(font_path)
	font.size = font_size
	cell_size = _set_cell_size()
	cell_size_font = cell_size
	cell_size_terrain = cell_size * terrain_size_factor
	screen_size_pixels = screen_size_characters * cell_size


func saves():
	if Global.project_name == "": return
	var config = ConfigFile.new()
	for p in get_script().get_script_property_list():
		if not p["name"] in ["font", "cell_size", "screen_size_pixels"]:
			config.set_value("project_settings", p["name"], get(p["name"]))
	config.save(Global.get_project_settings_path())


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
