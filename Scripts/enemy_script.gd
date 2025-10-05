class_name Enemy
extends CharacterBody2D


var screen_size : Rect2
var screen_position : Vector2
var screen_ends : Vector2
var speed := 150
var player_position : Vector2
signal death(body : CharacterBody2D)
signal firing(body : CharacterBody2D)
signal killed(body : CharacterBody2D)

func _ready()->void:
	var upper_bound = Vector2(screen_ends.x, screen_ends.y)
	var lower_bound = Vector2(screen_position.x, screen_position.y)
	var high_or_low_x = [(randi() % 101 + upper_bound.x), (lower_bound.x - randi() % 101)]
	var high_or_low_y = [(randi() % 101 + upper_bound.y), (lower_bound.y - randi() % 101)]
	var poss = Vector2(high_or_low_x[randi() % 2],high_or_low_y[randi() % 2])
	position = poss
	

func _physics_process(delta: float) -> void:
	if (abs((player_position - position).length()) > 100):
		velocity = (player_position - position).normalized() * speed
	else:
		velocity = Vector2.ZERO
		firing.emit(self, $bullet_position)
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.has_method("_hit_method"):
			killed.emit(self)
	pass
