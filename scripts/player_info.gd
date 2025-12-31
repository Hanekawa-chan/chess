extends PanelContainer

@onready var first_player_name = $VBoxContainer/VBoxContainer/FirstPlayerName
@onready var second_player_name = $VBoxContainer/VBoxContainer2/SecondPlayerName

# Called when the node enters the scene tree for the first time.
func _ready():
	if MultiplayerManager.host_side == Game.Side.White:
		first_player_name.text = MultiplayerManager.host_name + " playing as white"
		second_player_name.text = MultiplayerManager.client_name + " playing as black"
	else:
		first_player_name.text = MultiplayerManager.host_name + " playing as black"
		second_player_name.text = MultiplayerManager.client_name + " playing as white"
