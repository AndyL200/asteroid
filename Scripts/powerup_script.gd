class_name PowerUp
extends Area2D

enum PowerUpType {
	RAPID_FIRE,
	SHIELD,
	EXTRA_LIFE
}

@export var powerup_type: PowerUpType = PowerUpType.RAPID_FIRE
@export var lifetime: float = 5.0
@export var float_speed: float = 30.0
@export var float_amplitude: float = 10.0

var lifetime_timer: Timer
var start_position: Vector2
var float_offset: float = 0.0

signal collected(powerup: PowerUp, type: PowerUpType)

func _ready() -> void:
	start_position = global_position
	
	setup_lifetime_timer()
	
	body_entered.connect(_on_body_entered)
	
	setup_powerup_visuals()
	
	start_floating_animation()

func setup_lifetime_timer() -> void:
	lifetime_timer = Timer.new()
	lifetime_timer.wait_time = lifetime
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(_on_lifetime_expired)
	add_child(lifetime_timer)
	lifetime_timer.start()

func setup_powerup_visuals() -> void:
	var sprite = $AnimatedSprite2D
	var texture_path: String
	
	match powerup_type:
		PowerUpType.RAPID_FIRE:
			texture_path = "res://Asset/KenneySpaceShooter/PNG/Power-ups/powerupRed_bolt.png"
		PowerUpType.SHIELD:
			texture_path = "res://Asset/KenneySpaceShooter/PNG/Power-ups/powerupBlue_shield.png"
		PowerUpType.EXTRA_LIFE:
			texture_path = "res://Asset/KenneySpaceShooter/PNG/Power-ups/powerupGreen_star.png"
	
	var texture = load(texture_path)
	if texture:
		var sprite_frames = SpriteFrames.new()
		sprite_frames.add_animation("default")
		sprite_frames.add_frame("default", texture)
		sprite.sprite_frames = sprite_frames
		sprite.play("default")

func start_floating_animation() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_method(_update_float_position, 0.0, TAU, 2.0)

func _update_float_position(angle: float) -> void:
	if is_inside_tree():
		var offset = Vector2(0, sin(angle) * float_amplitude)
		global_position = start_position + offset

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("_player_method"):
		play_pickup_sound()
		
		collected.emit(self, powerup_type)
		
		queue_free()

func play_pickup_sound() -> void:
	var pickup_sound = AudioStreamPlayer.new()
	pickup_sound.stream = preload("res://Asset/KenneySpaceShooter/Bonus/sfx_shieldUp.ogg")
	get_parent().add_child(pickup_sound)
	pickup_sound.play()
	pickup_sound.finished.connect(pickup_sound.queue_free)

func _on_lifetime_expired() -> void:
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	fade_tween.tween_callback(queue_free)

func set_powerup_type(type: PowerUpType) -> void:
	powerup_type = type
	if is_inside_tree():
		setup_powerup_visuals()
