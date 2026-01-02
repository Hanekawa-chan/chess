extends Control

@onready var exit_button = %ExitButton
@onready var enter_lobby_button = %EnterLobbyButton
@onready var create_lobby_button = %CreateLobbyButton
@onready var address_edit = %AddressEdit
@onready var current_name = %CurrentName
@onready var name_edit = %NameEdit
@onready var change_name_button = %ChangeNameButton
@onready var button_audio_player = Core.button_audio_player
const BUTTON_PRESS = preload("uid://dnr6ia0n4goas")
const LOBBY = preload("uid://8cvj5dv8dxvs")

# Called when the node enters the scene tree for the first time.
func _ready():
	exit_button.button_down.connect(_exit)
	enter_lobby_button.button_down.connect(_enter_lobby)
	create_lobby_button.button_down.connect(_create_lobby)
	change_name_button.button_down.connect(_change_name)
	address_edit.text_changed.connect(_change_address)
	
func _change_address(address):
	MultiplayerManager.server_ip = address

func _change_name():
	button_audio_player.play()
	var val = name_edit.text
	if len(val) > 0:
		MultiplayerManager.player_name = val
		current_name.text = val

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
