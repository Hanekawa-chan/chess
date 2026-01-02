extends Control

@onready var exit_button = %ExitButton
@onready var enter_lobby_button = %EnterLobbyButton
@onready var create_lobby_button = %CreateLobbyButton
@onready var address_edit = %AddressEdit
@onready var current_name = %CurrentName
@onready var name_edit = %NameEdit
@onready var change_name_button = %ChangeNameButton
const POPUP = preload("uid://jvgunv5ppmuc")
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
	var val = name_edit.text
	if len(val) > 0:
		MultiplayerManager.player_name = val
		current_name.text = val

func _exit():
	get_tree().free()
	
func _enter_lobby():
	MultiplayerManager.join()
	
func _create_lobby():
	MultiplayerManager.become_host()
	get_tree().change_scene_to_file(LOBBY.resource_path)


func _on_button_button_down():
	print("peers:", multiplayer.get_peers())
	print("unique id:", multiplayer.get_unique_id())
	print("server:", multiplayer.is_server())
	if multiplayer.multiplayer_peer != null:
		print("mp.unique_id:", multiplayer.multiplayer_peer.get_unique_id())
		print("status:", multiplayer.multiplayer_peer.get_connection_status())
