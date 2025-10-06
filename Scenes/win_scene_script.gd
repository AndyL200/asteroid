extends Control


func _on_quit_button_pressed() -> void:
	if is_inside_tree():
		get_tree().quit()
	pass # Replace with function body.
