extends RigidBody2D

class_name Bomb


var explosion


func _ready():
	explosion = preload("res://nodes/explosion.tscn")

func _on_body_entered(body):
	print( "Boom!" )
	var expl = explosion.instantiate()
	expl.position = position
	add_sibling(expl)
	queue_free()
