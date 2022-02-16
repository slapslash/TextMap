extends FileDialog


func _ready():
	var _e = connect("file_selected", self, "_on_file_selected")


func show():
	popup_centered_ratio(0.75)


func _on_file_selected(path):
	# current dir is missing drive by now.
	Global.project_directory = path.trim_suffix(current_file)
	Global.project_name = current_file.trim_suffix(".tscn")
