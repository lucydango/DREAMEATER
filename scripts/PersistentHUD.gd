extends Control

#Items and IDs
enum item_ids { POTION, KNIFE, STAM_SCROLL, HP_SCROLL, CLOTH}
var items = { item_ids.POTION : ["POTION: +4HP", "hp + 4"], item_ids.KNIFE: ["KNIFE: +2STR", "str + 2"], 
	item_ids.STAM_SCROLL: ["SCROLL: +?STAM", "stam + 20"], item_ids.HP_SCROLL: ["SCROLL: +?HP", "hp + 20"], 
	item_ids.CLOTH: ["CLOTH: +1 MAXHP", "max_hp + 1"]}

# Inventory
var inventory = []

# Player Stats
@export var hp: int = 5
@export var max_hp: int = 5
@export var stam: int = 5
@export var max_stam: int = 5
@export var str: int = 1
@export var end: int = 1
@export var exp: int = 0

# Child Node Variables
@onready var stat_container = get_node("StatsBox/StatContainer")
@onready var inventory_container = get_node("InventoryBox/InventoryContainer")
@onready var scene_root = get_node("SceneRoot")

# Preloads
@onready var dungeon = preload("res://Scenes/Dungeon.tscn")
@onready var combat = preload("res://Scenes/Combat.tscn")
@onready var death = preload("res://Scenes/Death.tscn")
@onready var end_scn = preload("res://Scenes/EndScreen.tscn")

@onready var inv_button = preload("res://Scenes/inv_button.tscn")
# Misc.
var update_hud_time = 0.1
var runs = 1
var damage_dealt = 0
var damage_taken = 0
var tutorial_read = false

func _ready():
	update_hud()

func parse_consequence_string(string):
	var s = string.split(" ")
	var add = true if s[1] == "+" else false
	if s[0] in ["hp", "stam", "str", "end", "max_hp", "max_stam"]:
		if s[0] == "hp":
			hp = hp + int(s[2]) if add else  hp - int(s[2])
		elif s[0] == "stam":
			stam = stam + int(s[2]) if add else  stam - int(s[2])
		elif s[0] == "str":
			str = str + int(s[2]) if add else str - int(s[2])
		elif s[0] == "end":
			end = end + int(s[2]) if add else  end - int(s[2])
		elif s[0] == "max_hp":
			max_hp = max_hp + int(s[2]) if add else max_hp - int(s[2])
		elif s[0] == "max_stam":
			max_stam = max_stam + int(s[2]) if add else max_stam - int(s[2])
	else:
		if add:
			print(items[item_ids.get(s[0])])
			inventory.append(item_ids.get(s[0]))
	if hp > max_hp:
		hp = max_hp
	if stam > max_stam:
		stam = max_stam
	if stam < 0:
		stam = 0
			
func update_hud():
	var label_array = ["HP: ", "STAM: ", "STR: ", "END: ", "EXP: "]
	var stat_array = [str(hp)+"/"+str(max_hp), str(stam)+"/"+str(max_stam), str(str), str(end), str(exp)]
	var ticker = 0
	for i in stat_container.get_children():
		i.text = label_array[ticker] + stat_array[ticker]
		ticker += 1
	for i in inventory_container.get_children():
		i.queue_free()
	ticker = len(inventory) + 1
	while ticker > 0:
		if ticker > len(inventory):
			var label = Label.new()
			inventory_container.add_child(label)
			label.text = "Inventory:"
		else:
			var button = inv_button.instantiate()
			inventory_container.add_child(button)
			button.connect("use",use_item)
			button.item = items[inventory[len(inventory) - ticker]]
			button.slot = len(inventory) - ticker
			button.text = items[inventory[len(inventory) - ticker]][0]
		ticker -= 1

func use_item(item, slot):
	print(slot)
	parse_consequence_string(item[1])
	inventory.pop_at(slot)
	
	
func load_final_combat():
	for i in scene_root.get_children():
		i.queue_free()
	var combat_loaded = combat.instantiate()
	scene_root.add_child(combat_loaded)	
	
func _process(delta):
	update_hud_time -= delta
	if update_hud_time < 0: 
		update_hud()
		update_hud_time = 0.1
	if scene_root.get_child_count() == 0:
		var new = dungeon.instantiate()
		scene_root.add_child(new)
	if hp <= 0:
		scene_root.get_child(0).queue_free()
		scene_root.add_child(death.instantiate())
		hp = max_hp
		stam = max_stam
		inventory = []
