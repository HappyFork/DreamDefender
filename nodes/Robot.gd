extends CharacterBody2D


@export var speed = 150

@onready var box_sprite = $Box/BoxSprite

var box_open = true
var box_open_sprite
var box_closed_sprite


func _ready():
	box_open_sprite = preload("res://assets/BombBoxOpen.png")
	box_closed_sprite = preload("res://assets/BombBoxClosed.png")

func _physics_process(delta):
	# Move
	var direction = Input.get_axis("move_left","move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	move_and_slide()


func _on_catch_body_entered(body):
	if body is Bomb and box_open:
		body.queue_free()
		box_open = false
		box_sprite.texture = box_closed_sprite
		var box_timer = get_tree().create_timer(1.0)
		box_timer.connect("timeout", _on_timer_timeout)

func _on_timer_timeout():
	var tween = get_tree().create_tween()
	tween.connect("finished", _on_tween_finished)
	tween.tween_property(box_sprite, "scale", Vector2(1.2,1.2), 0.5)

func _on_tween_finished():
	box_sprite.scale = Vector2(1,1)
	box_sprite.texture = box_open_sprite
	box_open = true
