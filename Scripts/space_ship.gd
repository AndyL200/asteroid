extends CharacterBody2D

signal firing(body : CharacterBody2D, shootingPosition : Node2D)
signal death
signal health_changed(new_health : int)
signal out(body : CharacterBody2D)

var max_speed: float = 300.0
var acceleration: float = 600.0
var friction: float = 200.0
var turn_speed: float = 3.0
var orientation_offset_deg: float = 90.0

var health := 3
var max_health := 3
var game_over_threshold := 0
var is_invulnerable := false
var is_game_over := false

var has_shield := false
var rapid_fire_active := false
var rapid_fire_timer: Timer
var shield_sprite: Sprite2D
var normal_fire_cooldown := 0.0
var rapid_fire_cooldown := 0.0
var last_shot_time := 0.0


func _player_method() -> void:
	pass

func _ready() -> void:
	normal_fire_cooldown = 0.25
	rapid_fire_cooldown = 0.125
	
	rapid_fire_timer = Timer.new()
	rapid_fire_timer.wait_time = 3.0
	rapid_fire_timer.one_shot = true
	rapid_fire_timer.timeout.connect(_on_rapid_fire_timeout)
	add_child(rapid_fire_timer)
	
	setup_shield_visual()


func _physics_process(delta: float) -> void:
	if not get_viewport_rect().has_point(position):
		out.emit(self)
		return
	if is_game_over:
		return
		
	var input_dir: Vector2 = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")

	if input_dir.length() > 0.0:
		var desired_velocity := input_dir.normalized() * max_speed
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)

		var target_angle := input_dir.angle() + deg_to_rad(orientation_offset_deg)
		rotation = lerp_angle(rotation, target_angle, min(1.0, turn_speed * delta))
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	var current_time = Time.get_ticks_msec() / 1000.0
	var fire_cooldown = rapid_fire_cooldown if rapid_fire_active else normal_fire_cooldown
	
	if Input.is_action_pressed("Shoot") and (current_time - last_shot_time) >= fire_cooldown:
		$shootingSound.play()
		firing.emit(self, $Pellet)
		last_shot_time = current_time
	
	move_and_slide()
	for i in get_slide_collision_count():
		var collide = get_slide_collision(i)
		var collider = collide.get_collider()
		if collider is CharacterBody2D and not is_invulnerable:
			if collider.has_method("is_enemy_bullet_check") and collider.is_enemy_bullet_check():
				take_damage(1)
				collider.expire_bullet()
			else:
				take_damage(1)

func take_damage(damage_amount: int) -> void:
	if is_invulnerable or is_game_over:
		return
	
	if has_shield:
		deactivate_shield()
		var shield_sound = AudioStreamPlayer.new()
		shield_sound.stream = preload("res://Asset/KenneySpaceShooter/Bonus/sfx_shieldDown.ogg")
		add_child(shield_sound)
		shield_sound.play()
		shield_sound.finished.connect(shield_sound.queue_free)
		return
		
	$damageSound.play()
	
	health -= damage_amount
	health = max(health, 0)
	
	health_changed.emit(health)
	
	check_game_over()

func check_game_over() -> void:
	if health <= game_over_threshold:
		is_game_over = true
		
		death.emit()
		
		queue_free()
	else:
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

func setup_shield_visual() -> void:
	shield_sprite = Sprite2D.new()
	shield_sprite.texture = preload("res://Asset/KenneySpaceShooter/PNG/Effects/shield1.png")
	shield_sprite.modulate = Color(0.5, 0.5, 1.0, 0.6)
	shield_sprite.scale = Vector2(1.5, 1.5)
	shield_sprite.visible = false
	add_child(shield_sprite)

func activate_rapid_fire() -> void:
	rapid_fire_active = true
	rapid_fire_timer.start()
	
	var sprite = $Sprite2D
	if sprite:
		sprite.modulate = Color.RED
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)

func _on_rapid_fire_timeout() -> void:
	rapid_fire_active = false

func activate_shield() -> void:
	has_shield = true
	if shield_sprite:
		shield_sprite.visible = true
		
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(shield_sprite, "modulate:a", 0.3, 0.5)
		tween.tween_property(shield_sprite, "modulate:a", 0.6, 0.5)

func deactivate_shield() -> void:
	has_shield = false
	if shield_sprite:
		shield_sprite.visible = false

func add_extra_life() -> void:
	if health < max_health:
		health += 1
		health = min(health, max_health)
		
		health_changed.emit(health)
		
		var sprite = $Sprite2D
		if sprite:
			sprite.modulate = Color.GOLD
			var tween = create_tween()
			tween.tween_property(sprite, "modulate", Color.WHITE, 0.5)
