class_name Game
extends Node2D

@export var score_label : Label
@export var lives_label : Label
@export var combo_label : Label
@export var enemy_timer : Timer
@export var player : CharacterBody2D

var asteroid_timer : Timer

var screen_size : Rect2
var screen_position : Vector2
var screen_ends : Vector2

@onready var enemy_scene := preload("res://Scenes/enemy_black_1_scene.tscn")
@onready var asteroid_scene_big := preload("res://Scenes/asteroid_template_big.tscn")
@onready var asteroid_scene_med := preload("res://Scenes/asteroid_template_med.tscn")
@onready var asteroid_scene_small := preload("res://Scenes/asteroid_template_small.tscn")
@onready var asteroid_scene_tiny := preload("res://Scenes/asteroid_template_tiny.tscn")
@onready var bullet_scene := preload("res://Scenes/bullet_scene.tscn")
@onready var enemy_bullet_scene := preload("res://Scenes/enemy_bullet_scene.tscn")
@onready var powerup_scene := preload("res://Scenes/powerup_scene.tscn")

var asteroid_scenes : Array

var asteroid_count = 10
var score = 0
var enemy_current = 0

var combo_count := 1
var combo_window := 1.5
var combo_timer : Timer

var is_game_over := false

func update_score(points : int):
	score += points
	score_label.text = str(score)
	if score == 20:
		win_game()
	pass
func make_asteroid():
	var selected_scene = asteroid_scenes[randi() % asteroid_scenes.size()]
	var a = selected_scene.instantiate()
	a.killed.connect(Callable(self, "dead_asteroid"))
	a.out.connect(Callable(self, "remove_asteroid"))
	
	var direction = (player.position - a.position).normalized()
	var random_angle = randf_range(-0.5, 0.5)
	direction = direction.rotated(random_angle)
	a.velocity = direction * randf_range(80, 120)
	a.basic_conditions()
	
	$Asteroids.add_child(a)
	

func dead_asteroid(body : CharacterBody2D):
	if body in $Asteroids.get_children():
		var destruction_sound = AudioStreamPlayer.new()
		destruction_sound.stream = preload("res://Asset/KenneySpaceShooter/Bonus/sfx_zap.ogg")
		add_child(destruction_sound)
		destruction_sound.play()
		destruction_sound.finished.connect(destruction_sound.queue_free)
		
		handle_object_destroyed(10, "asteroid")
		remove_asteroid(body)
	
	
func remove_asteroid(asteroid : CharacterBody2D):
	$Asteroids.remove_child(asteroid)
	asteroid.queue_free()

func instantiate_enemy():
	var enemy : CharacterBody2D = enemy_scene.instantiate()
	enemy.set_player_position(player.global_position)
	enemy.death.connect(Callable(self, "remove_enemy"))
	enemy.firing.connect(Callable(self, "on_enhanced_enemy_firing"))
	enemy_current += 1
	$Enemies.add_child(enemy)
func remove_enemy(enemy : Node2D):
	handle_object_destroyed(50, "enemy")
	
	spawn_powerup_at_position(enemy.global_position)
	
	$Enemies.remove_child(enemy)
	enemy_current -= 1
	enemy.queue_free()
	
	
func _ready() -> void:
	screen_size = get_viewport_rect()
	screen_position = screen_size.position
	screen_ends = screen_size.end
	score_label.position = screen_size.get_center() - Vector2(0, screen_ends.y*0.45)
	
	asteroid_scenes = [asteroid_scene_big, asteroid_scene_med, asteroid_scene_small, asteroid_scene_tiny]
	
	enemy_timer.wait_time = 10
	enemy_timer.autostart = true
	
	asteroid_timer = Timer.new()
	asteroid_timer.wait_time = 2.0
	asteroid_timer.autostart = true
	asteroid_timer.timeout.connect(Callable(self, "_on_asteroid_spawn_timer_timeout"))
	add_child(asteroid_timer)
	
	update_lives_label(player.health)
	player.out.connect(Callable(self, "ship_out_of_bounds"))
	
	setup_combo_timer()
	update_combo_display()
	
	for i in range(asteroid_count):
		call_deferred("make_asteroid")
	pass

func _process(delta: float) -> void:
	if is_game_over:
		return
		
	for e in $Enemies.get_children():
		if e.has_method("set_player_position"):
			e.set_player_position(player.position)
		
	pass



func ship_out_of_bounds(player: CharacterBody2D) -> void:
	enemy_timer.stop()
		
	if(player.position.x < screen_position.x):
		player.position = screen_size.get_center() + Vector2(screen_ends.x * 0.45, 0)
	elif(player.position.x > screen_ends.x):
		player.position = Vector2(screen_position.x, screen_size.get_center().y)
	elif(player.position.y < screen_position.y):
		player.position = screen_size.get_center() + + Vector2(0, screen_ends.y * 0.45)
	elif(player.position.y > screen_ends.y):
		player.position = Vector2(screen_size.get_center().x, screen_position.y)
	
	for a in $Asteroids.get_children():
		if a.has_method("_asteroid_method"):
			remove_asteroid(a)
	for i in range(asteroid_count):
		make_asteroid()
	for e in $Enemies.get_children():
		if e.has_method(""):
			remove_enemy(e)
	for b in $Bullets.get_children():
		$Bullets.remove_child(b)
		b.queue_free()
		
	enemy_timer.start()


