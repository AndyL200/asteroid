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

var variationKeys = ["big1", "big2", "big3", "big4", "med1", "med2", "small1", "small2", "tiny1", "tiny2"]
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
	var query = ""
	print(self.name)
	if "big" in self.name.to_lower():
		query = "big"
	elif "med" in self.name.to_lower():
		query = "med"
	elif "small" in self.name.to_lower():
		query = "small"
	elif "tiny" in self.name.to_lower():
		query = "tiny"
		
	var q_count = 0
	var q_size = variationKeys.size()
	while q_count < q_size:
		if query not in variationKeys[q_count]:
			variationKeys.remove_at(q_count)
			q_size-= 1
			q_count-=1
		q_count+=1
	
	screen_size = get_viewport_rect()
	screen_position = screen_size.position
	screen_ends = screen_size.end
	
	strikeTime.wait_time = 3
	
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
	
func _process(delta: float) -> void:
	#should accelerate at some point
	#Use a timer for strikes
	position += force_direction * speed * delta
	if(position.x > screen_ends.x or position.y > screen_ends.y or position.x < screen_position.x or position.y < screen_position.y):
		strikeTime.start()
	pass


func _on_strike_time_timeout() -> void:
	strikes += 1
	if strikes >= 2:
		strikeout.emit(self)
	pass # Replace with function body.
