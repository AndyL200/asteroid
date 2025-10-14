class_name Enemy
extends CharacterBody2D

@export var chase_speed: float = 100.0
@export var turn_speed: float = 3.0
@export var fire_rate: float = 1.0
@export var engagement_distance: float = 400.0
@export var bullet_speed: float = 450.0
@export var bullet_spawn_offset: float = 50.0
@export var max_health: int = 3

var screen_size : Rect2
var screen_position : Vector2
var screen_ends : Vector2

var player_position : Vector2
var target_rotation : float

var fire_timer : Timer
var can_fire : bool = true

var current_health : int

var red_bullet_scene := preload("res://Scenes/enemy_bullet_scene.tscn")

signal death(body : CharacterBody2D)
signal firing(body : CharacterBody2D, muzzle_position : Node2D)

func _ready() -> void:
	current_health = max_health
	
	screen_size = get_viewport_rect()
	screen_position = screen_size.position
	screen_ends = screen_size.end
	
	spawn_at_random_position()
	
	setup_firing_timer()

func spawn_at_random_position() -> void:
	var upper_bound = Vector2(screen_ends.x, screen_ends.y)
	var lower_bound = Vector2(screen_position.x, screen_position.y)
	
	var spawn_sides = [
		Vector2(randi() % int(screen_ends.x), lower_bound.y - randi() % 101 - 50),
		Vector2(randi() % int(screen_ends.x), upper_bound.y + randi() % 101 + 50),
		Vector2(lower_bound.x - randi() % 101 - 50, randi() % int(screen_ends.y)),
		Vector2(upper_bound.x + randi() % 101 + 50, randi() % int(screen_ends.y))
	]
	
	position = spawn_sides[randi() % spawn_sides.size()]

func setup_firing_timer() -> void:
	fire_timer = Timer.new()
	fire_timer.wait_time = 1.0 / fire_rate
	fire_timer.timeout.connect(Callable(self, "_on_fire_timer_timeout"))
	fire_timer.autostart = true
	add_child(fire_timer)

func _physics_process(delta: float) -> void:
	if not get_viewport_rect().grow(100).has_point(position):
		death.emit(self)
		return
	var game_manager = get_node("/root/Game")
	if game_manager and game_manager.has_method("get") and "is_game_over" in game_manager:
		if game_manager.is_game_over:
			return
	
	update_orientation(delta)
	update_movement(delta)

func update_orientation(delta: float) -> void:
	if player_position == Vector2.ZERO:
		return
	
	var direction_to_player = (player_position - global_position).normalized()
	
	target_rotation = direction_to_player.angle() + deg_to_rad(90.0)
	
	rotation = lerp_angle(rotation, target_rotation, turn_speed * delta)

func update_movement(delta: float) -> void:
	if player_position == Vector2.ZERO:
		return
	
	var direction = (player_position - global_position).normalized()
	var desired_velocity = direction * chase_speed
	
	var collision = move_and_collide(desired_velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		
		if collider and (collider is Asteroid or collider is Enemy):
			global_position += desired_velocity * delta
		elif collider and collider.has_method("is_player_bullet") and collider.is_player_bullet():
			pass
		else:
			pass


func _on_fire_timer_timeout() -> void:
	if player_position != Vector2.ZERO:
		fire_bullet()

func fire_bullet() -> void:
	
	var forward_direction = Vector2.UP.rotated(rotation)
	var spawn_position = global_position + (forward_direction * bullet_spawn_offset)
	
	var spawn_marker = Marker2D.new()
	spawn_marker.global_position = spawn_position
	
	firing.emit(self, spawn_marker)
	
	if is_inside_tree():
		get_tree().process_frame.connect(spawn_marker.queue_free, CONNECT_ONE_SHOT)

func _on_bullet_expired(bullet: CharacterBody2D) -> void:
	if bullet and is_instance_valid(bullet):
		bullet.queue_free()

func set_player_position(pos: Vector2) -> void:
	player_position = pos

func set_fire_rate(rate: float) -> void:
	fire_rate = rate
	if fire_timer:
		fire_timer.wait_time = 1.0 / fire_rate
		
func _enemy_method() ->void:
	pass

func take_damage() -> void:
	current_health -= 1
	
	print("Enemy hit! Health: ", current_health, "/", max_health)
	
	if current_health > 0:
		flash_damage_effect()
		
		var damage_sound = AudioStreamPlayer.new()
		damage_sound.stream = preload("res://Asset/KenneySpaceShooter/Bonus/sfx_shieldDown.ogg")
		add_child(damage_sound)
		damage_sound.play()
		damage_sound.finished.connect(damage_sound.queue_free)
	
	if current_health <= 0:
		print("Enemy destroyed!")
		death.emit(self)

func flash_damage_effect() -> void:
	var sprite = $AnimatedSprite2D
	if sprite:
		sprite.modulate = Color.RED
		
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
