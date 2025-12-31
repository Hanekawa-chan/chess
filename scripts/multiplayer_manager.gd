extends Node

signal players_count_changed(count: int)
signal client_name_changed(name: String)
signal host_name_changed(name: String)

const server_port = 9002
var server_ip = "127.0.0.1"
var players_count = 1
var player_name = "bob"
var host_name = "bob"
var client_name = "bob"
var host_side = Game.Side.White
var client_side = Game.Side.Black
var player_side = Game.Side.White

func _ready():
	multiplayer.allow_object_decoding = true

func set_random_sides():
	var rng = RandomNumberGenerator.new()
	print("set random sides ", player_name, " host ", host_side, " client ", client_side, " player ", player_side, " is server ", multiplayer.is_server())
	if rng.randf() >= 0.5:
		set_sides.rpc(Game.Side.Black, Game.Side.White)
	if !multiplayer.is_server():
		player_side = client_side
	else:
		player_side = host_side
	print("set random sides ", player_name, " host ", host_side, " client ", client_side, " player ", player_side, " is server ", multiplayer.is_server())

@rpc("authority", "call_local")
func set_sides(_host_side, _client_side):
	print("set sides ", player_name, " host ", host_side, " client ", client_side, " player ", player_side, " is server ", multiplayer.is_server())
	host_side = _host_side
	client_side = _client_side
	print("set sides ", player_name, " host ", host_side, " client ", client_side, " player ", player_side, " is server ", multiplayer.is_server())

func become_host():
	print("hosting on port:", server_port)
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(server_port)
	
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_delete_player)
	
func join():
	print("joining to ", server_ip, ":", server_port)
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(server_ip, server_port)
	
	multiplayer.multiplayer_peer = peer
	print("joined as player id:", multiplayer.multiplayer_peer.get_unique_id())
	multiplayer.server_disconnected.connect(_force_return_to_main_menu)
	return

func _return_to_main_menu():
	print("returning to main menu")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
func _force_return_to_main_menu():
	_return_to_main_menu()
	GlobalPopup.show_popup("disconnected")
	
func _add_player(id: int):
	if players_count >= 2:
		players_count += 1
		multiplayer.multiplayer_peer.disconnect_peer(id)
		return
	print("added player id:", id)
	players_count += 1
	players_count_changed.emit(players_count)
	switch_scene.rpc()
	
func _delete_player(id: int):
	print("deleted player id:", id)
	players_count -= 1
	players_count_changed.emit(players_count)
	client_name = ""
	client_name_changed.emit("")

@rpc("any_peer", "call_remote", "reliable")
func switch_scene():
	print("switch scene", " peer ", multiplayer.get_unique_id())
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")

@rpc("any_peer", "call_local", "reliable")
func set_host_name(_name: String):
	print("new host name: ", _name)
	host_name = _name
	host_name_changed.emit(_name)

@rpc("any_peer", "call_local", "reliable")
func set_client_name(_name: String):
	print("new client name: ", _name)
	client_name = _name
	client_name_changed.emit(_name)
