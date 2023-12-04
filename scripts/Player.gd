class_name Player extends CharacterBody3D
enum {GRAPPLER,DIRTMOVER}

@export var SPEED = 50.0
@export var JUMP_VELOCITY = 30
@export var fly_amount = 0 # 1 means fully flying
@export var drag = .975
@export var dirtMover:DirtMover
var gravity = 40
var grapplerScene = preload("res://scenes/Grappler.tscn")
var grappleCharge = 0.0
var _active_grappler:RigidBody3D
var grappler_grappled = false
var gear:set = set_gear, get = get_gear
var _gear = GRAPPLER
var light_radius = 25.0
var health = 10.0
var max_health = 10.0
var multi_jumps = 1
var recent_jumps = 0

func _enter_tree():
	Singleton.player = self

func _physics_process(delta):
	if Input.is_action_pressed("left_mouse"):
		if gear == GRAPPLER:
			if grappler_grappled:
				var dir = Vec.xy0(_active_grappler.global_position - global_position).normalized()
				velocity += dir
			elif !_active_grappler:
				$RopeMesh.visible = true
				if $RopeMesh.mesh.top_radius < 1.8:
					$RopeMesh.mesh.top_radius += delta*.7
					grappleCharge += delta
		elif gear == DIRTMOVER:
			pass
	var lr_control = 1
	if not is_on_floor():
		lr_control = .5
	# Add the gravity.

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	input_dir.y *= fly_amount
	var direction = (transform.basis * Vector3(input_dir.x, -input_dir.y, 0))
	
	velocity.x = move_toward(velocity.x, direction.x * SPEED, .95*lr_control)
	velocity.y = move_toward(velocity.y, direction.y * SPEED, fly_amount)
	velocity.x *= drag
	velocity.y *= drag

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		recent_jumps = 0
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or recent_jumps < multi_jumps):
		velocity.y = JUMP_VELOCITY
		recent_jumps += 1
	if move_and_slide():
		var kc = get_last_slide_collision()
		if kc.get_collider(0) is StaticBody3D:
			print(kc.get_collider(0))
			velocity = Vector3.ZERO
	
	if gear == GRAPPLER:
		if !_active_grappler and Input.is_action_just_released("left_mouse"):
			shoot_grappler()
		if Input.is_action_just_pressed("right_mouse"):
			ungrapple()
	if Input.is_action_just_pressed("1"):
		gear = GRAPPLER
	if Input.is_action_just_pressed("2"):
		gear = DIRTMOVER

func shoot_grappler():
	$RopeMesh.visible = false
	$RopeMesh.mesh.top_radius = .5
	var newGrappler = grapplerScene.instantiate() as RigidBody3D
	get_parent().add_child(newGrappler)
	newGrappler.global_position = global_position
	var dir = get_viewport().get_mouse_position() - get_viewport().size/2.0
	newGrappler.apply_central_impulse(Vector3(dir.x,-dir.y,0)*grappleCharge*.1 + velocity)
	grappleCharge = 0
	_active_grappler = newGrappler

func on_grappler_grappled():
	grappler_grappled = true

func ungrapple():
	grappler_grappled = false
	if _active_grappler:
		_active_grappler.queue_free()
		_active_grappler = null

func set_gear(value):
	_gear = value
	ungrapple()
	dirtMover.clear()
	if value == DIRTMOVER:
		dirtMover.visible = true
	else:
		dirtMover.visible = false
	
func get_gear():
	return _gear

func on_powerup_hit(powerup:Powerup):
	if powerup.type == powerup.powerup_type.ROPE:
		Singleton.max_grapple_dist += 6
	if powerup.type == powerup.powerup_type.POT:
		health = minf(max_health,health + 5.0)
	if powerup.type == powerup.powerup_type.LANTERN:
		light_radius += 5
		$Light.omni_range = light_radius
	if powerup.type == powerup.powerup_type.MAXHEART:
		max_health += 5
	if powerup.type == powerup.powerup_type.SHOVEL:
		dirtMover.moverSize += 1
	if powerup.type == powerup.powerup_type.BOOTS:
		multi_jumps += 1
	powerup.queue_free()
