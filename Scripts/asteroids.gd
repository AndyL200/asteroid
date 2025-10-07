class_name Asteroid
extends CharacterBody2D

@export var sprite : Sprite2D

var variations : Dictionary

@onready var variationKeys = ["big1", "big2", "big3", "big4"]
var colorKeys = ["brown", "grey"]


var screen_size : Rect2
var screen_position : Vector2
var screen_ends : Vector2
var speed := 150
var max_speed := 250
var onscreen
signal strikeout(body : CharacterBody2D)
signal killed(body : CharacterBody2D)

var val := 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	screen_size = get_viewport_rect()
	screen_position = screen_size.position
	screen_ends = screen_size.end
	onscreen = false
	var upper_bound = Vector2(screen_ends.x, screen_ends.y)
	#redundant
	var lower_bound = Vector2(screen_position.x, screen_position.y)
	var lower_naught = randf_range(upper_bound.x, lower_bound.x)
	var high_or_low_x = [(randi() % 101 + lower_naught), (lower_naught - randi() % 101)]
	var high_naught = randf_range(upper_bound.y, lower_bound.y)
	var high_or_low_y = [(randi() % 101 + high_naught), (high_naught - randi() % 101)]
	var poss = Vector2(high_or_low_x[randi() % 2],high_or_low_y[randi() % 2])
	global_position = poss
	var color = colorKeys[randi() % colorKeys.size()]
	var variedKeys = variationKeys[randi() % variationKeys.size()]
	var variation = variations[color][variedKeys]
	var image = variation
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	velocity = Vector2.ZERO
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
	
func _physics_process(delta: float) -> void:
	#should accelerate at some point
	#Use a timer for strikes
	#position += force_direction * speed * delta
	if velocity != Vector2.ZERO:
		if global_position.x <= screen_ends.x and global_position.x >= screen_position.x and global_position.y <= screen_ends.y and global_position.y >= screen_position.y:
			onscreen = true 
		if (onscreen and global_position.x > screen_ends.x+100 or global_position.x < screen_position.x-100 or global_position.y > screen_ends.y+100 or global_position.y < screen_position.y-100):
			strikeout.emit(self)
			set_physics_process(false)
			
		move_and_slide()
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			# Check if hit by bullet
			if collider and collider.has_method("_hit_method") and onscreen:
				killed.emit(self)
			# Check if colliding with another asteroid for bouncing (ignore enemies)
			elif collider and collider.has_method("_asteroid_method"):
				# Simple bounce physics - reverse velocity component along collision normal
				var collision_normal = (collider.global_position-global_position).normalized() * 150
				velocity = collision_normal * delta
				# Add some random variation to prevent perfect bouncing cycles
				velocity += Vector2(randf_range(-20, 20), randf_range(-20, 20))
			
			velocity = 1.5 * velocity
	pass
	
func _asteroid_method():
	pass
