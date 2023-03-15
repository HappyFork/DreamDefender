extends Node2D


### Variables ###
var arena_width = 974.0 # Used for x-axis range where bombs can spawn
var bomb_spawn_height = -700.0 # The y-axis where bombs spawn
var rng = RandomNumberGenerator.new() # Generates random spawn locations
var bomb = preload("res://nodes/bomb.tscn") # Bombs (for spawning)
var explosion = preload("res://assets/boom.png") #preload("res://nodes/explosion.tscn") # Explosions (bombs spawn these when they hit the ground)


### Built-in functions ###
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	# Get all the nodes in the scene that are TinyHouses


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


### Signal functions ###
func _on_bomb_spawn_timer_timeout():
	var x_cor = rng.randf_range( -arena_width, arena_width )
	var b = bomb.instantiate()
	b.position = Vector2( x_cor, bomb_spawn_height )
	# I think it would be fun to add a random x-axis impulse
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
