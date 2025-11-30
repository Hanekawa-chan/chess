class_name ChoosablePiece extends TextureButton

@export
var piece: Game.Pieces
@onready
var game: Game = $"../../../../../.."

func _ready():
	button_up.connect(_on_button_up)
	
func _on_button_up():
	print("pressed")
	game.pawn_to_figure(piece)
