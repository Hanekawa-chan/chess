class_name ChoosablePiece extends TextureButton

@export
var piece: Game.Pieces
@onready
var game: Game = $"../../../../../.."
var texture: AtlasTexture

func _ready():
	texture = texture_normal as AtlasTexture
	if MultiplayerManager.player_side == Game.Side.Black:
		print("black ", texture, " name ", MultiplayerManager.player_name)
		texture.region = Rect2(texture.region.position.x,texture.region.position.y+32,texture.region.size.x,texture.region.size.y)
	print("region ", texture.region, " name ", MultiplayerManager.player_name, " side ", MultiplayerManager.player_side)
	button_up.connect(_on_button_up)
	
func _on_button_up():
	if game.current_side == MultiplayerManager.player_side:
		print("pressed")
		game.pawn_to_figure.rpc(piece)
