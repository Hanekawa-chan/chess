extends Node
@onready var background_audio_player: AudioStreamPlayer = %BackgroundAudioPlayer
@onready var button_audio_player: ButtonAudioPlayer = %ButtonAudioPlayer

func _ready():
	background_audio_player.play()

func exit():
	button_audio_player.play()
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	MultiplayerManager.current_scene = MultiplayerManager.Scenes.MainMenu
