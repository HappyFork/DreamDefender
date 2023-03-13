extends Node2D


@export var speed = 10


func _physics_process(delta):
	# Move
	var direction = Input.get_axis("move_left","move_right")
	if direction:
		position.x = position.x + (direction * speed)
