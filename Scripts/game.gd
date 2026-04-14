extends Node2D


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		if body.global_position.y > -48:
			body.z_index = -1
		elif body.global_position.y > 170:
			# Force it to render on top of EVERYTHING as it falls down the screen
			body.z_index = 1
		if is_instance_valid(body.shado):
			body.shado.queue_free()
		body.collision_mask = 0
		body.collision_layer = 0
		body.gravity_scale = 1.0
