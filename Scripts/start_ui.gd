extends Control

@onready var game_scene : PackedScene = load(Global.SCENES.game)

func _ready() -> void:
	get_tree().paused = true

func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(game_scene)
