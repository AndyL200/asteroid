class_name Asteroid
extends CharacterBody2D

@export var strikeTime : Timer
@export var sprite : Sprite2D

var variations = {
	"brown" : {
	"big1" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorBrown_big1.png"), 
	"big2" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorBrown_big2.png"),
	"big3" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorBrown_big3.png"),
	"big4" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorBrown_big4.png"),
	"med1" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorBrown_med1.png"),
	"med2" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorBrown_med3.png"),
	"small1" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorBrown_small1.png"),
	"small2" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorBrown_small2.png"),
	"tiny1" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorBrown_tiny1.png"),
	"tiny2" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorBrown_tiny2.png")
	},
	
	"grey" : {
	"big1" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorGrey_big1.png"), 
	"big2" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorGrey_big2.png"),
	"big3" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorGrey_big3.png"),
	"big4" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorGrey_big4.png"),
	"med1" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorGrey_med1.png"),
	"med2" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorGrey_med2.png"),
	"small1" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorGrey_small1.png"),
	"small2" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorGrey_small2.png"),
	"tiny1" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorGrey_tiny1.png"),
	"tiny2" : Image.load_from_file("res://Asset/KenneySpaceShooter/PNG/Meteors/meteorGrey_tiny2.png")
	}
}

@onready var variationKeys = []
var bigVary = ["big1", "big2", "big3", "big4"]
var medVary = ["med1", "med2"]
var smallVary = ["small1", "small2"]
var tinyVary = ["tiny1", "tiny2"]
var colorKeys = ["brown", "grey"]


@onready var force_direction = Vector2.ZERO
var screen_size : Rect2
var screen_position : Vector2
var screen_ends : Vector2
var strikes := 0
var speed := 150
signal strikeout(body : CharacterBody2D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var type = $Container.get_child(0)
	if "big" in type.name.to_lower():
		variationKeys += bigVary
	elif "med" in type.name.to_lower():
		variationKeys += medVary
	elif "small" in type.name.to_lower():
		variationKeys += smallVary
	else:
		variationKeys += tinyVary
	
	screen_size = get_viewport_rect()
	screen_position = screen_size.position
	screen_ends = screen_size.end
	
	strikeTime.wait_time = 5
	strikeTime.stop()
	
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
	if(position.x > screen_ends.x or position.y > screen_ends.y or position.x < screen_position.x or position.y < screen_position.y):
		if strikeTime.is_stopped():
			strikeTime.start()
	move_and_slide()
	pass


func _on_strike_time_timeout() -> void:
	strikes += 1
	if strikes >= 2:
		strikeout.emit(self)
	pass # Replace with function body.
