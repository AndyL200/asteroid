extends Control


func _on_quit_button_pressed() -> void:
	if is_inside_tree():
		get_tree().quit()


func _on_continue_button_pressed() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_file("res://Scenes/startingScene.tscn")
