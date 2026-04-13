extends Node2D


func _on_detection_area_body_exited(body: Node2D) -> void:
	print("exit : "+body.name)
	if body is RigidBody2D:
		if body.shado :
			body.shado.queue_free()
		body.queue_free()
