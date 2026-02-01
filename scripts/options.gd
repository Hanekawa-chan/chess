extends Control

#SOUND
@onready var background_slider: HSlider = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/BackgroundContainer/VBoxContainer/HSlider
@onready var game_slider: HSlider = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/GameContainer/VBoxContainer/HSlider
@onready var test_button = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/TestContainer/VBoxContainer/TestButton
#GRAPHICS
@onready var screen_mode_picker = $PanelContainer/HBoxContainer/MarginContainer2/VBoxContainer/VBoxContainer/ScreenModeContainer/VBoxContainer/ScreenModePicker
#MISC
@onready var current_name = %CurrentName
@onready var name_edit = %NameEdit
@onready var change_name_button = %ChangeNameButton
@onready var misc_container = %MiscContainer
#UI
@onready var return_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/MarginContainer3/ReturnButton
@onready var close_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/CloseButton
@onready var apply_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/MarginContainer2/ApplyButton

var close_func
var options: OptionsResource
var save_path = "user://options.tres"

@onready var button_audio_player: ButtonAudioPlayer = Core.button_audio_player

# Called when the node enters the scene tree for the first time.
func _ready():
	_load_options()
	set_misc_state(MultiplayerManager.Scenes.MainMenu)
	return_button.pressed.connect(_return_to_main_menu)
	close_button.pressed.connect(_close_options)
	apply_button.pressed.connect(_apply_options)
	change_name_button.button_down.connect(_change_name)
	background_slider.value_changed.connect(_on_background_slider_change)
	game_slider.value_changed.connect(_on_game_slider_change)
	test_button.pressed.connect(_test_sound)
	screen_mode_picker.item_selected.connect(_screen_mode_selected)
	get_window().size_changed.connect(_set_mode)

func set_misc_state(scene: MultiplayerManager.Scenes):
	if scene == MultiplayerManager.Scenes.MainMenu:
		misc_container.visible = true
		return_button.visible = false
	else:
		misc_container.visible = false
		return_button.visible = true
	
func _set_mode():
	screen_mode_picker.select(screen_mode_picker.get_item_index(get_window().mode))

func _screen_mode_selected(_screen_mode):
	button_audio_player.play_normal()
	get_window().mode = screen_mode_picker.get_item_id(_screen_mode)

func _on_background_slider_change(value):
	Core.background_audio_player.volume_linear = value
	
func _on_game_slider_change(value):
	button_audio_player.volume_linear = value

func _change_name():
	button_audio_player.play()
	var val = name_edit.text
	if len(val) > 0:
		MultiplayerManager.player_name = val
		current_name.text = val

func _return_to_main_menu():
	_close_options()
	Core.exit()

func _close_options():
	button_audio_player.play_normal()
	close_func.call()
	close_func = null
	self.visible = false
	self.top_level = false

func open(_close_func):
	button_audio_player.play_normal()
	close_func = _close_func
	self.visible = true
	self.top_level = true
	close_func.call()
	
func _test_sound():
	button_audio_player.play_normal()
	
func _load_options():
	options = OptionsResource.new()
	options.default()
	if not FileAccess.file_exists(save_path):
		print("No save file found, creating new data.")
		_save_options()
	# Load the resource, ignoring cache to ensure fresh data
	var loaded_data = ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if loaded_data:
		options = loaded_data as OptionsResource
		print("Game data loaded successfully.", options)
		background_slider.value = options.background_volume
		_on_background_slider_change(background_slider.value)
		game_slider.value = options.game_volume
		_on_game_slider_change(game_slider.value)
		screen_mode_picker.select(screen_mode_picker.get_item_index(options.screen_mode))
		get_window().mode = options.screen_mode
		name_edit.text = options.player_name
		var val = name_edit.text
		MultiplayerManager.player_name = val
		current_name.text = val
	else:
		print("Error loading save file.")
		_save_options()

func _apply_options():
	options.background_volume = background_slider.value
	options.game_volume = game_slider.value
	options.screen_mode = get_window().mode
	if MultiplayerManager.current_scene == MultiplayerManager.Scenes.MainMenu:
		options.player_name = name_edit.text
	_save_options()

func _save_options():
	var error = ResourceSaver.save(options, save_path)
	if error == OK:
		print("Game saved successfully to ", save_path)
	else:
		print("Error saving game: ", error)
