class_name EnemyBullet
extends CharacterBody2D

# Bullet configuration
var direction: Vector2
var pos: Vector2
var dir: float
var speed: float = 450
var decay_rate: float = 2.0
var min_velocity: float = 150.0

# Bullet identification
var is_enemy_bullet: bool = true
var shooter_reference: Node2D = null  # Reference to the enemy that fired this bullet

# Signals
signal motion_end(body: CharacterBody2D)

func _ready() -> void:
	"""Initialize bullet position, rotation, and animation"""
	# Set initial position and rotation
	global_position = pos
	global_rotation = dir
	
	# Calculate velocity vector from rotation
	velocity = (Vector2.UP * speed).rotated(dir)
	
	# Start red laser animation
	$AnimatedSprite2D.play("red_shooting")

func _physics_process(delta: float) -> void:
	"""Handle bullet movement and lifetime management"""
	# Degrade velocity over time (simulates air resistance/energy loss)
	velocity -= Vector2(decay_rate * delta, decay_rate * delta)
	
	# Move bullet using kinematic collision
	var collision = move_and_collide(velocity * delta)
	
	# Handle collision with player or other objects
	if collision:
		var collider = collision.get_collider()
		if collider:
			# Ignore collision with the enemy that fired this bullet
			if shooter_reference and collider == shooter_reference:
				# Skip collision with shooter - bullet passes through
				return
			
			# Check if it's the player ship by looking for health_changed signal and take_damage method
			if collider.has_signal("health_changed") and collider.has_method("take_damage"):
				damage_player(collider)
				# Bullet expires after hitting player
				expire_bullet()
				return
			
			# Check if colliding with asteroids or other enemies (not the shooter)
			if collider != shooter_reference:
				# Bullet expires on collision with other objects
				expire_bullet()
	
	# Check if bullet should expire due to low velocity
	if velocity.length() < min_velocity:
		expire_bullet()

func damage_player(player: CharacterBody2D) -> void:
	"""Apply damage to player if not invulnerable"""
	# Check if player has invulnerability (same system as existing collisions)
	if player.has_method("take_damage"):
		player.take_damage(1)  # Deal 1 damage
	elif not player.is_invulnerable:  # Direct access if method doesn't exist
		player.health -= 1
		player.health_changed.emit(player.health)
		if player.health <= 0:
			player.death.emit()
		else:
			player.blink_sprite()  # Trigger invulnerability period

func expire_bullet() -> void:
	"""Clean up bullet when it expires"""
	motion_end.emit(self)
#
#func _hit_method() -> void:
	#"""Interface method for collision identification - enemy bullets don't get destroyed by asteroids/enemies"""
	#pass

func is_player_bullet() -> bool:
	"""Identifies this as an enemy bullet (not player bullet)"""
	return false

func is_enemy_bullet_check() -> bool:
	"""Identifies this as an enemy bullet"""
	return true
