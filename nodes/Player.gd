extends CharacterBody2D


@export var speed = 150


func _physics_process(delta):
	# Move
	var direction = Input.get_axis("move_left","move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	move_and_slide()
	
	# Check collisions
	for c in get_slide_collision_count():
		var colob = get_slide_collision(c).get_collider()
		if colob is RigidBody2D:
			colob.queue_free()
