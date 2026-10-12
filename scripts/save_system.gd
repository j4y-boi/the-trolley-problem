# SaveSystem largely adapted from
# https://github.com/brooddoos/ijzerboer/blob/main/ijzerboer/scripts/savesystem.gd
# (Which I also happened to write myself)

extends Node

@onready var autosave_icon_timer: Timer = $AutosaveIconTimer
@onready var autosave_timer: Timer = $AutosaveTimer
@onready var save_icon: RichTextLabel = $SaveIcon

var current_save_slot = 1
var autosave_interval = 120
var version = ProjectSettings.get_setting("application/config/version")
var autosave_disabled_scenes = ["res://scenes/main_menu.tscn"]

const SAVE_LOCATION = "user://savefiles/"
const SETTINGS_LOCATION = "user://settings.sav"
var success = false

var save_content = {}
var DEFAULT_SAVE_CONTENT = {}

var settings = {
	"volume_sfx": AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("SFX")), #audio settings
	"volume_music": AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("BGM")),
	"volume_dialog": AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Diag")),
	
	"vsync": true, # video settings
	"fullscreen": false,
	"max_fps": 0,
}
var DEFAULT_SETTINGS = {}

func _ready() -> void:
	DEFAULT_SAVE_CONTENT = save_content.duplicate(true)
	DEFAULT_SETTINGS = settings.duplicate(true)
	
	autosave_timer.wait_time = autosave_interval
	get_tree().scene_changed.connect(_on_scene_changed)
	_on_scene_changed()
	
	DirAccess.make_dir_recursive_absolute(SAVE_LOCATION)
	autosave_icon_timer.timeout.connect(save_icon.hide)
	autosave_timer.timeout.connect(save)
	
	load_settings()
	apply_settings()

# - All Settings load and save routines - # (wow arent these comments so pretty now)
func save_settings():
	var file = FileAccess.open_encrypted_with_pass(SETTINGS_LOCATION, FileAccess.WRITE, "thetrainhassettingsiguess")
	file.store_var(settings)
	file.close()
	print("Settings saved")
func load_settings():
	if FileAccess.file_exists(SETTINGS_LOCATION):
		var file = FileAccess.open_encrypted_with_pass(SETTINGS_LOCATION, FileAccess.READ, "thetrainhassettingsiguess")
		var data = file.get_var()
		file.close()

		if typeof(data) == TYPE_DICTIONARY:
			for key in settings.keys():
				if data.has(key) and typeof(data[key]) == typeof(settings[key]):
					settings[key] = data[key]
		print("Settings loaded")
	else:
		settings = DEFAULT_SETTINGS.duplicate(true)
		save_settings()
func apply_settings():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(settings.volume_sfx))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear_to_db(settings.volume_music))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Diag"), linear_to_db(settings.volume_dialog))

	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if settings.vsync else DisplayServer.VSYNC_DISABLED)

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if settings.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED) # this is extremely unreadable, but fuck it we ball

	Engine.max_fps = settings.max_fps
# - - - #

# - All main game data load and save routines - #
func set_list(): # updates save_content
	var current_date = Time.get_date_string_from_system() # Output: "2024-05-20"
	var current_time = Time.get_time_string_from_system() # Output: "14:30:05"
	
	save_content = {
		"version" : version,
		"last_saved" : current_date + " at " + current_time,
	}
func load_list(): # actually loads and applies all progress from file
	for content in save_content:
		GameState.set(content, save_content[content])
func save(refresh_data:bool = true):
	var used_save_location = get_save_path()
	
	autosave_icon_timer.start()
	print("Saving...")
	save_icon.show()
	
	if refresh_data:
		set_list()
		
	var file = FileAccess.open_encrypted_with_pass(used_save_location, FileAccess.WRITE, "ijzerboersavefile")
	file.store_var(save_content.duplicate())
	file.close()
	await autosave_icon_timer.timeout
	print("Saved")
func get_save_info(slot:int): # save metadata
	var path = SAVE_LOCATION + "slot" + str(slot) + ".sav"
	if not FileAccess.file_exists(path):
		return {}

	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, "trolleysavesfilesnow")
	var data = file.get_var()
	file.close()

	if typeof(data) != TYPE_DICTIONARY:
		return {}

	return {"version": data.get("version", "unknown"),"last_saved": data.get("last_saved", "unknown")}
func get_save_path(slot = current_save_slot) -> String:
	return SAVE_LOCATION + "slot" + str(slot) + ".sav"
func load_save(setgamestate:bool = true):
	success = false
	var used_save_location = get_save_path()
	if FileAccess.file_exists(used_save_location):
		print("Savefile found!")
		var file = FileAccess.open_encrypted_with_pass(used_save_location, FileAccess.READ, "trolleysavesfilesnow")
		var data = file.get_var()
		file.close()
		
		if typeof(data) != TYPE_DICTIONARY:
			print("Savefile did not contain valid dict.")
			success = false
			return
		
		for key in save_content.keys(): #checking if types are correct
			if data.has(key) and typeof(data[key]) == typeof(save_content[key]):
				save_content[key] = data[key]
		
		success = true
		
		if setgamestate:
			load_list()
		print("Succesfully loaded")
	else:
		print("No savefile found.")
		return
func delete_save():
	success = false
	var used_save_location = get_save_path()
	if FileAccess.file_exists(used_save_location):
		DirAccess.remove_absolute(used_save_location)
		print("Deleted")
	else:
		print("No savefile found.")
		return
# - - - #

func _on_scene_changed():
	if get_tree().current_scene.scene_file_path in autosave_disabled_scenes:
		autosave_timer.stop()
	else:
		autosave_timer.start()
