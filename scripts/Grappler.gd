extends RigidBody3D
var grappled = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var pp = Singleton.player.global_position
	var diff = global_position - pp
	$RopeMesh.scale.y = diff.length()
	$RopeMesh.rotation.z = Vector2(-diff.x,-diff.y).angle()+PI*.5
	$RopeMesh.global_position = (pp+global_position)*.5
	if diff.length() > Singleton.max_grapple_dist-10:
		if diff.length() > Singleton.max_grapple_dist:
			Singleton.player.ungrapple()
		else:
			linear_velocity *= .95

func _on_body_entered(body):
	grappled = true
	print(body)
	collision_layer = 0
	collision_mask = 0
	freeze = true
	Singleton.player.on_grappler_grappled()
