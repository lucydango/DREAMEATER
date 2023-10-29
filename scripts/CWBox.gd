extends Control

@export var root: PackedScene
func _on_button_pressed():
	get_tree().change_scene_to_packed(root)
	queue_free()