func _on_enemy_spawn_timer_timeout() -> void:
	if enemy_current < 1:
		instantiate_enemy()

func _on_asteroid_spawn_timer_timeout() -> void:
	var current_asteroid_count = $Asteroids.get_child_count()
	while current_asteroid_count < asteroid_count:
		make_asteroid()
		current_asteroid_count += 1
	pass
func bullet_stopped(bullet : CharacterBody2D) -> void:
	$Bullets.remove_child(bullet)
	bullet.queue_free()

func _on_space_ship_firing(body : CharacterBody2D, shoot : Node2D) -> void:
	var bullet = bullet_scene.instantiate()
	bullet.dir = body.global_rotation
	bullet.pos = shoot.global_position
	print(bullet.pos)
	bullet.motion_end.connect(Callable(self, "bullet_stopped"))
	$Bullets.add_child(bullet)
	
func _on_enemy_ship_firing(body : CharacterBody2D, shoot : Node2D):
	var bullet = bullet_scene.instantiate()
	bullet.dir = body.global_rotation
	bullet.pos = shoot.global_position
	bullet.motion_end.connect(Callable(self, "bullet_stopped"))
	$Bullets.add_child(bullet)
	pass

func on_enhanced_enemy_firing(body : CharacterBody2D, spawn_marker : Node2D):
	"""Handle firing from enhanced enemies with red bullets"""
	var bullet = enemy_bullet_scene.instantiate()
	
	bullet.dir = body.global_rotation
	bullet.pos = spawn_marker.global_position
	bullet.speed = 450
	bullet.is_enemy_bullet = true
	bullet.shooter_reference = body
	
	bullet.motion_end.connect(Callable(self, "bullet_stopped"))
	$Bullets.add_child(bullet)
	pass

func update_lives_label(new_health : int) -> void:
	lives_label.text = "Lives: " + str(new_health)

func on_player_death() -> void:
	is_game_over = true
	
	enemy_timer.stop()
	
	if is_inside_tree():
		var game_over_sound = AudioStreamPlayer.new()
		game_over_sound.stream = preload("res://Asset/KenneySpaceShooter/Bonus/sfx_lose.ogg")
		add_child(game_over_sound)
		game_over_sound.play()
		
		await game_over_sound.finished
		
		game_over_sound.queue_free()
		if is_inside_tree():
			get_tree().change_scene_to_file("res://Scenes/loseScene.tscn")
	
func win_game() -> void:
	is_game_over = true
	
	enemy_timer.stop()
	
	if is_inside_tree():
		var victory_sound = AudioStreamPlayer.new()
		victory_sound.stream = preload("res://Asset/KenneySpaceShooter/Bonus/jingle.ogg")
		add_child(victory_sound)
		victory_sound.play()
		
		await victory_sound.finished
		
		victory_sound.queue_free()
		if is_inside_tree():
			get_tree().change_scene_to_file("res://Scenes/winScene.tscn")

func setup_combo_timer() -> void:
	combo_timer = Timer.new()
	combo_timer.wait_time = combo_window
	combo_timer.timeout.connect(Callable(self, "reset_combo"))
	combo_timer.one_shot = true
	add_child(combo_timer)

func handle_object_destroyed(base_points: int, object_type: String) -> void:
	var final_score = base_points * combo_count
	
	update_score(final_score)
	
	combo_count += 1
	
	combo_timer.stop()
	combo_timer.start()
	
	update_combo_display()

func reset_combo() -> void:
	"""Reset combo when timer expires"""
	combo_count = 1
	update_combo_display()

func update_combo_display() -> void:
	"""Update the combo UI display"""
	if combo_label:
		if combo_count > 1:
			combo_label.text = "Combo: " + str(combo_count) + "x"
			combo_label.visible = true
		else:
			combo_label.visible = false

func spawn_powerup_at_position(position: Vector2) -> void:
	var random_value = randi() % 100
	var powerup_type: int
	
	if random_value < 50:
		powerup_type = 0
	elif random_value < 90:
		powerup_type = 1
	else:
		powerup_type = 2
	
	var powerup = powerup_scene.instantiate()
	powerup.global_position = position
	powerup.set_powerup_type(powerup_type)
	
	powerup.collected.connect(_on_powerup_collected)
	
	$PowerUps.add_child(powerup)

func _on_powerup_collected(powerup: Node2D, type: int) -> void:
	match type:
		0:
			player.activate_rapid_fire()
		1:
			player.activate_shield()
		2:
			player.add_extra_life()
	
	if powerup and is_instance_valid(powerup):
		$PowerUps.remove_child(powerup)
