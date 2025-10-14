class_name Game
extends Node2D

#exports
@export var score_label : Label
@export var lives_label : Label
@export var enemy_timer : Timer
@export var player : CharacterBody2D


#Notes
#TODO(make a scene for the enemies)
var variations = {
	"brown" : {
	"big1" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorBrown_big1.png"), 
	"big2" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorBrown_big2.png"),
	"big3" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorBrown_big3.png"),
	"big4" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorBrown_big4.png"),
	},
	
	"grey" : {
	"big1" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorGrey_big1.png"), 
	"big2" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorGrey_big2.png"),
	"big3" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorGrey_big3.png"),
	"big4" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorGrey_big4.png"),
	}
}

var asteroid_positions = []
var curr_ast_post = 0;

func add_ast_poss(i : int) ->void:
	curr_ast_post = (curr_ast_post + i) % asteroid_positions.size()
	pass
#get screen size
var screen_size : Rect2
var screen_position : Vector2
var screen_ends : Vector2

#scenes
@onready var enemy_scene := preload("res://Scenes/enemy_black_1_scene.tscn")
@onready var asteroid_scene_big := preload("res://Scenes/asteroid_template_big.tscn")
@onready var bullet_scene := preload("res://Scenes/bullet_scene.tscn")
@onready var enemy_bullet_scene := preload("res://Scenes/enemy_bullet_scene.tscn")

#counts
var asteroid_count = 10
var score = 0
#counter (may need to be atomic)
var enemy_current = 0

# Game state management
var is_game_over := false

func update_score(points : int):
	score += points
	score_label.text = str(score)
	if score == 20:
		win_game()
	pass
func make_asteroid():
	var a = asteroid_scene_big.instantiate()
	a.variations = variations
	a.killed.connect(Callable(self, "dead_asteroid"))
	a.global_position = asteroid_positions[curr_ast_post].global_position;
	add_ast_poss(1)
	a.velocity = (player.global_position - a.global_position).normalized() * a.speed
	#ready function called when added to scene tree
	$Asteroids.add_child(a)
	
	#set the force direction here
	

func dead_asteroid(body : CharacterBody2D):
	if body in $Asteroids.get_children():
		# Play asteroid destruction sound (using zap sound effect)
		var destruction_sound = AudioStreamPlayer.new()
		destruction_sound.stream = preload("res://Asset/KenneySpaceShooter/Bonus/sfx_zap.ogg")
		add_child(destruction_sound)
		destruction_sound.play()
		# Clean up sound after playing
		destruction_sound.finished.connect(destruction_sound.queue_free)
		
		update_score(body.val)
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
	#This is wrong this needs to be based on a signal
	$Enemies.remove_child(enemy)
	enemy_current -= 1
	
	
func _ready() -> void:
	asteroid_positions = [$Asteroids/spawn/spawn1, $Asteroids/spawn/spawn2, $Asteroids/spawn/spawn3,  $Asteroids/spawn/spawn4]
	screen_size = get_viewport_rect()
	screen_position = screen_size.position
	screen_ends = screen_size.end
	score_label.position = screen_size.get_center() - Vector2(0, screen_ends.y*0.45)
	#should start already stopped
	enemy_timer.wait_time = 1
	enemy_timer.autostart = true
	
	# Initialize lives label
	update_lives_label(player.health)
	#player.health_changed.connect(Callable(self, "update_lives_label"))
	#player.death.connect(Callable(self, "on_player_death"))
	
	for i in range(asteroid_count):
		call_deferred("make_asteroid")
	pass

func _process(delta: float) -> void:
	# Stop all game processes if game is over
	if is_game_over:
		return
		
	#TODO(Interpolate an angle for each swap)
	for e in $Enemies.get_children():
		# Update player position for enhanced enemies
		if e.has_method("set_player_position"):
			e.set_player_position(player.position)
		
	pass



func ship_out_of_bounds(player: CharacterBody2D) -> void:
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
		if a.has_method("_asteroid_method"):
			remove_asteroid(a)
			a.queue_free()
	for i in range(asteroid_count):
		call_deferred("make_asteroid")
	for e in $Enemies.get_children():
		if e.has_method(""):
			remove_enemy(e)
			e.queue_free()
	for b in $Bullets.get_children():
		$Bullets.remove_child(b)
		b.queue_free()
		
	enemy_timer.start()
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

func on_enhanced_enemy_firing(body : CharacterBody2D, spawn_marker : Node2D):
	"""Handle firing from enhanced enemies with red bullets"""
	var bullet = enemy_bullet_scene.instantiate()
	
	# Configure bullet properties using the calculated spawn position from enemy
	bullet.dir = body.global_rotation  # Fire in direction enemy is facing
	bullet.pos = spawn_marker.global_position  # Use calculated spawn position (in front of enemy)
	bullet.speed = 450  # Match player bullet speed  
	bullet.is_enemy_bullet = true  # Mark as enemy bullet for collision detection
	bullet.shooter_reference = body  # Pass shooter reference to prevent self-collision
	
	# Connect cleanup signal and add to scene
	bullet.motion_end.connect(Callable(self, "bullet_stopped"))
	$Bullets.add_child(bullet)
	pass

func update_lives_label(new_health : int) -> void:
	lives_label.text = "Lives: " + str(new_health)

func on_player_death() -> void:
	# Game Over - Play sound, stop all gameplay, and transition to lose scene
	# Set game over flag to stop all gameplay processes
	is_game_over = true
	
	# Stop enemy spawning
	enemy_timer.stop()
	
	# Play game over sound effect from assets folder
	if is_inside_tree():
		var game_over_sound = AudioStreamPlayer.new()
		game_over_sound.stream = preload("res://Asset/KenneySpaceShooter/Bonus/sfx_lose.ogg")
		add_child(game_over_sound)
		game_over_sound.play()
		
		# Wait for sound to finish playing before changing scene
		await game_over_sound.finished
		
		# Clean up sound player and change scene
		game_over_sound.queue_free()
		if is_inside_tree():
			get_tree().change_scene_to_file("res://Scenes/loseScene.tscn")
	
func win_game() -> void:
	# Victory - Stop all gameplay and transition to win scene
	# Set game over flag to stop all gameplay processes
	is_game_over = true
	
	# Stop enemy spawning
	enemy_timer.stop()
	
	if is_inside_tree():
		# Play victory sound effect
		var victory_sound = AudioStreamPlayer.new()
		victory_sound.stream = preload("res://Asset/KenneySpaceShooter/Bonus/jingle.ogg")
		add_child(victory_sound)
		victory_sound.play()
		
		# Wait for sound to play before changing scene
		await victory_sound.finished
		
		# Clean up sound player and change scene
		victory_sound.queue_free()
		if is_inside_tree():
			get_tree().change_scene_to_file("res://Scenes/winScene.tscn")


func _on_screen_area_body_exited(body: Node2D) -> void:
	if body.has_method("_asteroid_method"):
		remove_asteroid(body)
	elif body.has_method("_enemy_method"):
		remove_enemy(body)
	elif body.has_method("_player_method"):
		ship_out_of_bounds(body)
	pass # Replace with function body.
