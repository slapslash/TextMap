extends Polygon2D

func _ready():
	# set cursor behind the text
	z_index = -1
	
	polygon = PoolVector2Array([Vector2(0,0),
								Vector2(Global.cell_size.x, 0),
								Global.cell_size,
								Vector2(0, Global.cell_size.y)])

	_update_cursor()

func init_custom_cursor(zoom_level: float = 1.0):
	"""
	change cursor to something more suitable than the standard arrow.
	TODO: sadly, the complete custom cursor isn't as easy to do, as not only
	the camera zoom level applies, but also the 
	"""
	var tex = ImageTexture.new()
	var img = Image.new()
	var width = round(Global.cell_size.x / zoom_level)
	var height = round(Global.cell_size.y / zoom_level)
	img.create(width, height, true, Image.FORMAT_RGBA8)
	var col = Color.goldenrod
	# set the transparancy of the cursor
	col.a = 0.6
	img.fill(col)
	tex.create_from_image(img)
	Input.set_custom_mouse_cursor(tex, 0, Vector2(width / 2, height / 2))


func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				var mpos = get_global_mouse_position()
				Global.cell.x = round((mpos.x - Global.cell_size.x / 2) / Global.cell_size.x)
				Global.cell.y = round((mpos.y - Global.cell_size.y / 2) / Global.cell_size.y)
				_update_cursor()
				
	elif event is InputEventKey and event.pressed:
		var add = Vector2(0, 0)
		var scm = event.get_scancode_with_modifiers()
		match scm:
			KEY_RIGHT:
				add.x = 1
			KEY_LEFT:
				add.x = -1
			KEY_UP:
				add.y = -1
			KEY_DOWN:
				add.y = 1
			KEY_ESCAPE:
				print("escape pressed")
			KEY_ENTER, KEY_KP_ENTER:
				print("enter pressed")
			KEY_SPACE:
				Global.push_cells()
				add.x = 1
			KEY_DELETE:
				Global.clear_cell()
				Global.pull_cells()
			KEY_BACKSPACE:
				Global.clear_left_cell()
				Global.pull_cells()
				add.x = -1
			268435539: # Control+S
				Global.save_matrix()
				Global.save_as_godot_scene()
			_:
				var ch = OS.get_scancode_string(scm)
				var last_input = char(event.unicode)
				if last_input == '':
					# most likely some unhandled function key.
					printt("function key pressed:", ch, scm)
				else:
					printt(last_input, scm, ch)
					Global.set_cell_character(last_input)
					add.x = 1
		change_cell(add)
		

func _update_cursor():
	global_position = Global.cell_size * Global.cell
	
func change_cell(add: Vector2):
	Global.cell += add
	_update_cursor()

