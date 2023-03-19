extends CharacterBody2D


### Variables ###
@export var speed = 800 # How fast the player moves

@onready var box_sprite = $Box/BoxSprite # The sprite for the bomb-defusal box
@onready var left_wheel = $LeftWheel/WheelSprite # The sprite for the left wheel
@onready var right_wheel = $RightWheel/WheelSprite # The sprite for the right wheel

var box_open = true # Whether the bomb-defusal box can catch bombs
var smoke_offset = Vector2(50.0,-150.0) # Where the smoke cloud will spawn relative to the box
var smoke_rise = Vector2(0,-50) # The amount the smoke cloud will rise before fading away
var parts = 3 # When I make more parts, I should set this in _ready based on the # of houses.
var tilted_rot = 0.4 # Added or removed from rotation when 1 wheel is missing
var tilted_drop = Vector2(0,24) # Added to position when 1 wheel is missing
var wheelless_drop = Vector2(0,14) # Added to position when both wheels are missing
var box_open_sprite = preload("res://assets/BombBoxOpen.png") # Box is open sprite
var box_closed_sprite = preload("res://assets/BombBoxClosed.png") # Box is closed sprite
var smoke_cloud = preload("res://assets/smokecloud.png") # Smoke cloud node

signal caught


### Built-in functions ###
func _physics_process(delta):
	# Move
	var direction = Input.get_axis("move_left","move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	move_and_slide()
	
	# Rotate tires
	if get_slide_collision_count() == 0 and direction > 0:
		left_wheel.rotation += 5.0 * delta
		right_wheel.rotation += 5.0 * delta
	elif get_slide_collision_count() == 0 and direction < 0:
		left_wheel.rotation -= 5.0 * delta
		right_wheel.rotation -= 5.0 * delta


### Custom Functions ###
func remove_part( rand ):
	match parts:
		3:
			if rand == 0:
				left_wheel.hide()
				rotation = -tilted_rot
			else:
				right_wheel.hide()
				rotation = tilted_rot
			position += tilted_drop
			speed = 400
		2:
			left_wheel.hide()
			right_wheel.hide()
			position += wheelless_drop
			rotation = 0
			speed = 100
		1:
			get_tree().change_scene_to_file("res://scenes/lose.tscn")
	
	parts = parts - 1


### Signal functions ###
func _on_catch_body_entered(body):
	if body is Bomb and box_open:
		emit_signal("caught")
		body.queue_free()
		box_open = false
		box_sprite.texture = box_closed_sprite
		var box_timer = get_tree().create_timer(1.0)
		box_timer.connect("timeout", _on_timer_timeout)

func _on_timer_timeout():
	var box_tween = create_tween()
	box_tween.connect("finished", _on_tween_finished)
	box_tween.tween_property(box_sprite, "scale", Vector2(1.2,1.2), 0.5)

func _on_tween_finished():
	# Make a new sprite and a new tween
	var sc = Sprite2D.new()
	var smoke_tween = create_tween()
	
	# Set smoke cloud's sprite & position, then spawn
	sc.texture = smoke_cloud
	sc.position = position + smoke_offset
	add_sibling(sc)
	
	# Smoke cloud will rise and fade away, and then despawn once faded out
	smoke_tween.set_parallel( true )
	smoke_tween.tween_property( sc, "modulate", Color(1,1,1,0), 1 ).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	smoke_tween.tween_property( sc, "position", sc.position + smoke_rise, 1 )
	smoke_tween.set_parallel( false )
	smoke_tween.tween_callback( sc.queue_free )
	
	# Reset the box to open
	box_sprite.scale = Vector2(1,1)
	box_sprite.texture = box_open_sprite
	box_open = true
