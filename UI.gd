extends CanvasLayer


onready var cursor_loc_label = $Top/CursorLocation
onready var current_layer_label = $Top/CurrentLayer



func _on_Inputs_cursor_pos_changed():
	cursor_loc_label.text = str(Global.cell)


func _on_TextMap_switch_layer(to_layer_id):
	current_layer_label.text = "Current Layer: " + str(to_layer_id)
