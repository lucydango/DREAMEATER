extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("MainBox/StatText").text = "Nightmares Traversed: "+str(get_node("/root/PersistentHUD").runs)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
