extends TileMap

export var layer_id: int = 1


func _ready():
	pass # Replace with function body.




func _on_TextMap_switch_layer(to_layer_id):
	if to_layer_id == layer_id:
		set_process_unhandled_input(true)
	else:
		set_process_unhandled_input(false)

