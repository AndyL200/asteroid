class_name EnhancedEnemy
extends CharacterBody2D

# Configuration variables - easily adjustable
@export var chase_speed: float = 100.0
@export var turn_speed: float = 3.0
@export var fire_rate: float = 1.0  # Bullets per second
@export var engagement_distance: float = 400.0  # Distance at which enemy starts engaging
@export var bullet_speed: float = 450.0
@export var bullet_spawn_offset: float = 50.0  # Distance in front of enemy to spawn bullets

# Screen boundary variables
var screen_size : Rect2
var screen_position : Vector2
var screen_ends : Vector2

# Player tracking
var player_position : Vector2
var target_rotation : float

# Shooting system
var fire_timer : Timer
var can_fire : bool = true

# Scene references
var red_bullet_scene := preload("res://Scenes/enemy_bullet_scene.tscn")

# Signals for game manager communication
signal death(body : CharacterBody2D)
signal firing(body : CharacterBody2D, muzzle_position : Node2D)

func _ready() -> void:
	# Initialize screen boundaries
	screen_size = get_viewport_rect()
	screen_position = screen_size.position
	screen_ends = screen_size.end
	
	# Spawn enemy at random position outside screen bounds
	spawn_at_random_position()
	
	# Setup automatic firing timer
	setup_firing_timer()

func spawn_at_random_position() -> void:
	"""Spawns enemy at random position outside screen boundaries"""
	var upper_bound = Vector2(screen_ends.x, screen_ends.y)
	var lower_bound = Vector2(screen_position.x, screen_position.y)
	
	# Choose random side to spawn from (with 100px buffer outside screen)
	var spawn_sides = [
		Vector2(randi() % int(screen_ends.x), lower_bound.y - randi() % 101 - 50),  # Top
		Vector2(randi() % int(screen_ends.x), upper_bound.y + randi() % 101 + 50),  # Bottom
		Vector2(lower_bound.x - randi() % 101 - 50, randi() % int(screen_ends.y)),  # Left
		Vector2(upper_bound.x + randi() % 101 + 50, randi() % int(screen_ends.y))   # Right
	]
	
	position = spawn_sides[randi() % spawn_sides.size()]

func setup_firing_timer() -> void:
	"""Initialize the automatic firing timer"""
	fire_timer = Timer.new()
	fire_timer.wait_time = 1.0 / fire_rate  # Convert fire rate to interval
	fire_timer.timeout.connect(Callable(self, "_on_fire_timer_timeout"))
	fire_timer.autostart = true
	add_child(fire_timer)

func _physics_process(delta: float) -> void:
	# Update enemy behavior
	update_orientation(delta)
	update_movement(delta)
	handle_collisions()

func update_orientation(delta: float) -> void:
	"""Smoothly rotate enemy to face the player"""
	if player_position == Vector2.ZERO:
		return  # No player position set yet
	
	# Calculate direction to player
	var direction_to_player = (player_position - global_position).normalized()
	
	# Calculate target rotation (pointing toward player)
	# Add 90 degrees offset since sprite faces up by default
	target_rotation = direction_to_player.angle() + deg_to_rad(90.0)
	
	# Smoothly interpolate rotation
	rotation = lerp_angle(rotation, target_rotation, turn_speed * delta)

func update_movement(delta: float) -> void:
	"""Handle enemy movement logic - chase player when in range"""
	if player_position == Vector2.ZERO:
		return
	
	var distance_to_player = global_position.distance_to(player_position)
	
	if distance_to_player > engagement_distance:
		# Too far - move toward player
		var direction = (player_position - global_position).normalized()
		velocity = direction * chase_speed
	elif distance_to_player > 100:
		# In engagement range - chase but slower for better targeting
		var direction = (player_position - global_position).normalized()
		velocity = direction * (chase_speed * 0.7)
	else:
		# Very close - stop moving and focus on shooting
		velocity = velocity.move_toward(Vector2.ZERO, chase_speed * 2 * delta)
	
	move_and_slide()

func handle_collisions() -> void:
	"""Process collision detection with bullets"""
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Check if hit by player bullet (has _hit_method)
		if collider and collider.has_method("_hit_method") and collider.has_method("is_player_bullet"):
			if collider.is_player_bullet():
				death.emit(self)
				return

func _on_fire_timer_timeout() -> void:
	"""Called every fire_rate interval - shoot at player"""
	if player_position != Vector2.ZERO:
		fire_bullet()

func fire_bullet() -> void:
	"""Calculate bullet spawn position and emit firing signal to game manager"""
	
	# Calculate spawn position in front of enemy based on facing direction
	# Enemy faces toward player, so forward vector is based on current rotation
	var forward_direction = Vector2.UP.rotated(rotation)  # Up vector rotated by enemy's facing angle
	var spawn_position = global_position + (forward_direction * bullet_spawn_offset)
	
	# Create a temporary marker at the calculated spawn position for the game manager
	var spawn_marker = Marker2D.new()
	spawn_marker.global_position = spawn_position
	
	# Emit firing signal to game manager with calculated spawn position
	firing.emit(self, spawn_marker)
	
	# Clean up the temporary marker after a short delay
	get_tree().process_frame.connect(spawn_marker.queue_free, CONNECT_ONE_SHOT)

func _on_bullet_expired(bullet: CharacterBody2D) -> void:
	"""Handle bullet cleanup when it expires"""
	if bullet and is_instance_valid(bullet):
		bullet.queue_free()

# Public interface for game manager
func set_player_position(pos: Vector2) -> void:
	"""Called by game manager to update player position"""
	player_position = pos

func set_fire_rate(rate: float) -> void:
	"""Adjust firing rate during gameplay"""
	fire_rate = rate
	if fire_timer:
		fire_timer.wait_time = 1.0 / fire_rate
