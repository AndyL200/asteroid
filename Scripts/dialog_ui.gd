class_name dialog_ui
extends Control

@onready var dialogBox := %Dialog
@onready var speaker := %speaker_name

const ANIMATION_SPEED := 30
var animate_text : bool = false
var curr_visible_characters := 0

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if animate_text:
		if dialogBox.visible_ratio < 1:
			dialogBox.visible_ratio += (1.0/dialogBox.text.length()) * (ANIMATION_SPEED * delta)
			curr_visible_characters = dialogBox.visible_characters
		else:
			animate_text = false
	pass
	
func change_line(speaking : String, line : String):
	speaker.text = speaking
	dialogBox.text = line
	dialogBox.visible_ratio = 0
	curr_visible_characters = 0
	animate_text = true
