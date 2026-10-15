extends PanelContainer
@onready var main_menu: Control = $"../.."
@onready var animation: AnimationPlayer = $"../../Camera3D/Animation"
@onready var gui_transition: AnimationPlayer = $"../GuiTransition"
@onready var camera: Camera3D = $"../../Camera3D"

@onready var title: RichTextLabel = $Content/Title
@onready var buttons = [
	$Content/SaveSlots/Slot1, 
	$Content/SaveSlots/Slot2, 
	$Content/SaveSlots/Slot3, 
	$Content/SaveManagement/Copy, 
	$Content/SaveManagement/Delete,
]

var file_mode = "load"
var slot = 0
var save_file_existence = []

func refresh_file_existence():
	save_file_existence = [
		FileAccess.file_exists(SaveSystem.SAVE_LOCATION + "slot1.sav"),
		FileAccess.file_exists(SaveSystem.SAVE_LOCATION + "slot2.sav"),
		FileAccess.file_exists(SaveSystem.SAVE_LOCATION + "slot3.sav"),
	]

func _ready() -> void:
	refresh_file_existence()
	
	for button in buttons:
		button.pressed.connect(_on_button_pressed.bind(button))

func handle_save_slot(saveslot):
	var index = saveslot-1
	slot = saveslot #used for cross function features
	if file_mode == "load":
		SaveSystem.current_save_slot = saveslot
		if save_file_existence[index]:
			pass
		else: # no savefile, create new
			pass
			
	#elif file_mode == "delete":
		#delete_confirm.dialog_text = "Are you sure you want to delete the save file in slot " + str(saveslot) + "?"
		#delete_confirm.popup_centered()
		##rest of delete logic handled by _on_delete_confirm_confirmed()
		#label_setter("load")
	#elif file_mode == "copy":
		#slot = saveslot
		#label_setter("paste")
	#elif file_mode == "paste":
		#Savesystem.current_used_slot = slot
		#Savesystem.load_save(false)
		#Savesystem.current_used_slot = saveslot
		#await Savesystem.save()
		#label_setter("load")

func _on_button_pressed(button):
	if button.name.begins_with("Save"):
		var saveslot := int(button.name.trim_prefix("Slot"))
		handle_save_slot(saveslot)
		return
	
	#match button.name:
		#"Delete":
			#if file_mode == "delete":
				#label_setter("load")
			#else:
				#label_setter("delete")
		#"Copy":
			#if file_mode == "copy" or file_mode == "paste":
				#label_setter("load")
			#else:
				#label_setter("copy")

func _on_back_pressed() -> void:
	if not animation.is_playing():
		main_menu.enable_parallax = false
		gui_transition.play_backwards("intro3")
		await gui_transition.animation_finished
		
		animation.play_backwards("pan_to_save")
		
		await animation.animation_finished
		gui_transition.play("intro")
		main_menu.enable_parallax = true
		main_menu.origin = camera.position 
