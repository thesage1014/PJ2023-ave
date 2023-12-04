extends Node

static var instance:Singleton
static var player:Player
static var max_grapple_dist = 30

func _enter_tree():
	if !instance:
		instance = self
	else:
		queue_free()
