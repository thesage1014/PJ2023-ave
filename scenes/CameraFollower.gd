extends Camera3D
@export var target:Node3D
var _last_pos = Vector3.ZERO

func _ready():
	pass  


func _physics_process(delta):
	if Input.is_action_just_pressed("scroll_down"):
		position.z *= 1.1
	if Input.is_action_just_pressed("scroll_up"):
		position.z *= .9090909
	
	var offset = Singleton.camera_offset
	if target:
		position.x = lerp(_last_pos.x, target.position.x + offset.x,.05) 
		position.y = lerp(_last_pos.y, target.position.y + offset.y,.05)
	if offset != Vector2.ZERO:
		$SappPlayerMesh.visible = true
		$SappPlayerMesh.global_position = Vector3(global_position.x,global_position.y,1)
	else:
		$SappPlayerMesh.visible = false

	_last_pos = position
