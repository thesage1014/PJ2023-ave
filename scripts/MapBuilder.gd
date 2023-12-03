extends Node3D
@export var noiseViewport:SubViewport
@export var gridMap:GridMap
var lineScene = preload("res://scenes/line_2d.tscn")
var blobScene = preload("res://scenes/blob.tscn")
var mapSize = Vector2i(512,512)
var _generated = false
var _last_generated_time = 0
func _enter_tree():
	load("res://graphics/noisebase.tres").seed = randi()

func _ready():
	_place_lines()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		gridMap.clear()
		_place_lines()
		load("res://graphics/noisebase.tres").seed = randi()		
		_generated = false
	elif Time.get_ticks_msec()-_last_generated_time > 2.0 and !_generated:
		await RenderingServer.frame_post_draw
		_generated = true
		var noiseTex = noiseViewport.get_texture()
		var image = noiseTex.get_image()
		#image.draw
		for x in range(mapSize.x):
			for y in range(mapSize.y):
				var pos = Vector2i(x,y)
				var sample = image.get_pixelv(pos).r
				gridMap.set_cell_item(Vector3i(x,y,0),clamp(sample*6-2.5,-1,1))
				
			

func _place_lines():
	for _child in noiseViewport.get_children():
		if _child is Line2D or _child is TextureRect:
			_child.queue_free()
	var numDests = 24
	var points:Array[Vector2] = []
	var margin = 64
	points.append(Vector2(margin,margin))
	for i in range(numDests):
		var randPoint = Vector2(randf_range(0,1),randf_range(0,1))
		points.append(Vector2(margin+randPoint.x*(mapSize.x-margin*2),
				margin+randPoint.y*(mapSize.y-margin*2)))
	points.append(Vector2(mapSize.x-margin,mapSize.y-margin))
	var curve:Curve2D = Curve2D.new()
	curve.add_point(points[0])
	for i in range(1,points.size()):
		var point = points[i]
#		var inout = (curve.get_point_position(i-1)+point)*.5*.1
		var inout = (curve.get_point_position(i-1)-point)*-.4
		curve.add_point(point,-inout,inout)
	var linePoints:Array[Vector2] = []
	#var lineRes = float(numDests+2.0)*10.0
	#for i in range(lineRes):
	#	linePoints.append(curve.samplef(i/lineRes*curve.point_count))
	#var delaunay = Geometry2D.triangulate_delaunay(PackedVector2Array(points))
	var mst = prim(points)
	#for j in range(delaunay.size()/3):
		#for i in range (3):
			#linePoints.append(points[delaunay[i+j*3]])
		#linePoints.append(points[delaunay[j*3]])
	for j in range(mst.size()/2):
		linePoints = []
		for i in range (2):
			linePoints.append(points[mst[i+j*2]])
		#linePoints.append(points[mst[j*2]])
		var newBlob = blobScene.instantiate() as TextureRect
		noiseViewport.add_child(newBlob)
		newBlob.position = linePoints[0]
		var newLine = lineScene.instantiate() as Line2D
		noiseViewport.add_child(newLine)
		newLine.points = PackedVector2Array(linePoints)

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
