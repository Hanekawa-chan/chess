extends Control

@onready var exit_button = %ExitButton
@onready var enter_lobby_button = %EnterLobbyButton
@onready var create_lobby_button = %CreateLobbyButton
@onready var address_edit = %AddressEdit
@onready var options_button = %OptionsButton
@onready var button_audio_player = Core.button_audio_player
const BUTTON_PRESS = preload("uid://dnr6ia0n4goas")
const LOBBY = preload("uid://8cvj5dv8dxvs")

# Called when the node enters the scene tree for the first time.
func _ready():
	Options.visible = false
	exit_button.button_down.connect(_exit)
	enter_lobby_button.button_down.connect(_enter_lobby)
	create_lobby_button.button_down.connect(_create_lobby)
	address_edit.text_changed.connect(_change_address)
	options_button.pressed.connect(_open_options)
	
func _change_address(address):
	MultiplayerManager.server_ip = address

func _exit():
	button_audio_player.play()
	get_tree().free()
	
func _enter_lobby():
	button_audio_player.play()
	MultiplayerManager.join()
	
func _create_lobby():
	button_audio_player.play()
	MultiplayerManager.become_host()
	get_tree().change_scene_to_file(LOBBY.resource_path)
	MultiplayerManager.current_scene = MultiplayerManager.Scenes.Lobby
	
func _open_options():
	Options.open(_switch_visible)

func _switch_visible():
	self.visible = !self.visible
