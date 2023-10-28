extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var r = get_node("/root/PersistentHUD")
	get_node("MainBox/StatText").text = "Nightmares Traversed: "+str(r.runs)+"\nDamage Taken: "+str(r.damage_taken)+"\nDamage Dealt: "+str(r.damage_dealt)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
