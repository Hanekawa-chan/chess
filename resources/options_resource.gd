class_name OptionsResource extends Resource

@export
var background_volume: float
@export
var game_volume: float
@export
var screen_mode: Window.Mode
@export
var player_name: String

func default():
	background_volume = 0.3
	game_volume = 1.0
	screen_mode = Window.MODE_WINDOWED
	player_name = "Bob"
