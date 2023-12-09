class_name DirtMover extends MeshInstance3D
@onready var gridMap:GridMap = get_parent().find_child("GridMap")
@export var helperGM:GridMap
var reticle:Area3D
var last_input_position = Vector3.ZERO
var moverSize = 2

func _ready():
	reticle = Singleton.instance.player.mouseHelper

func _physics_process(delta):
	moverSize = 2+Singleton.shovel_level
	if Singleton.player.gear == Singleton.player.DIRTMOVER:
		global_position = Vector3(round(last_input_position.x+.5),round(last_input_position.y+.5),0)
	


func _unhandled_input(event):
	#var me = event as InputEventMouseMotion
	var pos = reticle.global_position
	last_input_position = pos
	if Singleton.player.gear == Singleton.player.DIRTMOVER:
		if event is InputEventMouseButton:
			var mevent = event as InputEventMouseButton
			if mevent.pressed and mevent.button_index == MOUSE_BUTTON_LEFT:
				helperGM.position = Vector3(-moverSize*.5,-moverSize*.5,-1)
				for i in range(moverSize):
					for j in range(moverSize):
						var ipos = Vector3i(pos-Vector3(0,0,0))+Vector3i(i,j,-1)
						var sample = gridMap.get_cell_item(ipos)
						if sample >= 3:
							continue
						helperGM.set_cell_item(Vector3i(i,j,0),sample)
						gridMap.set_cell_item(ipos,0)
			if !mevent.pressed and mevent.button_index == MOUSE_BUTTON_LEFT:
				helperGM.position = Vector3(-moverSize*.5,-moverSize*.5,-1)
				for i in range(moverSize):
					for j in range(moverSize):
						var ipos = Vector3i(pos-Vector3(0,0,0))+Vector3i(i,j,-1)
						var sample = helperGM.get_cell_item(Vector3i(i,j,0))
						var target_item = gridMap.get_cell_item(ipos)
						if target_item != 3 and sample > 0:
							gridMap.set_cell_item(ipos,min(sample+target_item,3))
				helperGM.clear()

func clear():
	helperGM.clear()
	(mesh as SphereMesh).radius = moverSize*.5
	(mesh as SphereMesh).height = moverSize
