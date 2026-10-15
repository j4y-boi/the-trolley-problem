extends Control

@onready var photo: TextureRect = $Box/Content/Holder/Photo
@onready var dialog_name: RichTextLabel = $Box/Content/TextContent/DialogName
@onready var dialog: RichTextLabel = $Box/Content/TextContent/Dialog
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var dialog_shown = false

func show_dialog(name:String,dialog_text:String,photo_path:String):
	if not dialog_shown:
		dialog_shown = true
		dialog_name.text = name
		dialog.text = dialog_text
		photo.texture = load(photo_path)
		animation_player.play("up")

func hide_dialog():
	if dialog_shown:
		dialog_shown = false
		animation_player.play_backwards("up")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not dialog_shown:
			show_dialog(
				"mr name",
				"Hi, I'm dialog test",
				"res://assets/image/placeholder.svg"
			)
		else:
			hide_dialog()
