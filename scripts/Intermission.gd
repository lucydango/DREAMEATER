extends Control

@export var time: float = 2
var to_load

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		time -= delta
		if time <= 0:
			get_parent().current_state = get_parent().states.NEW_EVENT
	else:
		time = 2
