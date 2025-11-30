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
var tile_model: ChessTileModel

func change_figure_on_grid(_figure: Game.Pieces):
	print("change figure on grid")
	figure = _figure
	if tile != null:
		print("tile != null")
		tile.change_figure_tile()

func _init(_place = Vector2i(0,0), _figure = Game.Pieces.Pawn, _color = Game.Side.White, _tile = null):
	place = _place
	figure = _figure
	color = _color
	tile = _tile

func make_copy():
	var _piece = Piece.new()
	_piece.place = Vector2i(place)
	_piece.figure = figure
	_piece.moved = moved
	_piece.color = color
	return _piece
