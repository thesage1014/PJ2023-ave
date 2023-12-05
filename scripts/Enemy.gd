class_name Enemy extends RigidBody3D
var target:Player
var jumpCooldown = 2.0
var jumpTimer = 0.0
var jumpStrength = 15.0
var attackStrength = 1.0

func _physics_process(delta):
	if target and jumpTimer > jumpCooldown:
		var posDiff = target.global_position - global_position
		if posDiff.length() > 25:
			target = null
		else:
			apply_central_impulse((posDiff+Vector3(0,5,0)).normalized()*jumpStrength)
			jumpTimer = 0
	jumpTimer += delta

func _on_area_3d_body_entered(body):
	if body is Player:
		target = body


func _on_body_entered(body):
	if body is Player:
		body.on_enemy_hit(self)
