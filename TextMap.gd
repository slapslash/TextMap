extends Node2D

onready var saveas = $UI/SaveAs
onready var camera = $Camera

signal save_project
signal switch_layer(to_layer_name)


func _ready():
	emit_signal("switch_layer", Global.LAYER_TEXT)


func _unhandled_key_input(event):
	if event.pressed:
		var scm = event.get_scancode_with_modifiers()
		match scm:
			16777244: # F1
				Settings.cell_size = Settings.cell_size_font
				init_custom_mouse_cursor()
				emit_signal("switch_layer", Global.LAYER_TEXT)
				
			16777245: # F2
				Settings.cell_size = Settings.cell_size_terrain
				init_custom_mouse_cursor()
				emit_signal("switch_layer", Global.LAYER_TERRAIN)
			
			16777246: # F3
				pass

			16777247: # F4
				pass
			
			268435539, 134217811: # Control+S, Cmd+S
				if Global.project_name == "":
					Input.set_custom_mouse_cursor(null)
					saveas.show()
					# wait until dialog is closed
					yield(saveas, "hide")
					init_custom_mouse_cursor()
				
				Global.saves()
				Settings.saves()
				emit_signal("save_project")
		

func init_custom_mouse_cursor():
	"""
	Change cursor to something more suitable than the standard arrow.
	Needs to be called every time, the camera zoom changes.
	"""
	var zoom_level = 1.0
	# camera might not be initialized yet.
	if camera:
		zoom_level = camera.zoom.x
	var tex = ImageTexture.new()
	var img = Image.new()
	var width = round(Settings.cell_size.x / zoom_level)
	var height = round(Settings.cell_size.y / zoom_level)
	img.create(width, height, true, Image.FORMAT_RGBA8)
	var col = Settings.mouse_color
	# set the transparancy of the cursor
	col.a = 0.6
	img.fill(col)
	tex.create_from_image(img)
	Input.set_custom_mouse_cursor(tex, 0, Vector2(width / 2, height / 2))


func _on_Camera_zoom_changed():
	init_custom_mouse_cursor()
