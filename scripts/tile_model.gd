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
				special_moves = []
				movable_places = []
		else:
			special_moves = []
			movable_places = []
		piece = value

@export
var place: Vector2i
@export
var movable_places: Array
@export
var special_moves: Array

func make_copy():
	var copy_tile = ChessTileModel.new()
	if piece != null:
		var _piece = piece.make_copy()
		_piece.tile_model = copy_tile
		copy_tile.piece = _piece
	copy_tile.movable_places = movable_places
	copy_tile.special_moves = special_moves
	copy_tile.place = Vector2i(place)
	return copy_tile

func convert_movable_places(grid):
	var new_movable_places = []
	for p in movable_places:
		for t in grid:
			if t.place == p.place:
				new_movable_places.append(t)
	return new_movable_places

func convert_special_moves(grid):
	var new_movable_places = []
	for p in special_moves:
		for t in grid:
			if t.place == p.place:
				new_movable_places.append(t)
	return new_movable_places
