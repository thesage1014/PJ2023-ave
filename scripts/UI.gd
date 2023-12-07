class_name UI extends Control
@export var player:Player
@export var hp:ProgressBar
@export var hpText:Label
@export var buttons:GridContainer

func _ready():
	for _child:ItemButton in buttons.get_children():
		_child.connect("gearSelected", on_gear_selected)

func _process(delta):
	hp.max_value = player.max_health
	hp.value = player.health
	hpText.text = "HP: " + str(player.health) + "/" + str(player.max_health)

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
