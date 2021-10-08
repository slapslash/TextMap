extends KinematicBody2D

const layer_name: String = Global.LAYER_GAME

onready var anim = $AnimationPlayer
onready var _tile_map_material: Material

export (int) var speed = 100

var velocity = Vector2()

var _default_clear: Color = Color(0.3, 0.3, 0.3, 1.0)


func _ready():
	_tile_map_material = _get_material()


func _get_material() -> Material:
	# make material to mask by light
	var mat = CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_LIGHT_ONLY
	return mat


func get_input():
	velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	velocity = velocity.normalized() * speed

	if velocity != Vector2.ZERO:
		anim.play("Walk")
	elif anim.is_playing():
		anim.seek(0, true)
		anim.stop()


func _physics_process(_delta):
	get_input()
	velocity = move_and_slide(velocity)


func _on_TextMap_switch_layer(to_layer_name):
	if to_layer_name == layer_name:
		show()
		get_parent().get_node("Grid").hide()
		for child in get_parent().get_node("Project").get_children():
			child.material = _tile_map_material
		$Camera2D.current = true
		global_position = Global.cell * Global.cell_size + Global.cell_size * 0.5
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		VisualServer.set_default_clear_color(Color.black)
		set_physics_process(true)
	else:
		hide()
		get_parent().get_node("Grid").show()
		for child in get_parent().get_node("Project").get_children():
			child.material = null
		$Camera2D.current = false
		get_parent().get_node("Camera").current = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		VisualServer.set_default_clear_color(_default_clear)
		set_physics_process(false)
