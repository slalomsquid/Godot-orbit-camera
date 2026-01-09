extends Node3D

# Simple orbit camera rig control script

# control variables
@export var maxPitchDeg : float = 45
@export var minPitchDeg : float = -45
@export var maxZoom : float = 50
@export var minZoom : float = 4
@export var zoomStep : float = 2
@export var zoomYStep : float = 0.15
@export var verticalSensitivity : float = 0.002
@export var horizontalSensitivity : float = 0.002
@export var camYOffset : float = 50.0
@export var camLerpSpeed : float = 16.0
@export var _curYoffset : float = 10
@export var _curZoom : float = 10

#@export var _curYoffset : float = camYOffset

# private variables
@onready var _camTarget = $SpringArm3D/Camera3D
@onready var _springArm : SpringArm3D = get_node("SpringArm3D")

# No need to be top layer
func _ready() -> void:
	_springArm.spring_length = _curZoom

func _input(event) -> void:
	if event is InputEventMouseMotion:
		# rotate the rig around the target
		rotation.y -= event.relative.x * horizontalSensitivity
		rotation.y = wrapf(rotation.y,0.0,TAU)
		
		rotation.x -= event.relative.y * verticalSensitivity
		rotation.x = clamp(rotation.x, deg_to_rad(minPitchDeg), deg_to_rad(maxPitchDeg))
		
	if event is InputEventMouseButton:
		# change zoom level on mouse wheel rotation
		# this could be refactored to be based on an input action as well
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and _curZoom > minZoom:
				_curZoom -= zoomStep
				camYOffset -= zoomYStep
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and _curZoom < maxZoom:
				_curZoom += zoomStep
				camYOffset += zoomYStep
				print(_curZoom)

func _physics_process(delta) -> void:
	# zoom the camera accordingly
	_curYoffset = lerp(_curYoffset, camYOffset, delta * camLerpSpeed)
	_camTarget.position.y = _curYoffset
	_springArm.spring_length = lerp(_springArm.spring_length, _curZoom, delta * camLerpSpeed)
	# No need to move rig as it is a child of the player
