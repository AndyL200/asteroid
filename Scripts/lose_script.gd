class_name loseDialog
extends Node3D

@onready var dialog_ui = %DialogUI

var dialog_lines : Array[String] = [ 
	"??? : You lost", 
	"??? : Continue?", 
	"??? : sample dialog", 
	"??? : sample dialog", 
	"??? : sample dialog" ]
var current_line := 0

func _ready() -> void:
	process_line(parse_line(dialog_lines[current_line]))
	current_line = (current_line + 1) % len(dialog_lines)
	pass
	
func _process(delta: float) -> void:
	if Input.is_action_pressed("Shoot"):
		process_line(parse_line(dialog_lines[current_line]))
		current_line = (current_line + 1) % len(dialog_lines)
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
