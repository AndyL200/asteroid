class_name Bullet
extends CharacterBody2D

var force_direction
var target


func _ready()->void:
	force_direction = Vector2.ZERO
	target = Vector2.ZERO
func _process(delta: float) -> void:
	position += (force_direction - target) * 5 * delta
