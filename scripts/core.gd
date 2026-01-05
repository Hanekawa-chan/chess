extends Node
@onready var background_audio_player: AudioStreamPlayer = %BackgroundAudioPlayer
@onready var button_audio_player: ButtonAudioPlayer = %ButtonAudioPlayer

func _ready():
	background_audio_player.play()
