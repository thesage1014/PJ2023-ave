class_name Powerup extends Area3D
enum powerup_type {ROPE,POT,LANTERN,MAXHEART,SHOVEL,BOOTS}
@export var type:powerup_type
@export var icons:Array[CompressedTexture2D]
signal collected(powerup:Powerup)

func _ready():
	($Mesh.get_active_material(0) as StandardMaterial3D).albedo_texture = icons[type]
	connect("collected",Singleton.player.on_powerup_hit)


func _on_body_entered(body):
	if body is Player:
		emit_signal("collected",self)
