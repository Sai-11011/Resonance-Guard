extends Node

@onready var timer : Timer = $Timer
@onready var resources : Dictionary = Global.object_res
@export var spawner : Node2D
@onready var object_scene : PackedScene = load(Global.SCENES.base_object)

var types : Array

func _ready() -> void:
	types = resources.keys()

var stop_point : Vector2 = Vector2.ZERO

func _on_timer_timeout() -> void:
	spawn_object()

func spawn_object():
	var res = select_resource()
	var location = select_location()
	var spawn_location = Vector2(location.x , -250)
	
	var object = object_scene.instantiate()
	object.data = res
	object.global_position = spawn_location
	object.stop_location = location
	spawner.add_child(object)

func select_resource() -> Resource : 
	var type : String
	if Global.is_endless : # for now true always
		type = types.pick_random()
	else :
		pass #For now i am spawning randomply after we add the waves and scale up and chnage weight according to the wave
	return load(Global.object_res[type])

func select_location() -> Vector2 :
	var x = randi_range(-290, 290)
	var y = randi_range(-20, 160)
	
	return Vector2(x,y)
