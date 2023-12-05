class_name GameWorld extends Node3D

@onready var mapBuilder:MapBuilder = $MapBuilder

func rebuild_world():
	mapBuilder.rebuild_world()
	Singleton.player.respawn()
