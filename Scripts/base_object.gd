extends RigidBody2D
class_name BaseObject

@export var data: ShapeData 
var edges: int = 0
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision : CollisionShape2D = $CollisionShape2D
var stop_location : Vector2
@onready var shadow : PackedScene = load(Global.SCENES.shadow)
var shado : Node2D
var has_landed: bool = false

func _ready() -> void:
	if data == null:
		push_warning("BaseObject has no ShapeData assigned!")
		return
		
	mass = data.mass
	
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.friction = data.friction
	physics_material_override.bounce = data.bounciness
	
	sprite.frame = data.frame_index
	
	if data.collision_shape :
		collision.shape = data.collision_shape
		
	if data.frame_index >= 3 and data.frame_index <= 5:
		edges = 6 # Diamond
	elif data.frame_index >= 6 and data.frame_index <= 8:
		edges = 3 # Triangle
	else:
		edges = 0 # Circle
	
	if shadow and stop_location :
		shado = shadow.instantiate()
		shado.global_position = stop_location
		get_parent().add_child(shado) #child for the spawner

func _physics_process(_delta: float) -> void:
	# 1. Have we fallen down to or past our stop location?
	if not has_landed and global_position.y >= stop_location.y:
		has_landed = true
		
		# 2. Turn off gravity
		gravity_scale = 0
		
		# 3. CRITICAL: Kill the downward momentum so it stops instantly 
		# instead of drifting further down before the physics engine updates
		linear_velocity.y = 0 
		
		# 4. Safely delete the shadow
		if is_instance_valid(shado):
			shado.queue_free()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# 1. Do we have flat edges? Are we moving slowly enough to settle?
	if edges > 0 and abs(state.angular_velocity) < 1.5:
		
		# 2. Calculate the angles (120 degrees for triangle, 90 for diamond)
		var step = (PI * 2.0) / float(edges)
		var target_rotation = round(rotation / step) * step
		
		# 3. Find the difference between our current angle and the flat angle
		var angle_diff = angle_difference(rotation, target_rotation)
		
		# 4. Apply a gentle twisting force (torque) to snap it flat!
		# The heavier the object, the harder we twist it.
		state.apply_torque(angle_diff * mass * 800.0)

func force_land() -> void:
	if not has_landed:
		has_landed = true
		gravity_scale = 0
		linear_velocity.y = 0
		if is_instance_valid(shado):
			shado.queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
