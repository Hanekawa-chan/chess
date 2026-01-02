extends Node
@onready var background_audio_player = %BackgroundAudioPlayer
@onready var button_audio_player = %ButtonAudioPlayer

func _ready():
	background_audio_player.play()
