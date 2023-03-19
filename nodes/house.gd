extends Sprite2D

class_name House


var sleeping = true
var z_offset = Vector2(40.0, -20.0)
var z_rise = Vector2(50.0, -50.0)
var z = preload("res://assets/z.png")


func _on_z_timer_timeout():
	if sleeping:
		# Make a new sprite and a new tween
		var new_z = Sprite2D.new()
		var tween = create_tween()
	
		# Set z's sprite & position, then spawn
		new_z.texture = z
		new_z.position = position + z_offset
		add_sibling(new_z)
	
		# z will rise and fade away, and then despawn once faded out
		tween.set_parallel( true )
		tween.tween_property( new_z, "modulate", Color(1,1,1,0), 1 ).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		tween.tween_property( new_z, "position", new_z.position + z_rise, 1 )
		tween.tween_property( new_z, "scale", Vector2(0.2,0.2), 1 )
		tween.set_parallel( false )
		tween.tween_callback( new_z.queue_free )
