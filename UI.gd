extends CanvasLayer


onready var cursor_loc_label = $Top/CursorLocation


func _on_Inputs_cursor_pos_changed():
	cursor_loc_label.text = str(Global.cell)
