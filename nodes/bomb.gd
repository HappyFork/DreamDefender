extends RigidBody2D

class_name Bomb


### Signals ###
signal exploded( pos )


### Signal functions ###
func _on_body_entered(body):
	if body is StaticBody2D:
		print( "Boom!" )
		exploded.emit( position )
		queue_free()
