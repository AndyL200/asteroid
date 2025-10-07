extends CharacterBody2D

var screen_size : Rect2
var screen_position : Vector2
var screen_ends : Vector2
signal outOfBounds(player : CharacterBody2D)
signal firing(body : CharacterBody2D, shootingPosition : Node2D)
signal death
signal health_changed(new_health : int)

# Movement properties
var max_speed: float = 300.0
var acceleration: float = 600.0
var friction: float = 200.0
var turn_speed: float = 3.0
var orientation_offset_deg: float = 90.0

# Health system properties
var health := 3
var max_health := 3
var game_over_threshold := 0  # Health value that triggers game over
var is_invulnerable := false
var is_game_over := false  # Flag to stop gameplay processes

func _ready() -> void:
	screen_size = get_viewport_rect()
	screen_position = screen_size.position
	screen_ends = screen_size.end

func _physics_process(delta: float) -> void:
	# Stop all gameplay processes if game is over
	if is_game_over:
		return
		
	# Boundary detection for screen wrapping
	if(position.x > screen_ends.x or position.y > screen_ends.y):
		outOfBounds.emit(self)
	if(position.x < screen_position.x or position.y < screen_position.y):
		outOfBounds.emit(self)
		
	# Player input handling
	var input_dir: Vector2 = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")

	if input_dir.length() > 0.0:
		var desired_velocity := input_dir.normalized() * max_speed
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)

		var target_angle := input_dir.angle() + deg_to_rad(orientation_offset_deg)
		rotation = lerp_angle(rotation, target_angle, min(1.0, turn_speed * delta))
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# Shooting input handling
	if Input.is_action_just_pressed("Shoot"):
		$shootingSound.play()  # Play shooting sound effect
		firing.emit(self, $Pellet)
	
	# Physics movement and collision detection
	move_and_slide()
	for i in get_slide_collision_count():
		var collide = get_slide_collision(i)
		var collider = collide.get_collider()
		if collider is CharacterBody2D and not is_invulnerable:
			# Check if it's an enemy bullet
			if collider.has_method("is_enemy_bullet_check") and collider.is_enemy_bullet_check():
				take_damage(1)
				collider.expire_bullet()  # Destroy the bullet on impact
			else:
				# Regular collision (asteroid, enemy)
				take_damage(1)

func take_damage(damage_amount: int) -> void:
	"""Centralized damage handling method with health clamping and game-over logic"""
	# Prevent damage during invulnerability or if game is already over
	if is_invulnerable or is_game_over:
		return
		
	# Play damage sound effect
	$damageSound.play()
	
	# Apply damage and clamp health to prevent negative values
	health -= damage_amount
	health = max(health, 0)  # Clamp health to minimum of 0
	
	# Update UI with clamped health value
	health_changed.emit(health)
	
	# Check if game over condition is met
	check_game_over()

func check_game_over() -> void:
	"""Dedicated function to handle game over logic when health reaches threshold"""
	# Check if health has reached the game over threshold
	if health <= game_over_threshold:
		# Set game over flag to stop all gameplay processes
		is_game_over = true
		
		# Emit death signal to trigger scene transition (game manager will handle sound)
		death.emit()
		
		# Destroy the space ship
		queue_free()
	else:
		# Player is still alive, trigger invulnerability
		blink_sprite()


func blink_sprite() -> void:
	is_invulnerable = true
	var sprite = $Sprite2D
	
	for blink_count in range(5):
		if not is_inside_tree():
			return
		sprite.visible = false
		await get_tree().create_timer(0.2).timeout
		if not is_inside_tree():
			return
		sprite.visible = true
		await get_tree().create_timer(0.2).timeout
	
	if is_inside_tree():
		is_invulnerable = false
