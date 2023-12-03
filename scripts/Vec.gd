class_name Vec extends Object

static func xx(input:Vector3): return Vector2(input.x,input.x)
static func xy(input:Vector3): return Vector2(input.x,input.y)
static func xz(input:Vector3): return Vector2(input.x,input.z)
static func yx(input:Vector3): return Vector2(input.y,input.x)
static func yy(input:Vector3): return Vector2(input.y,input.y)
static func yz(input:Vector3): return Vector2(input.y,input.z)
static func zx(input:Vector3): return Vector2(input.z,input.x)
static func zy(input:Vector3): return Vector2(input.z,input.y)
static func zz(input:Vector3): return Vector2(input.z,input.z)

static func xx0(input:Vector3): return Vector3(input.x,input.x,0)
static func xy0(input:Vector3): return Vector3(input.x,input.y,0)
static func xz0(input:Vector3): return Vector3(input.x,input.z,0)
static func yx0(input:Vector3): return Vector3(input.y,input.x,0)
static func yy0(input:Vector3): return Vector3(input.y,input.y,0)
static func yz0(input:Vector3): return Vector3(input.y,input.z,0)
static func zx0(input:Vector3): return Vector3(input.z,input.x,0)
static func zy0(input:Vector3): return Vector3(input.z,input.y,0)
static func zz0(input:Vector3): return Vector3(input.z,input.z,0)

static func boundingBoxCenter(vecs:Array[Vector3]):
	var minimum = Vector3.ONE*-100000000000000000000.0
	var maximum = Vector3.ONE*100000000000000000000.0
	for vec in vecs:
		if minimum.x < vec.x: minimum.x = vec.x
		if minimum.y < vec.y: minimum.y = vec.y
		if minimum.z < vec.z: minimum.z = vec.z
		if maximum.x > vec.x: maximum.x = vec.x
		if maximum.y > vec.y: maximum.y = vec.y
		if maximum.z > vec.z: maximum.z = vec.z
	var size = maximum - minimum
	return minimum + (size * .5)

static func shortest_index(vecs:Array[Vector3]):
	var shortest = Vector3.ZERO
	var shortest_ind = 0
	for i in range(vecs.size()):
		if vecs[i].length() < shortest:
			shortest = vecs[i].length()
			shortest_ind = i
	
	return shortest_ind
