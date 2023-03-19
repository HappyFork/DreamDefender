extends Node2D


### Variables ###
@onready var robot = $Robot

@onready var bomb_timer = $BombSpawnTimer
@onready var level_timer = $LevelTimer
@onready var timer_display = $UI/Label
@onready var expl_sound = $ExplosionSound
@onready var fall_sound = $FallingSound

var rnd = 2
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
	
	# I have a bomb automatically spawned in but no sound effect plays so
	fall_sound.play()

func _process(delta):
	timer_display.text = "%d:%02d remaining" % [rnd, level_timer.time_left]


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
	fall_sound.play()

func _on_bomb_exploded( pos ):
	# Make a new sprite and a new tween
	var ex = Sprite2D.new()
	var ex_tween = create_tween()
	
	# Set explosion's sprite & position, then spawn
	ex.texture = explosion
	ex.position = pos
	add_child( ex )
	
	# Play explosion sound
	expl_sound.play()
	
	# Explosion will fade out, then despawn
	ex_tween.tween_property( ex, "modulate", Color(1,1,1,0), 1 ).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	ex_tween.tween_callback( ex.queue_free )
	
	# Wake up closest house within range
	wake_closest_house( pos )

func _on_despawn_area_body_entered(body):
	if body is Bomb:
		body.queue_free()
		fall_sound.stop()

func _on_level_timer_timeout():
	match rnd:
		2:
			rnd = 1
			bomb_timer.wait_time = 4.0
		1:
			rnd = 0
			bomb_timer.wait_time = 3.0
		0:
			get_tree().change_scene_to_file("res://scenes/win.tscn")

func _on_robot_caught():
	fall_sound.stop()
