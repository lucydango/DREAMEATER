extends Control

signal final_combat
# Will be filled with loaded events
var events = []
@export var events_preload: Array[PackedScene]
var current_event = null
var current_event_id = 0
var events_run = 0
var events_per_run = 3
# State information
enum states { NEW_EVENT, RES_ONE, RES_TWO, INTERMISSION }
var current_state = states.NEW_EVENT
# Child Node Access
@onready var main_box = get_node("MainBox")
@onready var event_text = get_node("MainBox/EventText")
@onready var resolution_one = get_node("MainBox/ResolutionOne")
@onready var resolution_two = get_node("MainBox/ResolutionTwo")
@onready var intermission = get_node("IntermissionHUD")

# Root
@onready var root = get_node("/root/PersistentHUD")

func _ready():
	connect("final_combat", root.load_final_combat)
	var dir = DirAccess.open("res://Scenes/Events")
	var event = dir.list_dir_begin()
	var event_name = dir.get_next()
	#while event_name != "":
	#	events.append(load("res://Scenes/Events/"+event_name))
	#	if event_name == "AEvent0.tscn":
	#		current_event = events[-1]
	#		current_event_id = len(events) - 1
	#	event_name = dir.get_next()
	events = events_preload
	current_event = events[-1]
	current_event_id = len(events) - 1
	load_event()

func load_event_text(main, button_one, button_two):
	event_text.text = main
	resolution_one.text = button_one
	resolution_two.text = button_two
	
func load_event():
	var event = current_event.instantiate()
	if current_state == states.NEW_EVENT:
		if events_run > events_per_run:
			emit_signal("final_combat")
		load_event_text(event.intro_text, event.resolution_one_button_text, event.resolution_two_button_text)
		main_box.get_node("ImageFrame").texture = event.frame
	if current_state == states.RES_ONE:
		load_event_text(event.resolution_one_text, event.resolution_one_end_text, event.resolution_one_end_text)
	if current_state == states.RES_TWO:
		load_event_text(event.resolution_two_text, event.resolution_two_end_text, event.resolution_two_end_text)
	if current_state == states.INTERMISSION:
		intermission.visible = true
	else:
		intermission.visible = false
			
func resolve_event():
	var resolve_consequences
	var event = current_event.instantiate()
	if current_state == states.RES_ONE:
		if event.resolution_one_resolve_consequences:
			resolve_consequences = event.resolution_one_resolve_consequences
	else:
		if event.resolution_two_resolve_consequences:
			resolve_consequences = event.resolution_two_resolve_consequences
	if resolve_consequences:
		for i in resolve_consequences:
			root.parse_consequence_string(i)
	current_event = events[randi_range(0, len(events) - 1)]
	while current_event.instantiate().prerequisite >= root.max_hp:
		current_event = events[randi_range(0, len(events) - 1)]
	current_state = states.INTERMISSION
	events_run += 1
	
func _process(delta):
	load_event()


func _on_resolution_one_pressed():
	if current_state == states.NEW_EVENT:
		current_state = states.RES_ONE
	else:
		resolve_event()
		
func _on_resolution_two_pressed():
	if current_state == states.NEW_EVENT:
		current_state = states.RES_TWO
	else:
		resolve_event()
