extends Node2D


var main = preload("res://scenes/main.tscn")


func _on_button_pressed():
	get_tree().change_scene_to_packed( main )
