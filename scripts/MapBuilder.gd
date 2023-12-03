extends Node3D
@export var noiseViewport:SubViewport
@export var gridMap:GridMap
var lineScene = preload("res://scenes/line_2d.tscn")
var mapSize = Vector2i(512,512)
var _generated = false

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
	if Time.get_ticks_msec() > .1 and !_generated:
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
		if _child is Line2D:
			_child.queue_free()
	var numDests = 3
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
	var lineRes = float(numDests+2.0)*10.0
	for i in range(lineRes):
		linePoints.append(curve.samplef(i/lineRes*curve.point_count))
	var newLine = lineScene.instantiate() as Line2D
	noiseViewport.add_child(newLine)
	newLine.points = PackedVector2Array(linePoints)
