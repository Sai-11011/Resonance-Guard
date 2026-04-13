extends Node

var STATS : Dictionary ={
	"speed" : 150,
	"strength" : 5
} 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		get_tree().debug_collisions_hint = !get_tree().debug_collisions_hint
		
		get_tree().reload_current_scene()
