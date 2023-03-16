extends Node2D


### Variables ###
@onready var robot = $Robot

var arena_width = 974.0 # Used for x-axis range where bombs can spawn
var bomb_spawn_height = -700.0 # The y-axis where bombs spawn
var impulse_variance = 200.0 # Random impulse added to bombs before they fall
var explosion_sound_range = 300.0 # How close a bomb needs to explode to a house to wake it
var houses : Array[House] # Holds the houses in the current scene
var rng = RandomNumberGenerator.new() # Generates random spawn locations
var bomb = preload("res://nodes/bomb.tscn") # Bombs (for spawning)
var explosion = preload("res://assets/boom.png") # Explosions (bombs spawn these when they hit the ground)


### Built-in functions ###
func _ready():
	# When the scene loads, add the houses to the houses array
	for n in get_children():
		if n is House:
			houses.append(n)


### Custom functions ###
func wake_closest_house( pos ):
	# Wake the closest house to the passed-in position, if it's within the explosion range
	var wake_dist = explosion_sound_range
	var wake_house = null
	for h in houses:
		if h.position.distance_to(pos) < wake_dist and h.sleeping:
			wake_dist = h.position.distance_to(pos)
			wake_house = h
	if wake_house != null:
		wake_house.sleeping = false
		robot.remove_part( rng.randi_range(0,1) )


### Signal functions ###
func _on_bomb_spawn_timer_timeout():
	var x_cor = rng.randf_range( -arena_width, arena_width )
	var x_imp = rng.randf_range( -impulse_variance, impulse_variance )
	var b = bomb.instantiate()
	b.position = Vector2( x_cor, bomb_spawn_height )
	b.apply_impulse( Vector2( x_imp, 0.0) )
	b.connect("exploded", _on_bomb_exploded )
	add_child( b )

func _on_bomb_exploded( pos ):
	# Make a new sprite and a new tween
	var exp = Sprite2D.new()
	var exp_tween = get_tree().create_tween()
	
	# Set explosion's sprite & position, then spawn
	exp.texture = explosion
	exp.position = pos
	add_child( exp )
	
	# Explosion will fade out, then despawn
	exp_tween.tween_property( exp, "modulate", Color(1,1,1,0), 1 ).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	exp_tween.tween_callback( exp.queue_free )
	
	# Wake up closest house within range
	wake_closest_house( pos )

func _on_despawn_area_body_entered(body):
	if body is Bomb:
		body.queue_free()
