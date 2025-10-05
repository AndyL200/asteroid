extends CharacterBody2D

var screen_size : Rect2
var screen_position : Vector2
var screen_ends : Vector2
signal outOfBounds(player : CharacterBody2D)
signal firing(body : CharacterBody2D, shootingPosition : Node2D)

var max_speed: float = 300.0
var acceleration: float = 600.0
var friction: float = 200.0
var turn_speed: float = 3.0
var orientation_offset_deg: float = 90.0

func _ready() -> void:
	screen_size = get_viewport_rect()
	screen_position = screen_size.position
	screen_ends = screen_size.end

func _physics_process(delta: float) -> void:
	if(position.x > screen_ends.x or position.y > screen_ends.y):
		outOfBounds.emit(self)
	if(position.x < screen_position.x or position.y < screen_position.y):
		outOfBounds.emit(self)
		
		
	var input_dir: Vector2 = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")

	if input_dir.length() > 0.0:
		var desired_velocity := input_dir.normalized() * max_speed
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)

		var target_angle := input_dir.angle() + deg_to_rad(orientation_offset_deg)
		rotation = lerp_angle(rotation, target_angle, min(1.0, turn_speed * delta))
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	if Input.is_action_just_pressed("Shoot"):
		firing.emit(self, $Pellet)

	move_and_slide()	
