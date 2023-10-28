extends Control

@onready var root = get_node("/root/PersistentHUD")
var time = 6
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time -= delta
	print(time)
	if time < 0:
		root.scene_root.add_child(root.dungeon.instantiate())
		root.runs += 1
		queue_free()
