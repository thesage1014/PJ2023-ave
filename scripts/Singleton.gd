extends Node

static var instance:Singleton
static var player:Player
static var gameWorld:GameWorld
static var lantern_level = 0
static var grapple_level = 0
static var sapphire_level = 0
static var maxhearts_level = 0
static var shovel_level = 0
static var enemy_level = 1
static var camera_offset = Vector2.ZERO

func _enter_tree():
	if !instance:
		instance = self
	else:
		queue_free()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	pass
