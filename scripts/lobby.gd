extends Control

@onready var start_game_button = %StartGameButton
@onready var exit_button = %ExitButton
@onready var menu_container = %MenuContainer
@onready var host_name = %HostName
@onready var client_name = %ClientName
@onready var options_button = %OptionsButton
@onready var button_audio_player = Core.button_audio_player
const BUTTON_PRESS = preload("uid://dnr6ia0n4goas")

# Called when the node enters the scene tree for the first time.
func _ready():
	MultiplayerManager.client_name_changed.connect(_client_name_changed)
	MultiplayerManager.host_name_changed.connect(_host_name_changed)
	exit_button.button_down.connect(Core.exit)
	start_game_button.button_down.connect(_start)
	options_button.pressed.connect(_open_options)
	if not multiplayer.is_server():
		start_game_button.visible = false
		print("setting client name ", MultiplayerManager.player_name)
		MultiplayerManager.set_client_name.rpc(MultiplayerManager.player_name)
	else:
		MultiplayerManager.set_host_name.rpc(MultiplayerManager.player_name)
		MultiplayerManager.players_count_changed.connect(_switch_start_game_button)
		start_game_button.disabled = true
		
func _open_options():
	Options.open(_switch_visible)

func _switch_visible():
	self.visible = !self.visible
	
func _client_name_changed(_name: String):
	print("on client name changed name:", _name, " server: ", multiplayer.is_server())
	client_name.text = "P2: "+_name
	if multiplayer.is_server():
		MultiplayerManager.set_host_name.rpc(MultiplayerManager.host_name)
	
func _host_name_changed(_name: String):
	host_name.text = "P1: "+_name
	
func _start():
	button_audio_player.play()
	print("started")
	start_game.rpc()
	
@rpc("any_peer", "call_local")
func start_game():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	MultiplayerManager.current_scene = MultiplayerManager.Scenes.Main

	
func _switch_start_game_button(count: int):
	print("count changed ", count)
	if count == 2:
		MultiplayerManager.set_random_sides()
		start_game_button.disabled = false
	else:
		start_game_button.disabled = true
