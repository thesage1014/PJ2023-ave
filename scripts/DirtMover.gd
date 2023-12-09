class_name DirtMover extends MeshInstance3D
@onready var gridMap:GridMap = get_parent().find_child("GridMap")
@onready var helperGM:GridMap = $HelperGM
var last_input_position = Vector3.ZERO
var moverSize = 2
#func _ready():

func _physics_process(delta):
	if Singleton.player.gear == Singleton.player.DIRTMOVER:
		global_position = Vector3(round(last_input_position.x+.5),round(last_input_position.y+.5),0)


func _on_static_body_3d_input_event(camera, event, position, normal, shape_idx):
	last_input_position = position
	if Singleton.player.gear == Singleton.player.DIRTMOVER:
		if event is InputEventMouseButton:
			var mevent = event as InputEventMouseButton
			if mevent.pressed and mevent.button_index == MOUSE_BUTTON_LEFT:
				helperGM.position = Vector3(-moverSize*.5,-moverSize*.5,-1)
				for i in range(moverSize):
					for j in range(moverSize):
						var ipos = Vector3i(position-Vector3(.5,.5,0))+Vector3i(i,j,-1)
						var sample = gridMap.get_cell_item(ipos)
						if sample == 1:
							continue
						helperGM.set_cell_item(Vector3i(i,j,0),sample)
						gridMap.set_cell_item(ipos,-1)
			if !mevent.pressed and mevent.button_index == MOUSE_BUTTON_LEFT:
				helperGM.position = Vector3(-moverSize*.5,-moverSize*.5,-1)
				for i in range(moverSize):
					for j in range(moverSize):
						var ipos = Vector3i(position-Vector3(.5,.5,0))+Vector3i(i,j,-1)
						var sample = helperGM.get_cell_item(Vector3i(i,j,0))
						if gridMap.get_cell_item(ipos) != 1 and sample != -1:
							gridMap.set_cell_item(ipos,sample)
				helperGM.clear()

func clear():
	helperGM.clear()
	(mesh as SphereMesh).radius = moverSize*.5
	(mesh as SphereMesh).height = moverSize
