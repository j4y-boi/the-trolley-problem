extends Node3D
@onready var anim: AnimationPlayer = $anim
@onready var anim_2: AnimationPlayer = $anim2

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	anim.play("rotate")
	effect()

func effect() -> void:
	while true:
		await get_tree().create_timer(randf_range(1.0, 4.0)).timeout
		anim_2.play("catch")
		await anim_2.animation_finished
