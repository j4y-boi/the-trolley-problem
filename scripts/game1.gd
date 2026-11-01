extends Control
@onready var root_control: Control = $"."
@onready var action_clock: Timer = $ActionClock
@onready var timer_label: Label = $GUI/SubViewportContainer/Content/Timer
@onready var view_intro: SubViewportContainer = $ViewIntro
@onready var speedcam: Camera3D = $GUI/SubViewportContainer/SubViewport/Speedcam

@onready var lever: Node3D = $"../lever"
@onready var lever_anim: AnimationPlayer = $"../lever/LeverAnim"
@onready var lever_enable: Button = $LeverEnable
@onready var camera_animate: AnimationPlayer = $MainCamera/CameraAnimate

# this is incredibly inefficnent, but i could care less atm
@onready var end: Control = $"../End"
@onready var lines = [
	$"../End/VBoxContainer/1", 
	$"../End/VBoxContainer/2", 
	$"../End/VBoxContainer/3", 
	$"../End/VBoxContainer/4", 
	$"../End/VBoxContainer/5", 
	$"../End/VBoxContainer/6", 
	$"../End/VBoxContainer/7"
]

var speedcam_initial_position: Vector3
const SHAKE_MAX = 1
const SHAKE_MIN = -1
const ACTION_TIME = 15

var lever_enabled = false

func _ready() -> void:
	speedcam_initial_position = speedcam.position
	action_clock.wait_time = ACTION_TIME
	action_clock.start()
	view_intro.stretch_shrink = 50
	end.hide()
	
	for i in lines:
		i.hide()
	
func _process(delta: float) -> void:
	speedcam.position = speedcam_initial_position + Vector3(randf_range(SHAKE_MIN,SHAKE_MAX)*delta,randf_range(SHAKE_MIN,SHAKE_MAX)*delta,randf_range(SHAKE_MIN,SHAKE_MAX)*delta)
	#long ahhh line of code lmfao
	
	var timer_left = action_clock.time_left
	@warning_ignore("integer_division") var milliseconds = int((timer_left - int(timer_left)) * 1000)
	@warning_ignore("integer_division") var seconds = int(timer_left) % 60 
	@warning_ignore("integer_division") var minutes = (int(timer_left) / 60) % 60
	timer_label.text = "%02d:%02d:%02d" % [minutes, seconds,milliseconds]
	
	if view_intro.stretch_shrink != 1:
		view_intro.stretch_shrink -= 1
	else:
		view_intro.hide()

func _on_lever_enable_pressed() -> void:
	lever_enabled = not lever_enabled
	if lever_enabled:
		lever_anim.play("right")
	else:
		lever_anim.play("left")

func _on_action_clock_timeout() -> void:
	lever_enable.disabled = true
	var tween = self.create_tween()
	tween.tween_property(root_control, "modulate:a", 0.0, 2.0)
	await get_tree().create_timer(1.5).timeout
	if lever_enabled:
		camera_animate.play("choice1")
	else:
		camera_animate.play("choice2")
	await tween.finished
	root_control.hide()
	
	await camera_animate.animation_finished
	
	tween = self.create_tween()
	end.modulate.a = 0
	end.show()
	tween.tween_property(end, "modulate:a", 1.0, 2.0)
	
	await tween.finished
	
	var waittime = 3.0
	
	await get_tree().create_timer(waittime).timeout
	lines[0].show()
	await get_tree().create_timer(waittime).timeout
	lines[1].show()
	await get_tree().create_timer(waittime/3).timeout
	lines[2].show()
	await get_tree().create_timer(waittime/3).timeout
	lines[3].show()
	await get_tree().create_timer(waittime).timeout
	lines[4].show()
	await get_tree().create_timer(waittime).timeout
	lines[5].show()
	await get_tree().create_timer(waittime).timeout
	lines[6].show()
	await get_tree().create_timer(waittime*2).timeout
	
	TransitionHandler.fade_out()
	await TransitionHandler.fade_out_finished
	get_tree().change_scene_to_packed(load("res://scenes/main_menu.tscn"))
	await TransitionHandler.fade_in()
