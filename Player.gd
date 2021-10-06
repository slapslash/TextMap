extends KinematicBody2D

onready var anim = $AnimationPlayer

export (int) var speed = 100

var velocity = Vector2()


func _ready():
	# make the parent (TileMap) only visible by light.
	var mat = CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_LIGHT_ONLY
	get_parent().material = mat

	VisualServer.set_default_clear_color(Color.black)


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
