extends Sprite2D


func _ready():
	var fade = get_tree().create_tween()
	fade.connect( "finished", _on_tween_finished )
	fade.tween_property( self, "modulate", Color(1,1,1,0), 1 )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_tween_finished():
	queue_free()
