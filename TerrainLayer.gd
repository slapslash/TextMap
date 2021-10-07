extends TileMap

export var layer_name: String = Global.LAYER_TERRAIN


func _ready():
	pass # Replace with function body.




func _on_TextMap_switch_layer(to_layer_name):
	if to_layer_name == layer_name:
		set_process_unhandled_input(true)
	else:
		set_process_unhandled_input(false)

