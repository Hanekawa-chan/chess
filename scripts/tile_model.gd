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
