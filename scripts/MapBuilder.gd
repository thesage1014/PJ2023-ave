class_name MapBuilder extends Node3D
enum types {CAVES1,TEMPLE}
@export var map_type:types = types.CAVES1
@export var noiseViewport:SubViewport
@export var gridMap:GridMap
@export var mapSize = Vector2i(256,160)
@export var drawThreshold = 0.0
@export var drawBiasMultiplier = 4.0
var lineScene = preload("res://scenes/line_2d.tscn")
var blobScene = preload("res://scenes/blob.tscn")
var powerupScene = preload("res://scenes/Powerup.tscn")
var enemyScene = preload("res://scenes/Enemy.tscn")
var exitScene = preload("res://scenes/Exit.tscn")
var _generated = false
var _last_generated_time = 0

func _enter_tree():
	load("res://graphics/noisebase.tres").seed = randi()

func _ready():
	($World/BACKGROUND.mesh as QuadMesh).size = Vector2(mapSize.x+50,mapSize.y+50)
	$World/BACKGROUND.global_position = Vector3(mapSize.x/2,mapSize.y/2,-2)
	$SubViewport/Control/centerOpener.position = Vector2(mapSize/2)
	$SubViewport/Control/centerOpener.scale = Vector2(mapSize/64)
	noiseViewport.size = mapSize
	(noiseViewport.get_node("Control/noise").texture.noise as FastNoiseLite).frequency = .01 * (max(mapSize.x,mapSize.y) / 512.0)
	_generate_image()

func _process(_delta):
	if Input.is_action_just_pressed("q"):
		rebuild_world()
	elif Time.get_ticks_msec()-_last_generated_time > 0.1 and !_generated:
		await RenderingServer.frame_post_draw
		_generated = true
		var noiseTex = noiseViewport.get_texture()
		var image = noiseTex.get_image()
		#image.draw
		for x in range(mapSize.x):
			for y in range(mapSize.y):
				var pos = Vector2i(x,y)
				var sample = image.get_pixelv(pos).r
				gridMap.set_cell_item(Vector3i(x,y,0),clamp(sample*drawBiasMultiplier-drawThreshold,-1,3))
				
			

func _generate_image():
	
	var numDests = pow((mapSize.x + mapSize.y)*.005,2)
	print("random nodes to visit: " + str(numDests as int))
	var points:Array[Vector2] = []
	var margin = 64
	
	if map_type == types.CAVES1:
		$SubViewport/Control/centerOpener.visible = false
		$SubViewport/Control/bridge.visible = false
		$World/templeLight.visible = false
		points.append(Vector2(margin,margin)) # start at bottom left
		points.append(Vector2(mapSize.x-margin,mapSize.y-margin)) # end at top right
		spawn_exit(Vector3(mapSize.x-margin,mapSize.y-margin,0))
	elif map_type == types.TEMPLE:
		$SubViewport/Control/centerOpener.visible = true
		$SubViewport/Control/bridge.visible = true
		$World/templeLight.visible = true
		points.append(Vector2(margin,margin)) # start at bottom left
	
	for i in range(numDests):
		var randPoint = Vector2(randf_range(0,1),randf_range(0,1))
		points.append(Vector2(margin+randPoint.x*(mapSize.x-margin*2),
				margin+randPoint.y*(mapSize.y-margin*2)))
	
	var linePoints:Array[Vector2] = []
	var mst = prim(points)
	draw_blob(Vector2(64,64))
	for j in range(mst.size()/2):
		linePoints = []
		for i in range (2):
			linePoints.append(points[mst[i+j*2]])
		draw_blob(linePoints[0])
		spawn_powerup(Vector3(linePoints[0].x,linePoints[0].y,0))
		spawn_enemy(Vector3(linePoints[0].x,linePoints[0].y,0))
		draw_line(linePoints)

func rebuild_world():
	Singleton.player.respawn()
	gridMap.clear()
	for _child in get_children():
		if _child is Powerup or _child is Enemy or _child is Exit:
			_child.queue_free()
	for _child in noiseViewport.get_children():
		if _child is Line2D or _child is TextureRect:
			_child.queue_free()
	_generate_image()
	load("res://graphics/noisebase.tres").seed = randi()
	_generated = false

func prim(points:Array[Vector2]):
	var neighbors = []
	for i in range(points.size()):
		neighbors.append([])
		for j in range(points.size()):
			if i != j:
				var vecDiff = (points[i] - points[j]).abs()
				var cost = vecDiff.x + vecDiff.y
				neighbors[i].append([cost,j])
	var visited = {}
	var minheap = [[0,0,0]] # Cost, point index, connecting from
	var segments:Array[int] = []
	while visited.size() < points.size():
		minheap.sort()
		var minh = minheap.pop_front()
		if !visited.has(str(minh[1])):
			visited[str(minh[1])] = 1
			segments.append(minh[1])
			segments.append(minh[2])
			for i in range(neighbors[minh[1]].size()):
				if !visited.has(str(neighbors[minh[1]][i])):
					var newHeapItem = neighbors[minh[1]][i]
					newHeapItem.append(minh[1])
					minheap.append(neighbors[minh[1]][i])
	segments.remove_at(0)
	segments.remove_at(0)
	return segments

func spawn_powerup(targetPos):
	var newPowerup = powerupScene.instantiate() as Powerup
	newPowerup.type = randi_range(0,Powerup.powerup_type.size()-1)
	add_child(newPowerup)
	newPowerup.position = targetPos

func spawn_exit(targetPos):
	var newExit = exitScene.instantiate() as Exit
	#newExit.type = randi_range(0,Powerup.powerup_type.size()-1)
	add_child(newExit)
	newExit.position = targetPos

func spawn_enemy(targetPos):
	var newEnemy = enemyScene.instantiate() as Enemy
	add_child(newEnemy)
	newEnemy.position = targetPos

func draw_line(points):
	var newLine = lineScene.instantiate() as Line2D
	noiseViewport.add_child(newLine)
	newLine.points = PackedVector2Array(points)

func draw_blob(targetPos:Vector2):
	var newBlob = blobScene.instantiate() as TextureRect
	noiseViewport.add_child(newBlob)
	newBlob.position = targetPos
