extends CharacterBody2D

var stats = PlayerData.STATS
var is_stunned: bool = false

# Components
@onready var squish_component : Node = $Components/SquishComponent
@onready var expression_manager : Node = $Components/ExpressionManager

# Animation
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var player_sprites :={
	"left_leg" : $PlayerSprites/LeftLeg,
	"right_leg" : $PlayerSprites/RightLeg,
	"body" : $PlayerSprites/Body,
	"expressions": $PlayerSprites/Expressions 
}

func _physics_process(_delta: float) -> void:
	if is_stunned:
		return

	var direction = Input.get_vector("left","right","up","down")
	velocity = direction * stats.speed
	
	# 1. Check heavy objects and adjust velocity BEFORE moving
	var is_pushing = handle_pushing()
	
	# 2. Now we move
	move_and_slide()
	
	# 3. Check if anything just fell on us during that movement
	check_for_falling_objects()
	
	# If the check above just stunned us, stop updating animations for this frame
	if is_stunned:
		return
	
	# 4. Handle the Waddle Animation natively
	if direction != Vector2.ZERO:
		squish_component.is_walking = true
	else:
		squish_component.is_walking = false
		
	# 5. Handle the Face Expressions
	if is_pushing:
		if expression_manager.current_state != expression_manager.State.PUSHING:
			expression_manager.change_state(expression_manager.State.PUSHING)
	elif direction != Vector2.ZERO:
		if expression_manager.current_state != expression_manager.State.WALKING:
			expression_manager.change_state(expression_manager.State.WALKING)
	else:
		if expression_manager.current_state != expression_manager.State.IDLE:
			expression_manager.change_state(expression_manager.State.IDLE)


func handle_pushing() -> bool:
	var pushable_objects = []
	var total_mass: float = 0.0
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var body = collision.get_collider()

		if body is BaseObject:
			pushable_objects.append(body)
			total_mass += body.mass
	
	if pushable_objects.is_empty() or velocity.length() == 0:
		return false
	
	if stats.strength >= total_mass:
		var force_magnitude = (stats.strength * 10.0) / total_mass
		for object in pushable_objects:
			var push_force = velocity.normalized() * force_magnitude * object.mass
			object.apply_central_impulse(push_force)
		return true
	else:
		for object in pushable_objects:
			var dir_to_object = global_position.direction_to(object.global_position)
			if velocity.dot(dir_to_object) > 0:
				var surface_normal = -dir_to_object
				velocity = velocity.slide(surface_normal)
		return true

func handle_walking_state() -> void:
	squish_component.is_walking = true
	if expression_manager.current_state != expression_manager.State.WALKING:
		expression_manager.change_state(expression_manager.State.WALKING)

func handle_idle_state() -> void:
	squish_component.is_walking = false
	if expression_manager.current_state != expression_manager.State.IDLE:
		expression_manager.change_state(expression_manager.State.IDLE)

# ==========================================
# STUN LOGIC
# ==========================================

func check_for_falling_objects() -> void:
	# Loop through everything we are touching right now
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var body = collision.get_collider()

		# If it's an object and it hasn't landed yet, it means it fell onto us
		if body is BaseObject and not body.has_landed:
			body.force_land()
			apply_stun(1.0, body.mass)
			break # Stop checking, one hit is enough to trigger the stun

func apply_stun(duration: float, object_mass: float) -> void:
	if object_mass > stats.strength:
		print("CRUSHED! Game Over.")
		expression_manager.change_state(expression_manager.State.DEAD)
		is_stunned = true
		return 
		
	print("Stunned!")
	is_stunned = true
	expression_manager.change_state(expression_manager.State.STUNNED)
	
	# Stop visual walking effects
	squish_component.is_walking = false
	
	# Wait for the duration
	await get_tree().create_timer(duration).timeout
	
	# Recover if not dead
	if expression_manager.current_state != expression_manager.State.DEAD:
		is_stunned = false
		expression_manager.change_state(expression_manager.State.IDLE)
