class_name Asteroid
extends CharacterBody2D


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

var sleeping := false;
var variationKeys = ["big1", "big2", "big3", "big4"]
var colorKeys = ["brown", "grey"]


var screen_size : Rect2
var screen_position : Vector2
var screen_ends : Vector2
var speed := 150
signal killed(body : CharacterBody2D)
signal out(body : CharacterBody2D)

var val := 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	screen_size = get_viewport_rect()
	screen_position = screen_size.position
	screen_ends = screen_size.end
	spawn_at_random_position()
	pass # Replace with function body.
func basic_conditions() -> void:
	var color = colorKeys[randi() % colorKeys.size()]
	var variation = variationKeys[randi() % variationKeys.size()]
	$BigSprite1.texture = variations[color][variation]
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(sleeping):
		return
		#sleep process
	move_and_slide()
	for i in range(get_slide_collision_count()):
		var collide = get_slide_collision(i)
		if collide and collide.get_collider().has_method("_hit_method"):
			killed.emit(self)
			sleeping = true
	if not get_viewport_rect().grow(300).has_point(position):
		out.emit(self)
		return

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
	
func _asteroid_method():
	pass
