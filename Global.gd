extends Node2D

var font: DynamicFont
var font_size: int = 32
var cell_size = Vector2(0, 0)
var cell = Vector2(0, 0)
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

# used to determine cells, that will be drawn as non walkable terrain.
var terrain_color: Color = Color.lightslategray

# when exporting the game res:// should be replaced by user:// as the export
# will not have access to the res-folder. 
var project_path = "res://TextMapProject.tscn"
var project_name = "TextMapProject"

const LAYER_TEXT = "Text Layer"
const LAYER_TERRAIN = "Terrain Layer"


func _ready():
	font = DynamicFont.new()
	font.font_data = load('res://fonts/monogram_extended.ttf')
	font.size = font_size
	cell_size = _set_cell_size()
	prints('using cell size:', cell_size)

	screen_size_pixels = screen_size_characters * cell_size


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


func get_cell_polygon() -> Polygon2D:
	"""
	return a polygon, with the same size as a cell.
	"""
	var pol = Polygon2D.new()
	pol.polygon = PoolVector2Array([Vector2(0,0),
								Vector2(Global.cell_size.x, 0),
								Global.cell_size,
								Vector2(0, Global.cell_size.y)])
	return pol


func get_cell_texture(col: Color) -> ImageTexture:
	"""
	return a ImageTexture with the same size as a cell and the given color.
	"""
	var tex = ImageTexture.new()
	var img = Image.new()
	img.create(cell_size.x, cell_size.y, true, Image.FORMAT_RGBA8)
	img.fill(col)
	tex.create_from_image(img)	
	return tex
