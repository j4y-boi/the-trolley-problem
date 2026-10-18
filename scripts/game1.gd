extends Control
@onready var do_something: Control = $DoSomething
@onready var do_nothing: Control = $DoNothing

@onready var do_something_point: Marker3D = $View/SubViewport/DoSomething
@onready var do_nothing_point: Marker3D = $View/SubViewport/DoNothing
@onready var camera: Camera3D = $View/SubViewport/game/Camera3D

@onready var speedcam: Camera3D = $SubViewportContainer/SubViewport/Speedcam

var speedcam_initial_position: Vector3
const SHAKE_MAX = 1
const SHAKE_MIN = -1

func project_to_2d(marker:Marker3D):
	var world_position = marker.global_transform.origin
	return camera.unproject_position(world_position)

func _ready() -> void:
	do_something.position = project_to_2d(do_something_point)
	do_nothing.position = project_to_2d(do_nothing_point)
	speedcam_initial_position = speedcam.position

func _process(delta: float) -> void:
	speedcam.position = speedcam_initial_position + Vector3(randf_range(SHAKE_MIN,SHAKE_MAX)*delta,randf_range(SHAKE_MIN,SHAKE_MAX)*delta,randf_range(SHAKE_MIN,SHAKE_MAX)*delta)
	#long ahhh line of code lmfao
