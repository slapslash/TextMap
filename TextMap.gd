extends Node2D

signal save_project
signal switch_layer(to_layer_name)


func _ready():
	emit_signal("switch_layer", Global.LAYER_TEXT)


func _unhandled_key_input(event):
	if event.pressed:
		var scm = event.get_scancode_with_modifiers()
		match scm:
			16777244: # F1
				emit_signal("switch_layer", Global.LAYER_TEXT)
				
			16777245: # F2
				emit_signal("switch_layer", Global.LAYER_TERRAIN)
			
			16777246: # F3
				pass

			16777247: # F4
				pass
#				# autosave, to ensure exported html5 project will work
#				# (scene at user-path needs to be written first).
#				emit_signal("save_project")
#
#				var map = load(Global.project_path).instance()
#				var player = load("res://Player.tscn").instance()
#
#				player.global_position = Vector2(-106, -76) * Global.cell_size
#				map.add_child(player)
#				player.owner = map
#
#				# hide the mouse in the game window.
#				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
#
#				var scene = PackedScene.new()
#				assert(scene.pack(map) == OK)
#				assert(get_tree().change_scene_to(scene) == OK)
			
			268435539: # Control+S
				print('saving project')
				emit_signal("save_project")


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


func _on_Camera_zoom_changed(current_zoom_level):
	init_custom_mouse_cursor(current_zoom_level)