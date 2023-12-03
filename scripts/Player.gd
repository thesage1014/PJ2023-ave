extends CharacterBody3D


@export var SPEED = 50.0
@export var JUMP_VELOCITY = 30
@export var fly_amount = 0 # 1 means fully flying
@export var drag = .98
var gravity = 30


func _physics_process(delta):
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

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if move_and_slide():
		var kc = get_last_slide_collision()
		if kc.get_collider(0) is StaticBody3D:
			print(kc.get_collider(0))
			velocity = Vector3.ZERO
