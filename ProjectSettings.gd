extends Node

# SETTINGS, THAT GET SAVED.
var font: DynamicFont
var cell_size = Vector2(0, 0)
# size of a screen in pixels. Is calculated from the cell size/ font size
# and screen_size_characters.
var screen_size_pixels: Vector2
var font_path = "res://fonts/monogram_extended.ttf"
var font_size: int = 32
var cell: Vector2 = Vector2.ZERO
# size of a screen in characters. will affect grid.
var screen_size_characters: Vector2 = Vector2(30, 8)
var show_grid: bool = true
var cursor_color: Color = Color.dimgray
var text_color: Color = Color.azure
var grid_color: Color = Color.dimgray
var selection_color: Color = Color.goldenrod
var mouse_color: Color = Color.goldenrod
# used to determine cells, that will be drawn as non walkable terrain.
var terrain_color: Color = Color.azure

	
func loads():
	var file = File.new()
	if file.file_exists(Global.get_project_settings_path()):
		file.open(Global.get_project_settings_path(), File.READ)
		for p in get_script().get_script_property_list():
			set(p["name"], file.get_var())
		file.close()
	_setup_properties()
	
	
func _setup_properties():
	font = DynamicFont.new()
	font.font_data = load(font_path)
	font.size = font_size
	cell_size = _set_cell_size()
	screen_size_pixels = screen_size_characters * cell_size


func saves():
	if Global.project_name == "": return
	var file = File.new()
	file.open(Global.get_project_settings_path(), File.WRITE)
	for p in get_script().get_script_property_list():
		file.store_var(get(p["name"]))
	file.close()


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
