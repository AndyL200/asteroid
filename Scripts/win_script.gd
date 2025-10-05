class_name winDialog
extends Node3D

@onready var dialog_ui = %DialogUI
@onready var win_ui = %Win

var dialog_lines : Array[String] = [ 
	"??? : You win", 
	"??? : Fuck offf", 
	"??? : sample dialog", 
	"??? : sample dialog", 
	"??? : sample dialog" ]
var current_line := 0

func _ready() -> void:
	win_ui.visible = false
	process_line(parse_line(dialog_lines[current_line]))
	current_line = current_line + 1
	pass
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Shoot"):
		process_line(parse_line(dialog_lines[current_line]))
		current_line = current_line + 1
		if current_line >= dialog_lines.size():
			win_message()
			current_line = 0
	pass

func parse_line(line : String) -> Dictionary:
	var line_info = line.split(':')
	assert(len(line_info) >= 2)
	return {
		"speaker": line_info[0],
		"dialog" : line_info[1]
	}
func process_line(line_info : Dictionary) -> void:
	dialog_ui.change_line(line_info["speaker"], line_info["dialog"])

func win_message():
	win_ui.visible = true
	pass
