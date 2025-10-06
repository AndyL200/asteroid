class_name Game
extends Node2D

#exports
@export var score_label : Label
@export var lives_label : Label
@export var enemy_timer : Timer
@export var player : CharacterBody2D


#Notes
#TODO(make a scene for the enemies)



#get screen size
var screen_size : Rect2
var screen_position : Vector2
var screen_ends : Vector2

#scenes
var enemy_scene := preload("res://Scenes/enemy_black_1_scene.tscn")
var enhanced_enemy_scene := preload("res://Scenes/enhanced_enemy_scene.tscn")
var asteroid_scene_big := preload("res://Scenes/asteroid_template_big.tscn")
var bullet_scene := preload("res://Scenes/bullet_scene.tscn")
var enemy_bullet_scene := preload("res://Scenes/enemy_bullet_scene.tscn")

#counts
var asteroid_count = 5
var score = 0
#counter (may need to be atomic)
var enemy_current = 0

func update_score(points : int):
	score += points
	score_label.text = str(score)
	if score == 20:
		win_game()
	pass
func make_asteroid():
	var asteroid_scene = asteroid_scene_big
	var a = asteroid_scene.instantiate()
	#ready function called when added to scene tree
	$Asteroids.add_child(a)
	
	#set the force direction here
	a.velocity = (player.position - a.position).normalized() * a.speed
	a.strikeout.connect(Callable(self, "remove_asteroid"))
	a.killed.connect(Callable(self, "dead_asteroid"))

func dead_asteroid(body : CharacterBody2D):
	if body in $Asteroids.get_children():
		update_score(body.val)
	remove_asteroid(body)
func remove_asteroid(asteroid : CharacterBody2D):
	$Asteroids.remove_child(asteroid)
	#asychronus code not guarded by mutex
	make_asteroid()

func instantiate_enemy():
	var enemy : CharacterBody2D = enhanced_enemy_scene.instantiate()
	enemy.set_player_position(player.global_position)
	enemy.death.connect(Callable(self, "remove_enemy"))
	enemy.firing.connect(Callable(self, "on_enhanced_enemy_firing"))
	enemy_current += 1
	$Enemies.add_child(enemy)
func remove_enemy(enemy : Node2D):
	#This is wrong this needs to be based on a signal
	$Enemies.remove_child(enemy)
	enemy_current -= 1
	
	
func _ready() -> void:
	screen_size = get_viewport_rect()
	screen_position = screen_size.position
	screen_ends = screen_size.end
	score_label.position = screen_size.get_center() - Vector2(0, screen_ends.y*0.45)
	#should start already stopped
	enemy_timer.wait_time = 1
	enemy_timer.autostart = true
	
	# Initialize lives label
	update_lives_label(player.health)
	player.health_changed.connect(Callable(self, "update_lives_label"))
	player.death.connect(Callable(self, "on_player_death"))
	
	for i in range(asteroid_count):
		make_asteroid()
	pass

func _process(delta: float) -> void:
	#TODO(Interpolate an angle for each swap)
	for e in $Enemies.get_children():
		# Update player position for enhanced enemies
		if e.has_method("set_player_position"):
			e.set_player_position(player.position)
		else:
			# Fallback for old enemy type
			e.player_position = player.position
	pass



func _on_space_ship_out_of_bounds(player: CharacterBody2D) -> void:
	enemy_timer.stop()
	#have to block process for until the end of this code
		
	#TODO(More complex enemy logic here [should feel like you are being chased)
		
	#logic to loop the player
	if(player.position.x < screen_position.x):
		player.position = screen_size.get_center() + Vector2(screen_ends.x * 0.45, 0)
	elif(player.position.x > screen_ends.x):
		player.position = Vector2(screen_position.x, screen_size.get_center().y)
	elif(player.position.y < screen_position.y):
		player.position = screen_size.get_center() + + Vector2(0, screen_ends.y * 0.45)
	elif(player.position.y > screen_ends.y):
		player.position = Vector2(screen_size.get_center().x, screen_position.y)
	
	for a in $Asteroids.get_children():
		$Asteroids.remove_child(a)
	for i in range(asteroid_count):
		make_asteroid()
	for e in $Enemies.get_children():
		$Enemies.remove_child(e)
	for b in $Bullets.get_children():
		$Bullets.remove_child(b)
	pass # Replace with function body.


func _on_enemy_spawn_timer_timeout() -> void:
	if enemy_current < 5:
		instantiate_enemy()
	pass # Replace with function body.
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
	pass # Replace with function body.
	
func _on_enemy_ship_firing(body : CharacterBody2D, shoot : Node2D):
	var bullet = bullet_scene.instantiate()
	bullet.dir = body.global_rotation
	bullet.pos = shoot.global_position
	bullet.motion_end.connect(Callable(self, "bullet_stopped"))
	$Bullets.add_child(bullet)
	pass

func on_enhanced_enemy_firing(body : CharacterBody2D, muzzle : Node2D):
	"""Handle firing from enhanced enemies with red bullets"""
	var bullet = enemy_bullet_scene.instantiate()
	bullet.dir = body.global_rotation
	bullet.pos = muzzle.global_position
	bullet.speed = 450  # Match player bullet speed
	bullet.is_enemy_bullet = true
	bullet.motion_end.connect(Callable(self, "bullet_stopped"))
	$Bullets.add_child(bullet)
	pass

func update_lives_label(new_health : int) -> void:
	lives_label.text = "Lives: " + str(new_health)

func on_player_death() -> void:
	# Game Over - Load the heart to heart scene
	get_tree().change_scene_to_file("res://Scenes/loseScene.tscn")
	
func win_game() -> void:
	get_tree().change_scene_to_file("res://Scenes/winScene.tscn")
