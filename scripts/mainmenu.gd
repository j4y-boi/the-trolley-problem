extends Control
@onready var ambient_particles: CPUParticles3D = $AmbientParticles
@onready var animation: AnimationPlayer = $Camera3D/Animation
@onready var music: AudioStreamPlayer = $AudioStreamPlayer
@onready var my_logo: Control = $logo/me
@onready var stardance: Control = $logo/stardance
@onready var godot: Control = $logo/godot
@onready var camera: Camera3D = $Camera3D

var stength:float = 0.01
var origin
var skip = true

func _ready() -> void:
	music.play()
	ambient_particles.emitting = false
	my_logo.hide()
	stardance.hide()
	godot.hide()
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
	
