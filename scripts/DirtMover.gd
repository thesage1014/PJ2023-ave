class_name DirtMover extends MeshInstance3D

var last_input_position = Vector3.ZERO

func _physics_process(delta):
	if Singleton.player.gear == Singleton.player.DIRTMOVER:
		global_position = last_input_position


func _on_static_body_3d_input_event(camera, event, position, normal, shape_idx):
	last_input_position = position
	if event is InputEventMouseButton:
		pass
