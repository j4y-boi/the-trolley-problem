extends CenterContainer
@onready var main_menu: Control = $"../.."
@onready var animation: AnimationPlayer = $"../../Camera3D/Animation"
@onready var gui_transition: AnimationPlayer = $"../GuiTransition"
@onready var camera: Camera3D = $"../../Camera3D"

func _on_return_pressed() -> void:
	if not animation.is_playing():
		main_menu.enable_parallax = false
		gui_transition.play_backwards("intro4")
		await gui_transition.animation_finished
		
		animation.play_backwards("pan_to_options")
		
		await animation.animation_finished
		gui_transition.play("intro")
		main_menu.enable_parallax = true
		main_menu.origin = camera.position 
