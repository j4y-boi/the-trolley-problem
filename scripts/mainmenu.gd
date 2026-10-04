extends Control
@onready var ambient_particles: CPUParticles3D = $AmbientParticles
@onready var animation: AnimationPlayer = $Camera3D/Animation
@onready var music: AudioStreamPlayer = $AudioStreamPlayer
@onready var camera: Camera3D = $Camera3D

#intro stuff
@onready var logo: Control = $logo
@onready var my_logo: Control = $logo/me
@onready var stardance: Control = $logo/stardance
@onready var godot: Control = $logo/godot

@onready var gui: Control = $gui
@onready var gui_transition: AnimationPlayer = $gui/GuiTransition
@onready var buttons: HBoxContainer = $gui/buttons
@onready var button_set_2: HBoxContainer = $gui/ButtonSet2
@onready var version_text: Label = $gui/buttons/version/VersionText

var stength:float = 0.01
var origin

var version = ProjectSettings.get_setting("application/config/version")
var skip = false

func _ready() -> void:
	version_text.text = "v"+str(version) 
	music.play()
	
	ambient_particles.emitting = false
	my_logo.hide()
	stardance.hide()
	godot.hide()
	
	logo.show()
	origin = camera.position
	do_it()

func _process(_delta: float) -> void:
	var mouse = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	var mx = (mouse.x / viewport_size.x - 0.5) * 2.0
	var my = (mouse.y / viewport_size.y - 0.5) * 2.0

	var offset = Vector3(mx * stength, -my * stength, 0)
	camera.position = origin + offset

func do_it() -> void:
	if not skip:
		my_logo.show()
		await get_tree().create_timer(1.7).timeout

		stardance.show()
		await get_tree().create_timer(1.7).timeout

		godot.show()
		my_logo.hide()
		stardance.hide()
		await get_tree().create_timer(1.7).timeout
		
		var tween = self.create_tween()
		tween.tween_property(godot, "modulate:a", 0, 1.5)
		tween.tween_interval(3)
		await tween.finished
	ambient_particles.emitting = true
	animation.play("pan")
	await animation.animation_finished
	gui_transition.play("intro")

func _on_extras_pressed() -> void:
	gui_transition.play_backwards("intro")
	await gui_transition.animation_finished
	gui_transition.play("intro2")
	button_set_2.show()
	buttons.hide()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	gui_transition.play_backwards("intro2")
	await gui_transition.animation_finished
	gui_transition.play("intro")
	buttons.show()
	button_set_2.hide()

func _on_version_pressed() -> void:
	OS.shell_open("https://github.com/j4y-boi/the-trolley-problem/releases/tag/v"+str(version))
