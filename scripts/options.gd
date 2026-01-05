extends Control

@onready var background_slider: HSlider = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/BackgroundContainer/VBoxContainer/HSlider
@onready var game_slider: HSlider = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/GameContainer/VBoxContainer/HSlider
@onready var close_button: TextureButton = $MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/CloseButton
@onready var test_button = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/TestContainer/VBoxContainer/TestButton
@onready var screen_mode_picker = $PanelContainer/HBoxContainer/MarginContainer2/VBoxContainer/VBoxContainer/ScreenModeContainer/VBoxContainer/ScreenModePicker
var close_func

# Called when the node enters the scene tree for the first time.
func _ready():
	Core.background_audio_player.volume_linear = 0.1
	close_button.pressed.connect(_close_options)
	background_slider.value_changed.connect(_on_background_slider_change)
	game_slider.value_changed.connect(_on_game_slider_change)
	test_button.pressed.connect(_test_sound)
	screen_mode_picker.item_selected.connect(_screen_mode_selected)

func _screen_mode_selected(_screen_mode):
	get_window().mode = _screen_mode

func _on_background_slider_change(value):
	Core.background_audio_player.volume_linear = value
	
func _on_game_slider_change(value):
	Core.button_audio_player.volume_linear = value

func _close_options():
	Core.button_audio_player.play_normal()
	close_func.call()
	close_func = null
	self.visible = false
	self.top_level = false
	
func open(_close_func):
	Core.button_audio_player.play_normal()
	close_func = _close_func
	self.visible = true
	self.top_level = true
	close_func.call()
	
func _test_sound():
	Core.button_audio_player.play_normal()
