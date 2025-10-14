class_name Asteroid
extends CharacterBody2D


var variations : Dictionary
var sleeping := false;
@onready var variationKeys = ["big1", "big2", "big3", "big4"]
var colorKeys = ["brown", "grey"]


var screen_size : Rect2
var screen_position : Vector2
var screen_ends : Vector2
var speed := 150
signal strikeout(body : CharacterBody2D)
signal killed(body : CharacterBody2D)

var val := 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var color = colorKeys[randi() % colorKeys.size()]
	var variation = variationKeys[randi() % variationKeys.size()]
	$BigSprite1.texture = variations[color][variation]
	screen_size = get_viewport_rect()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func onscreen():
	return not (global_position.x > screen_ends.x or global_position.x < screen_position.x or global_position.y > screen_ends.y or global_position.y < screen_position.y)
func _physics_process(delta: float) -> void:
	if(sleeping):
		return
	if(not onscreen()):
		strikeout.emit(self)
		return
		#sleep process
	var collide = move_and_collide(velocity * delta)
	if collide and collide.get_collider().has_method("_hit_method"):
		killed.emit(self)
		sleeping = true
		return
	
func _asteroid_method():
	pass
