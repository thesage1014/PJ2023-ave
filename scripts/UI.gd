class_name UI extends Control
@export var player:Player
@export var hp:ProgressBar
@export var hpText:Label
@export var buttons:GridContainer
var last_escape_press = 0.0

func _ready():
	for _child:ItemButton in buttons.get_children():
		_child.connect("gearSelected", on_gear_selected)

func _process(delta):
	hp.max_value = player.max_health
	hp.value = player.health
	hpText.text = "HP: " + str(player.health) + "/" + str(player.max_health)
	if Time.get_ticks_msec()-last_escape_press > 5000:
		$Popup.visible = false
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and get_window().has_focus():
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_pressed("ui_cancel"):
		$Popup.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		last_escape_press = Time.get_ticks_msec()
	if Input.is_action_pressed("ui_cancel") and Time.get_ticks_msec()-last_escape_press > 500:
		get_tree().quit(0)

func on_gear_selected(gear:String):
	if gear == "GRAPPLER":
		print(gear)
		player.gear = player.GRAPPLER
	if gear == "DIRTMOVER":
		print(gear)
		player.gear = player.DIRTMOVER
	if gear == "SAPPHIRE":
		print(gear)
		player.gear = player.SAPPHIRE
