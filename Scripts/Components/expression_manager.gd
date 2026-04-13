extends Node
class_name ExpressionManager

@export var sprite: Sprite2D 

enum State {STUNNED, IDLE, WALKING, DANGER, PUSHING, WON, DEAD}
var current_state: State = State.IDLE

func change_state(new_state: State) -> void:
	if current_state == State.DEAD:
		return 
		
	current_state = new_state
	
	match current_state:
		State.STUNNED:
			sprite.frame = 0 
		State.IDLE:
			sprite.frame = 1 
		State.WALKING:
			sprite.frame = 2 
		State.DANGER:
			sprite.frame = 3 
		State.PUSHING:
			sprite.frame = 4 
		State.WON:
			sprite.frame = 5 
		State.DEAD:
			sprite.frame = 6
