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

func is_player_bullet() -> bool:
	return true

func is_enemy_bullet_check() -> bool:
	return false
func _ready()->void:
	global_position = pos
	global_rotation = dir
	velocity = (Vector2.UP * speed).rotated(dir)
	$AnimatedSprite2D.play()
func _physics_process(delta: float) -> void:
	velocity -= Vector2(delta,delta)
	
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		if collider:
			if collider is Enemy:
				collider.take_damage()
				motion_end.emit(self)
				return
			elif collider is Asteroid:
				collider.killed.emit(collider)
				motion_end.emit(self)
				return
	
	if(velocity.length() < 150):
		motion_end.emit(self)
