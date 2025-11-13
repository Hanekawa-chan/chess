class_name ChessTileModel extends Resource

@export
var piece: Piece = null:
	set(value):
		if value != null:
			var tile = value.tile
			if tile != null:
				tile.piece = null
				value.place = place
				value.moved = true
		piece = value

@export
var place: Vector2i
@export
var movable_places: Array


func make_copy():
	var copy_tile = ChessTileModel.new()
	if piece != null:
		var _piece = piece.make_copy()
		_piece.tile_model = copy_tile
		copy_tile.piece = _piece
	copy_tile.movable_places = movable_places
	copy_tile.place = Vector2i(place)
	return copy_tile
