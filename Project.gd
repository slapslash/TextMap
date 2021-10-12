extends Node2D

"""
Handle Projects.
Children need to be TileMaps.
If Project file exists, it will be loaded and the TileMaps will get filled
by its content.
The number of children TileMaps, their type (text/terrain) and the type
order need to match.
"""

func _ready():
	# wait for Font2Tiles to be ready.
	yield(get_tree().create_timer(0.3), "timeout")
	if not load_project(Global.project_path):
		print("Project not found, loading default project.")
		assert(load_project(Global.default_project_path) == true)


func load_project(path: String) -> bool:
	var dir = Directory.new()
	if not dir.file_exists(path): return false

	var project: Node2D = load(path).instance()
	assert(project.get_child_count() == self.get_child_count(),
	"Number of child TileMaps in project need to match.")

	for i in project.get_child_count():
		var ext_map: TileMap = project.get_child(i)
		var int_map: TileMap = get_child(i)

		for cel in ext_map.get_used_cells():
			int_map.set_cell(cel.x, cel.y, ext_map.get_cellv(cel))
	return true

func save_project():
	var project = Node2D.new()
	project.name = Global.project_name
	for layer in get_children():
		var map: TileMap = TileMap.new()
		map.cell_size = Global.cell_size
		map.tile_set = layer.tile_set
		map.name = layer.name

		for cel in layer.get_used_cells():
			map.set_cell(cel.x, cel.y, layer.get_cellv(cel))

		project.add_child(map)
		map.owner = project

	var scene = PackedScene.new()
	assert(scene.pack(project) == OK)
	assert(ResourceSaver.save(Global.project_path, scene) == OK)


func _on_TextMap_save_project():
	save_project()
