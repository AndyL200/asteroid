class_name Bullet
extends CharacterBody2D

var direction
var pos : Vector2
var dir : float
var speed := 450
var slow := 2
signal motion_end(body : CharacterBody2D)

func _hit_method():
	pass
func _ready()->void:
	global_position = pos
	global_rotation = dir
	velocity = (Vector2.UP * speed).rotated(dir)
	$AnimatedSprite2D.play()
	pass
func _physics_process(delta: float) -> void:
	velocity -= Vector2(delta,delta)
	move_and_collide(velocity * delta)
	if(velocity.length() < 150):
		motion_end.emit(self)
	pass
