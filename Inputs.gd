extends Node2D

onready var cursor: Polygon2D
onready var selection = $Selection

signal export_tilemap


func _ready():
	_init_cursor()


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var mpos = Global.get_cell_from_mouse_pos()
			Global.cell = mpos
			_update_cursor()
			if event.pressed:
				selection.on_left_mouse_button_pressed(mpos)
			elif not event.pressed:
				selection.on_left_mouse_button_released()
	elif event is InputEventMouseMotion:
		selection.on_mouse_motion()

	elif event is InputEventKey and not event.pressed:
		var scm = event.get_scancode_with_modifiers()
		match scm:
			16777238: # Control
				# This special case is needed to clear selection after
				# dragging by keys.
				selection.clear()

	elif event is InputEventKey and event.pressed:
		var add = Vector2(0, 0)
		var scm = event.get_scancode_with_modifiers()
		match scm:
			KEY_RIGHT:
				add.x = 1
				selection.clear()
			
			KEY_LEFT:
				add.x = -1
				selection.clear()
			
			KEY_UP:
				add.y = -1
				selection.clear()
			
			KEY_DOWN:
				add.y = 1
				selection.clear()
			
			50331665: # Shift+Right
				add.x = 1
				selection.on_selection_by_key(1, 0)
			
			50331663: # Shift+Left
				add.x = -1
				selection.on_selection_by_key(-1, 0)
			
			50331664: # Shift+Up
				add.y = -1
				selection.on_selection_by_key(0, -1)
			
			50331666: # Shift+Down
				add.y = 1
				selection.on_selection_by_key(0, 1)

			50331662: # Shift+End
				add.x = Global.get_end()
				selection.on_selection_by_key(add.x, 0)

			50331661: # Shift+Home
				add.x = Global.get_home()
				selection.on_selection_by_key(add.x, 0)

			285212689: # Control+Right
				selection.on_drag_by_key(1, 0)

			285212687: # Control+Left
				selection.on_drag_by_key(-1, 0)

			285212688: # Control+Up
				selection.on_drag_by_key(0, -1)

			285212690: # Control+Down
				selection.on_drag_by_key(0, 1)

			16777244: # F1
				var map = load("res://SavedMap.tscn").instance()
				var player = load("res://Player.tscn").instance()

				map.add_child(player)
				player.owner = map
				
				var scene = PackedScene.new()
				assert(scene.pack(map) == OK)
				assert(get_tree().change_scene_to(scene) == OK)
				
			KEY_ESCAPE:
				selection.clear()

			KEY_ENTER, KEY_KP_ENTER:
				if selection.are_cells_selected():
					selection.clear_selected_cells()
				# basically same as home, but jump one row down.
				add.x = Global.get_home()
				add.y = 1
				selection.clear()
			
			KEY_SPACE, 33554464:
				# Shift+Space happens sometimes, when naturally writing 
				# and should most likely do the same then Space.
				if selection.are_cells_selected():
					selection.clear_selected_cells()
				Global.push_cells()
				add.x = 1
				selection.clear()
			
			KEY_DELETE:
				if selection.are_cells_selected():
					selection.clear_selected_cells()
				else:
					Global.clear_cell()
					Global.pull_cells()
				selection.clear()
			
			KEY_BACKSPACE:
				if selection.are_cells_selected():
					selection.clear_selected_cells()
				else:
					Global.clear_left_cell()
					Global.pull_cells()
					add.x = -1
				selection.clear()
			
			KEY_HOME:
				add.x = Global.get_home()
				selection.clear()
			
			KEY_END:
				add.x = Global.get_end()
				selection.clear()
			
			268435539: # Control+S
				print('saving')
				Global.save_matrix()
				emit_signal("export_tilemap")
			
			_:
				# Every other key
				var ch = OS.get_scancode_string(scm)
				var last_input = char(event.unicode)
				if last_input == '':
					# most likely some unhandled function key.
					printt("function key pressed:", ch, scm)
				elif last_input != " ":
					# Safety check if input is not space. There are cases like
					# Shift+Space and Control+Space, that would cause this.
					if selection.are_cells_selected():
						selection.clear_selected_cells()
					printt(last_input, scm, ch)
					Global.push_cells()
					Global.set_cell_character(last_input)
					add.x = 1
					selection.clear()

		change_cell(add)


func init_custom_mouse_cursor(zoom_level: float = 1.0):
	"""
	Change cursor to something more suitable than the standard arrow.
	Needs to be called every time, the camera zoom changes.
	"""
	var tex = ImageTexture.new()
	var img = Image.new()
	var width = round(Global.cell_size.x / zoom_level)
	var height = round(Global.cell_size.y / zoom_level)
	img.create(width, height, true, Image.FORMAT_RGBA8)
	var col = Global.mouse_color
	# set the transparancy of the cursor
	col.a = 0.6
	img.fill(col)
	tex.create_from_image(img)
	# TODO: image's size must be lower than 256x256.
	Input.set_custom_mouse_cursor(tex, 0, Vector2(width / 2, height / 2))


func _init_cursor():
	cursor = Polygon2D.new()
	# set cursor behind the text
	cursor.z_index = -1
	cursor.polygon = PoolVector2Array([Vector2(0,0),
								Vector2(Global.cell_size.x, 0),
								Global.cell_size,
								Vector2(0, Global.cell_size.y)])
	cursor.color = Global.cursor_color
	add_child(cursor)
	_update_cursor()


func _update_cursor():
	cursor.global_position = Global.cell_size * Global.cell


func change_cell(add: Vector2):
	Global.cell += add
	_update_cursor()
	
