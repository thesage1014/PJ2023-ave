class_name Exit extends Area3D

func _on_body_entered(body):
	if body is Player:
		Singleton.player.exit()
