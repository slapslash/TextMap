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
	load_project()


func load_project():
	var path = Global.get_project_path()
	var dir = Directory.new()
	if not dir.file_exists(path): return

	var project: Node2D = load(path).instance()
	assert(project.get_child_count() == self.get_child_count(),
	"Number of child TileMaps in project need to match.")

	for i in project.get_child_count():
		var ext_map: TileMap = project.get_child(i)
		var int_map: TileMap = get_child(i)

		for cel in ext_map.get_used_cells():
			int_map.set_cell(cel.x, cel.y, ext_map.get_cellv(cel))

func save_project():
	if Global.project_name == "": return
	var project = Node2D.new()
	project.name = Global.project_name
	for layer_name in ["TextLayer", "TerrainLayer"]:
		var layer = get_node(layer_name)
		var map: TileMap = TileMap.new()
		if layer_name == "TextLayer":
			map.cell_size = Settings.cell_size_text
		elif layer_name == "TerrainLayer":
			map.cell_size = Settings.cell_size_terrain
		map.tile_set = layer.tile_set
		map.name = layer_name

		for cel in layer.get_used_cells():
			map.set_cell(cel.x, cel.y, layer.get_cellv(cel))

		project.add_child(map)
		map.owner = project

	var scene = PackedScene.new()
	assert(scene.pack(project) == OK)
	assert(ResourceSaver.save(Global.get_project_path(), scene) == OK)


func _on_TextMap_save_project():
	save_project()
