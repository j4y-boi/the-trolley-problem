extends CanvasLayer
@onready var mask: ColorRect = $Mask

var busy := false
var current_scene := ""
const DEFAULT_MASK := preload("res://assets/image/transition.png")

signal fade_out_finished
signal fade_in_finished

func _ready() -> void:
	await get_tree().process_frame
	current_scene = get_tree().current_scene.name

func fade_in(custom_mask = ""):
	if custom_mask != "" and ResourceLoader.exists(custom_mask):
		mask.material.set_shader_parameter('mask',load(custom_mask))
	else:
		mask.material.set_shader_parameter('mask',DEFAULT_MASK)
	
	get_tree().paused = false
	
	var tween = self.create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(mask.material, "shader_parameter/scale", 0.0, 2.0)
	await tween.finished

	busy = false
	fade_in_finished.emit()

func fade_out(custom_mask = "") -> void:
	if busy:
		return
	busy = true
	
	var scene_path = get_tree().current_scene.scene_file_path
	GameState.last_scene = scene_path
	
	if custom_mask != "" and ResourceLoader.exists(custom_mask):
		mask.material.set_shader_parameter('mask',load(custom_mask))
	else:
		mask.material.set_shader_parameter('mask',DEFAULT_MASK)
	
	var tween = self.create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(mask.material, "shader_parameter/scale", 1.0, 2.0)
	await tween.finished
	fade_out_finished.emit()
