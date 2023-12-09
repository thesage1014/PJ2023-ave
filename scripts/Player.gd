class_name Player extends CharacterBody3D
enum {GRAPPLER,DIRTMOVER,SAPPHIRE}
@export var SPEED = 50.0
@export var JUMP_VELOCITY = 30
@export var fly_amount = 0 # 1 means fully flying
@export var drag = .975
@export var dirtMover:DirtMover
@export var light:Light3D
@export var mouth:Node3D
@export var mouseHelper:Area3D
@export var mouse_max_distance:float = 14
@export var gear_pointer_sprites:Array[CompressedTexture2D]
@export var attack_strength:float = 1
@export var multi_jumps = 1

var gravity = 40
var grapplerScene = preload("res://scenes/Grappler.tscn")
var clickCharge = 0.0
var _active_grappler:RigidBody3D
var grappler_grappled = false
var gear:set = set_gear, get = get_gear
var _gear = GRAPPLER
var light_radius = 25.0
var health = 10.0
var max_health = 10.0
var recent_jumps = 0
var invincible:set=_set_invincible,get=_get_invincible
var _invincible = false
var invince_timer = 0.0
var _shoot_grappler = false
var _mouse_delta = Vector2(0,0)

func _enter_tree():
	Singleton.player = self
	
func _ready():
	gear = GRAPPLER

func _process(delta):
	mouseHelper.rotation.z = Vector2(mouseHelper.position.x,mouseHelper.position.y).angle()
	if invincible:
		$Mesh.visible = int(Time.get_ticks_msec()/50)%2
	else:
		$Mesh.visible = true

func _physics_process(delta):
	if _mouse_delta != Vector2.ZERO:
		mouseHelper.global_position += Vector3(_mouse_delta.x,-_mouse_delta.y,0)*.1
		var mouseXY = Vector2(mouseHelper.position.x,mouseHelper.position.y)
		if mouseXY.length() > mouse_max_distance:
			var normXY = mouseXY.normalized()
			mouseHelper.position.x = normXY.x * mouse_max_distance
			mouseHelper.position.y = normXY.y * mouse_max_distance
		_mouse_delta = Vector2.ZERO
	if Input.is_action_pressed("left_mouse"):
		if gear == GRAPPLER:
			if grappler_grappled:
				var dir = Vec.xy0(_active_grappler.global_position - global_position).normalized()
				velocity += dir * (Singleton.grapple_level*.25+1.0)
			elif !_active_grappler:
				$RopeMesh.visible = true
				if $RopeMesh.mesh.top_radius < 1.8:
					$RopeMesh.mesh.top_radius += delta*.7
					clickCharge = max(.5,clickCharge + delta*(1+Singleton.grapple_level*.1))
		if gear == SAPPHIRE:
			Singleton.camera_offset += Vector2(mouseHelper.position.x, mouseHelper.position.y) * (Singleton.sapphire_level+1) * .03
	
	
	$Mesh.scale = Vector3(sign(mouseHelper.position.x+.00001),1,1)
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
	
	if _shoot_grappler:
		shoot_grappler()
		_shoot_grappler = false
	
	if Input.is_action_just_pressed("1"):
		gear = GRAPPLER
	if Input.is_action_just_pressed("2"):
		gear = DIRTMOVER
	if Input.is_action_just_pressed("3"):
		gear = SAPPHIRE
	invince_timer -= delta
	if health <= 0:
		get_parent().rebuild_world()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var em = event as InputEventMouseMotion
		
		_mouse_delta += em.relative
	elif event is InputEventMouseButton:
		var me = event as InputEventMouseButton
		if me.button_index == MOUSE_BUTTON_RIGHT:
			if me.pressed:
				ungrapple()
			else:
				pass
		if me.button_index == MOUSE_BUTTON_LEFT:
			if me.pressed:
				pass
			else:
				Singleton.camera_offset = Vector2.ZERO
				if gear == GRAPPLER and !_active_grappler:
					_shoot_grappler = true

func shoot_grappler():
	$RopeMesh.visible = false
	$RopeMesh.mesh.top_radius = .5
	var newGrappler = grapplerScene.instantiate() as RigidBody3D
	get_parent().add_child(newGrappler)
	newGrappler.global_position = mouth.global_position
	var dir = Vec.xy0(mouseHelper.position)
	newGrappler.apply_central_impulse(dir*clickCharge*get_grapple_power() + velocity)
	clickCharge = 0
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
	mouseHelper.get_node("Mesh").mesh.material.albedo_texture = gear_pointer_sprites[value]
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
		Singleton.grapple_level += 1
	if powerup.type == powerup.powerup_type.POT:
		health = minf(max_health,health + 5.0)
	if powerup.type == powerup.powerup_type.LANTERN:
		light_radius += 5
		light.omni_range = light_radius
	if powerup.type == powerup.powerup_type.MAXHEART:
		Singleton.maxhearts_level += 1
		max_health = 10+5*Singleton.maxhearts_level
	if powerup.type == powerup.powerup_type.SHOVEL:
		Singleton.shovel_level += 1
	if powerup.type == powerup.powerup_type.BOOTS:
		multi_jumps += 1
	powerup.queue_free()

func respawn():
	health = max_health
	invince_timer = 2.0
	global_position = Vector3(64,64,0)

func on_enemy_hit(enemy:Enemy):
	if !invincible:
		health -= enemy.attackStrength
		invince_timer = 1

func exit():
	(get_parent() as GameWorld).rebuild_world()



func input_plane_event(camera, event, position, normal, shape_idx):
	pass
	

func _set_invincible(value):
	_invincible = value
func _get_invincible():
	return _invincible or invince_timer > 0
func get_grapple_power():
	return 1.0 + Singleton.grapple_level*.2
