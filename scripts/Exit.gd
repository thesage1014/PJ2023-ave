class_name Exit extends Area3D
var target_map_index

func _on_body_entered(body):
	if body is Player:
		Singleton.player.exit(target_map_index)
