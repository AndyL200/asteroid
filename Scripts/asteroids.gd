class_name Asteroid
extends CharacterBody2D

@export var sprite : Sprite2D

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

@onready var variationKeys = ["big1", "big2", "big3", "big4"]
var colorKeys = ["brown", "grey"]


var screen_size : Rect2
var screen_position : Vector2
var screen_ends : Vector2
var speed := 150
var max_speed := 250
signal strikeout(body : CharacterBody2D)
signal killed(body : CharacterBody2D)

var val := 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	screen_size = get_viewport_rect()
	screen_position = screen_size.position
	screen_ends = screen_size.end
	
	var upper_bound = Vector2(screen_ends.x, screen_ends.y)
	#redundant
	var lower_bound = Vector2(screen_position.x, screen_position.y)
	var high_or_low_x = [(randi() % 101 + upper_bound.x), (lower_bound.x - randi() % 101)]
	var high_or_low_y = [(randi() % 101 + upper_bound.y), (lower_bound.y - randi() % 101)]
	var poss = Vector2(high_or_low_x[randi() % 2],high_or_low_y[randi() % 2])
	position = poss
	var color = colorKeys[randi() % colorKeys.size()]
	var variedKeys = variationKeys[randi() % variationKeys.size()]
	var variation = variations[color][variedKeys]
	var image = variation
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
	
func _physics_process(delta: float) -> void:
	#should accelerate at some point
	#Use a timer for strikes
	#position += force_direction * speed * delta
	if (position.x > screen_ends.x + 200 or position.x < screen_position.x - 200 or position.y > screen_ends.y + 200 or position.y < screen_position.y - 200):
		strikeout.emit(self)
		set_physics_process(false)
	if velocity.length() > max_speed * 2:
		velocity = velocity.normalized()
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Check if hit by bullet
		if collider and collider.has_method("_hit_method"):
			killed.emit(self)
		# Check if colliding with another asteroid for bouncing
		elif collider and collider.get_script() == get_script():
			# Simple bounce physics - reverse velocity component along collision normal
			var collision_normal = collision.get_normal()
			velocity = velocity.bounce(collision_normal)
			# Add some random variation to prevent perfect bouncing cycles
			velocity += Vector2(randf_range(-20, 20), randf_range(-20, 20))
	pass
