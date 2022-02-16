extends Node2D


# used to save last opened/recent project path
var _editor_settings_path = "user://TextMap.config"

var project_directory = ""
var project_name = ""


const LAYER_TEXT = "Text"
const LAYER_TERRAIN = "Terrain"


func _ready():
	loads()
	Settings.loads()


func loads():
	var config = ConfigFile.new()
	if not config.load(_editor_settings_path) == OK: return
	project_directory = config.get_value("project", "project_directory")
	project_name = config.get_value("project", "project_name")
	# recheck if project still exists
	var file = File.new()
	if not file.file_exists(get_project_path()):
		project_directory = ""
		project_name = ""


func saves():
	if project_name == "": return
	var config = ConfigFile.new()
	config.set_value("project", "project_directory", project_directory)
	config.set_value("project", "project_name", project_name)
	config.save(_editor_settings_path)


func get_project_path():
	return project_directory + project_name + ".tscn"

	
func get_project_settings_path():
	return project_directory + project_name + ".config"


func get_cell_from_mouse_pos() -> Vector2:
	"""
	Get the current cell from the global mouse position.
	The approximation of which is the current cell
	is based on the custom cursor and its extends.
	"""
	var mpos = get_global_mouse_position()
	var x = round((mpos.x - Settings.cell_size.x / 2) / Settings.cell_size.x)
	var y = round((mpos.y - Settings.cell_size.y / 2) / Settings.cell_size.y)
	return Vector2(x, y)


func get_cell_polygon() -> Polygon2D:
	"""
	return a polygon, with the same size as a cell.
	"""
	var pol = Polygon2D.new()
	pol.polygon = PoolVector2Array([Vector2(0,0),
								Vector2(Settings.cell_size.x, 0),
								Settings.cell_size,
								Vector2(0, Settings.cell_size.y)])
	return pol


func get_cell_texture(col: Color) -> ImageTexture:
	"""
	return a ImageTexture with the same size as a cell and the given color.
	"""
	var tex = ImageTexture.new()
	var img = Image.new()
	img.create(Settings.cell_size.x, Settings.cell_size.y, false, Image.FORMAT_RGBAF)
	img.fill(col)
	tex.create_from_image(img)
	return tex
