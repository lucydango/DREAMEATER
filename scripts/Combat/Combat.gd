extends Control

# Child Node Access
@onready var main_box = get_node("MainBox")
@onready var event_text = get_node("MainBox/EventText")
@onready var action_container = get_node("ActionContainer")

# Root
@onready var root = get_node("/root/PersistentHUD")

# Misc
var take_turn = false
var time_until = -1

# Flavour 
var intro_text = [
	"It's just like every time before.\n\nAs the walls close in on you, through them seep black, oily tendrils which sharpen to a point at their end.\n\nLarge and imposing they flail, aimless yet vicious."]
var nightmare_action_texts = [
	"A tendril finds it's mark, slashing straight through you and leaving a trail of your own blood in it's wake.", 
	"You hear a faint howling in the distance, and feel your energy being sapped away by some otherwordly force.",
	"A tendril aims itself for the crook of your neck. Mercifully, it misjudges its arc and undershoots your small, easy to miss body.",
	"The nightmare's gaping maw looms over you as you are gripped by a pair of the tooth-like tendrils. You are barely able to get yourself free.",
	"A tendril scrapes by you as you manouver in empty space, and you feel breathless as blood drips down your leg."]
var player_action_texts = [
	"You lurch at a tendril, barely making a dent in it's thick hide.", 
	"You steel yourself and dive at a tendril, tearing a hole in it before you are knocked backwards.", 
	"You catch your breath as best you can whilst edge after serrated edge passes you by."]

# Combat Tracking
var nightmare_actions = ["ATTACK", "DRAIN", "MISS", "DEVOUR", "SCRAPE"]
@export var nightmare_hp: int = 400
enum combat_actions {ATTACK, STRONG_ATTACK, RECOVER}
var action = combat_actions.ATTACK
var phase_two_started = false



# Called when the node enters the scene tree for the first time.
func _ready():
	event_text.text = intro_text[0]

func nightmare_ai():
	var nightmare_action = randi_range(0, 2) if !phase_two_started else randi_range(0, len(nightmare_actions) - 1)
	if nightmare_actions[nightmare_action] == "ATTACK":
		root.hp -= 4 * ((int(phase_two_started) * 2) + 1)
	elif nightmare_actions[nightmare_action] == "DRAIN":
		root.stam -= 2 * ((int(phase_two_started) * 4) + 1)
		if root.stam < 0:
			root.stam = 0
	elif nightmare_actions[nightmare_action] == "DEVOUR":
		root.hp -= 5 * ((int(phase_two_started) * 2) + 1)
	elif nightmare_actions[nightmare_action] == "SCRAPE":
		root.hp -= 2 * ((int(phase_two_started) * 2) + 1)
		root.stam -= 2 * ((int(phase_two_started) * 2) + 1)
	return nightmare_action_texts[nightmare_action]
	
func turn():
	var turn_text = ""
	turn_text += player_action_texts[action] + "\n\n"
	turn_text += nightmare_ai()
	if nightmare_hp < 350 && nightmare_hp > 300:
		turn_text += "\n\nYou hear pained screams and wails from within the walls."
	if nightmare_hp < 300 && !phase_two_started:
		turn_text = "As you land your blow, reality itself seems to contort. You lose grasp of your body, and feel weightless - almost formless.\n\n
		In front of you, the true nature of your nightmare reveals itself, the sentient labyrinth itself moves to reclaim you!"
		event_text.text = turn_text
		main_box.get_node("EnemyText").text = "Labyrinth"
		main_box.get_node("ImageFrame").texture = ImageTexture.create_from_image(Image.load_from_file("res://Sprites/HUD/nightmarephase2.png"))
		phase_two_started = true
		return
	event_text.text = turn_text
	if action == combat_actions.ATTACK || action == combat_actions.STRONG_ATTACK:
		var anim = get_node("AttackAnim")
		anim.play()
		time_until = 0.765
	root.exp += 1
	if root.exp == 10:
		root.parse_consequence_string(["str", "end", "max_hp", "max_stam"][randi_range(0,3)]+" + 1")
		root.exp = 0
	if nightmare_hp <= 0:
		root.scene_root.add_child(root.end_scn.instantiate())
		queue_free()
	
func _process(delta):
	if take_turn:
		turn()
		take_turn = false
	if time_until > 0:
		for i in action_container.get_children():
			i.disabled = true
		time_until -= delta
		if time_until < 0:
			if action == combat_actions.ATTACK ||  action == combat_actions.STRONG_ATTACK:
				var audio = get_node("AttackPlayer")
				audio.playing = true
	else:
		for i in action_container.get_children():
			i.disabled = false


func _on_attack_pressed():
	if root.stam > 0:
		root.stam -= 1
		nightmare_hp -= root.str
		action = combat_actions.ATTACK
		take_turn = true


func _on_recover_pressed():
	if root.stam < root.max_stam:
		root.stam += root.end
		get_node("RecoverPlayer").playing = true
		time_until = 0.5
		if root.stam > root.max_stam:
			root.stam = root.max_stam
		action = combat_actions.RECOVER
		take_turn = true


func _on_strong_attack_pressed():
	if root.stam > 2:
		root.stam -= 3
		nightmare_hp -= root.str * 3
		action = combat_actions.STRONG_ATTACK
		take_turn = true
