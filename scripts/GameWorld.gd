class_name GameWorld extends Node3D

@onready var mapBuilder:MapBuilder = $MapBuilder

func _enter_tree():
	Singleton.gameWorld = self

func rebuild_world():
	mapBuilder.rebuild_world()
	Singleton.player.respawn()
