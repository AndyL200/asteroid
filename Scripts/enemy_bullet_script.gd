class_name EnemyBullet
extends CharacterBody2D

var direction: Vector2
var pos: Vector2
var dir: float
var speed: float = 450
var decay_rate: float = 2.0
var min_velocity: float = 150.0

var is_enemy_bullet: bool = true
var shooter_reference: Node2D = null

signal motion_end(body: CharacterBody2D)

func _ready() -> void:
	global_position = pos
	global_rotation = dir
	
	velocity = (Vector2.UP * speed).rotated(dir)
	
	$AnimatedSprite2D.play("red_shooting")

func _physics_process(delta: float) -> void:
	velocity -= Vector2(decay_rate * delta, decay_rate * delta)
	
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		if collider:
			if shooter_reference and collider == shooter_reference:
				return
			
			if collider.has_signal("health_changed") and collider.has_method("take_damage"):
				damage_player(collider)
				expire_bullet()
				return
			
			if collider != shooter_reference:
				expire_bullet()
	
	if velocity.length() < min_velocity:
		expire_bullet()

func damage_player(player: CharacterBody2D) -> void:
	if player.has_method("take_damage"):
		player.take_damage(1)
	elif not player.is_invulnerable:
		player.health -= 1
		player.health_changed.emit(player.health)
		if player.health <= 0:
			player.death.emit()
		else:
			player.blink_sprite()

func expire_bullet() -> void:
	motion_end.emit(self)


func is_player_bullet() -> bool:
	return false

func is_enemy_bullet_check() -> bool:
	return true
