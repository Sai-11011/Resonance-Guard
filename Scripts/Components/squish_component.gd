extends Node
class_name SquishComponent

@export var sprite : Node2D

var time: float = 0.0

@export var idle_speed: float = 3.0
@export var walk_speed: float = 12.0

var is_walking: bool = false

func  _process(delta: float) -> void:
	time += delta
	var current_speed = walk_speed if is_walking else idle_speed
	var wave = sin(time * current_speed)
	var frequency = 2
	
	if is_walking:
		# Y-Scale between 0.8 and 1.0 (Center is 0.9, +/- 0.1)
		sprite.scale.y = 0.9 + (wave * 0.1)
		# Rotation between -4 and +4
		sprite.rotation_degrees = wave * 4.0 * frequency
	else:
		# Y-Scale between 0.9 and 1.0 (Center is 0.95, +/- 0.05)
		sprite.scale.y = 0.95 + (wave * 0.05)
		# Rotation between -2 and +2
		sprite.rotation_degrees = wave * 2.0 * frequency
