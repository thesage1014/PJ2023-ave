class_name Enemy extends RigidBody3D
@export var health = 1
@export var roll_strength = .02
var target:Player
var jumpCooldown = 2.5
var jumpTimer = 0.0
var jumpStrength = 15.0
var attackStrength = 1.0

func _ready():
	var level = Singleton.enemy_level
	jumpStrength = 13 + level*4
	attackStrength = level*1.25
	jumpCooldown = 2.5 - level*.1
	roll_strength = .02 + level*.02

func _physics_process(delta):
	if target:
		var posDiff = target.global_position - global_position
		apply_central_impulse((posDiff+Vector3(0,5,0)).normalized()*roll_strength)
		if jumpTimer > jumpCooldown:
			
			if posDiff.length() > 25:
				target = null
			else:
				apply_central_impulse((posDiff+Vector3(0,5,0)).normalized()*jumpStrength)
				jumpTimer = 0
	jumpTimer += delta

func _process(delta):
	if !target:
		$OmniLight3D.light_cull_mask = 0
		$OmniLight3D.layers = 0

func hit_by_player(damage):
	health -= damage
	if health <= 0:
		queue_free()
func _on_area_3d_body_entered(body):
	if body is Player:
		$OmniLight3D.light_cull_mask = 1
		$OmniLight3D.layers = 1
		target = body

func _on_body_entered(body):
	if body is Player:
		body.on_enemy_hit(self)
