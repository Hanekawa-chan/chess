class_name Piece extends Resource

@export
var place: Vector2i
@export
var figure: Game.Pieces
@export
var color: Game.Side
@export
var moved: bool
var tile: ChessTile


func _init(_place = Vector2i(0,0), _figure = Game.Pieces.Pawn, _color = Game.Side.White, _tile = null):
	place = _place
	figure = _figure
	color = _color
	tile = _tile
