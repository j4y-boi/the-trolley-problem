extends Control
@onready var ambient_particles: CPUParticles3D = $AmbientParticles
@onready var animation: AnimationPlayer = $Camera3D/Animation
@onready var logo: Control = $logo

func _ready() -> void:
	ambient_particles.emitting = false
	logo.visible = true
	do_it()

func do_it() -> void:
	var tween = self.create_tween()
	tween.tween_interval(3)
	tween.tween_property(logo, "modulate:a", 0, 1.5)
	tween.tween_interval(3)
	await tween.finished
	ambient_particles.emitting = true
	animation.play("pan")
	await animation.animation_finished
	
