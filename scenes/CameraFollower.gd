extends Camera3D
@export var target:Node3D

func _ready():
	pass  


func _physics_process(delta):
	if Input.is_action_just_pressed("scroll_down"):
		position.z *= 1.1
	if Input.is_action_just_pressed("scroll_up"):
		position.z *= .9090909
	
	if target:
		position.x = target.position.x
		position.y = target.position.y
