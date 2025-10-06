extends Control


func _on_quit_button_pressed() -> void:
	if is_inside_tree():
		get_tree().quit()
	pass # Replace with function body.


func _on_continue_button_pressed() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_file("res://Scenes/startingScene.tscn")
	pass # Replace with function body.
