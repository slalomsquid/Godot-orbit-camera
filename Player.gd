extends CharacterBody3D

# A basic kinematic character controller
# referenced from https://www.youtube.com/watch?v=UpF7wm0186Q

#@export(NodePath) onready var cameraRig = get_node(cameraRig) as Node3D
#@export(NodePath) onready var characterModel = get_node(characterModel) as Node3D
@export var speed: float = 7.0
@export var jumpStrength: float = 20.0
@export var gravity: float = 50.0

@onready var characterModel = $Capsule
@onready var cameraRig = $CameraRig

var _velocity : Vector3 = Vector3.ZERO
var _snap_vector : Vector3 = Vector3.DOWN

func _physics_process(delta: float) -> void:
	var moveDirection : Vector3 = Vector3.ZERO
	
	# calculate movement direction based on input and look direction
	moveDirection.x = Input.get_axis("move_left", "move_right")
	moveDirection.z = Input.get_axis("move_forward", "move_back")
	moveDirection = moveDirection.rotated(Vector3.UP, cameraRig.rotation.y).normalized()
	
	# apply horizontal movement to velcity
	_velocity.x = moveDirection.x * speed
	_velocity.z = moveDirection.z * speed
	

	if is_on_floor():
		_velocity.y = 0.0
		if Input.is_action_just_pressed("jump"):
			_velocity.y = jumpStrength
	else:
		_velocity.y -= gravity * delta
	
	# finally apply movement
	set_velocity(_velocity)
	# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `_snap_vector`
	set_up_direction(Vector3.UP)
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()
	_velocity = velocity
	
	# rotate player model to face movement direction
	if _velocity.length() > 0.2:
		var lookDir : Vector2 = Vector2(_velocity.z, _velocity.x)
		characterModel.rotation.y = lookDir.angle()
		
