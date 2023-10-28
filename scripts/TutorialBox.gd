extends Control

@onready var root = get_node("/root/PersistentHUD")

func _ready():
	if root.tutorial_read:
		queue_free()

func _on_button_pressed():
	root.tutorial_read = true
	queue_free()
