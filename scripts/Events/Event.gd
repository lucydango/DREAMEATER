extends Node

# RESOLVE CONSEQUENCE GUIDE #

# To give stat boost/loss:
# hp/stam/str/end +/- [int]
# e.g hp + 1

# To give/take item:
# [item_id] +/-
# e.g POTION +

@export var frame: Texture2D

# Min MAX_HP to encounter event
@export var prerequisite: int

@export_group("Intro Variables")
@export_multiline var intro_text: String
@export_multiline var resolution_one_button_text: String
@export_multiline var resolution_two_button_text: String

@export_group("Resolution One")
@export_multiline var resolution_one_text: String
@export_multiline var resolution_one_end_text: String
@export_multiline var resolution_one_resolve_consequences: Array[String]

@export_group("Resolution Two")
@export_multiline var resolution_two_text: String
@export_multiline var resolution_two_end_text: String
@export_multiline var resolution_two_resolve_consequences: Array[String]
