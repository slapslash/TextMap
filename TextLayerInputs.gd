extends Node2D

onready var selection = $Selection
onready var cursor = $"/root/TextMap/Cursor"
onready var parent_tilemap = $"/root/TextMap/Project/TextLayer"



func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				var mpos = Global.get_cell_from_mouse_pos()
				selection.on_left_mouse_button_pressed(mpos)
			elif not event.pressed:
				selection.on_left_mouse_button_released()
	
	elif event is InputEventMouseMotion:
		selection.on_mouse_motion()

	elif event is InputEventKey and not event.pressed:
		var scm = event.get_scancode_with_modifiers()
		match scm:
			16777238, 16777239: # Control, Cmd
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
				add.x = parent_tilemap.get_end()
				selection.on_selection_by_key(add.x, 0)

			50331661: # Shift+Home
				add.x = parent_tilemap.get_home()
				selection.on_selection_by_key(add.x, 0)

			285212689, 150994961: # Control+Right, Cmd+Right
				selection.on_drag_by_key(1, 0)

			285212687, 150994959: # Control+Left, Cmd+Left
				selection.on_drag_by_key(-1, 0)

			285212688, 150994960: # Control+Up, Cmd+Up
				selection.on_drag_by_key(0, -1)

			285212690, 150994962: # Control+Down, Cmd+Down
				selection.on_drag_by_key(0, 1)

			134217771: # Cmd+Plus
				# already used in camera, would print a + if not captured here.
				pass
				
			134217773: # Cmd+Minus
				# already used in camera, would print a - if not captured here.
				pass

			KEY_ESCAPE:
				selection.clear()

			KEY_ENTER, KEY_KP_ENTER:
				if selection.are_cells_selected():
					selection.clear_selected_cells()
				# basically same as home, but jump one row down.
				add.x = parent_tilemap.get_home()
				add.y = 1
				selection.clear()
			
			KEY_SPACE, 33554464:
				# Shift+Space happens sometimes, when naturally writing 
				# and should most likely do the same then Space.
				if selection.are_cells_selected():
					selection.clear_selected_cells()
				parent_tilemap.push_cells()
				add.x = 1
				selection.clear()
			
			KEY_DELETE:
				if selection.are_cells_selected():
					selection.clear_selected_cells()
				else:
					parent_tilemap.clear_cell()
					parent_tilemap.pull_cells()
				selection.clear()
			
			KEY_BACKSPACE:
				if selection.are_cells_selected():
					selection.clear_selected_cells()
				else:
					parent_tilemap.clear_left_cell()
					parent_tilemap.pull_cells()
					add.x = -1
				selection.clear()
			
			KEY_HOME:
				add.x = parent_tilemap.get_home()
				selection.clear()
			
			KEY_END:
				add.x = parent_tilemap.get_end()
				selection.clear()

			_:
				# Every other key
				var _ch = OS.get_scancode_string(scm)
				var last_input = char(event.unicode)
				if last_input == '':
					pass
					# most likely some unhandled function key.
#					printt("function key pressed:", ch, scm)
				elif last_input != " ":
					# Safety check if input is not space. There are cases like
					# Shift+Space and Control+Space, that would cause this.
					if selection.are_cells_selected():
						selection.clear_selected_cells()
#					printt(last_input, scm, _ch)
					parent_tilemap.push_cells()
					parent_tilemap.set_cell_character(last_input)
					add.x = 1
					selection.clear()

		change_cell(add)


func change_cell(add: Vector2):
	Settings.cell += add
	cursor.update_position()
