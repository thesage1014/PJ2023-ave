class_name UI extends Control
@export var player:Player
@export var hp:ProgressBar
@export var hpText:Label

func _process(delta):
	hp.max_value = player.max_health
	hp.value = player.health
	hpText.text = "HP: " + str(player.health) + "/" + str(player.max_health)
