class_name ChessTile extends Button

@onready
var game: Game = $"../../../../.."
@onready
var pieces = %Pieces
@export
var piece: Piece = null:
	set(value):
		if value != null:
			var tile = value.tile
			if tile != null:
				pieces.set_cell(tile.place, 0)
				tile.piece = null
				tile.movable_places = []
				value.place = place
				value.moved = true
		piece = value
		var new_tile =  Vector2i(-1,-1)
		if piece != null:
			piece.tile = self
			if piece.color == Game.Side.White:
				new_tile = game.white_piece_tiles_array[piece.figure]
			else:
				new_tile = game.black_piece_tiles_array[piece.figure]
		pieces.set_cell(place, 0, new_tile)

@export
var place: Vector2i
@export
var movable_places: Array

# Called when the node enters the scene tree for the first time.
func initialize():
	var n = String(name)
	var y = String(n[0]).to_int()
	var x = String(n[1]).to_int()
	place = Vector2i(x, y)
	button_up.connect(_on_button_up)
	#var atlas = pieces.get_cell_atlas_coords(place)
	#piece = Piece.new(place, game.piece_tiles_dict.get(atlas))

func _on_button_up():
	if piece != null:
		#print("clicked me! Pos:", place, " Fig:", Game.Pieces.keys()[piece.figure], " Color:", Game.Side.keys()[piece.color], " Available moves:", movable_places)
		if game.active_piece != null:
			if game.active_piece.color == piece.color:
				game.active_piece = piece
			else:
				# TODO add list of beaten pieces
				var active_piece = game.active_piece
				game.active_piece = null
				for pos in active_piece.tile.movable_places:
					if pos.place == place:
						# PIECE MOVES
						#print("active", active_piece)
						piece = active_piece
						game.move_number += 1
						game.new_round(game.chess_grid.get_children())
		else:
			game.active_piece = piece
	else:
		#print("clicked me! Pos:", place, " Empty")
		var active_piece = game.active_piece
		if active_piece != null:
			game.active_piece = null
			for pos in active_piece.tile.movable_places:
				if pos.place == place:
					# PIECE MOVES
					#print("active", active_piece)
					piece = active_piece
					game.move_number += 1
					game.new_round(game.chess_grid.get_children())
					
func convert_to_model():
	var copy_tile = ChessTileModel.new()
	if piece != null:
		var _piece = piece.make_copy()
		_piece.tile_model = copy_tile
		copy_tile.piece = _piece
	copy_tile.movable_places = movable_places
	copy_tile.place = Vector2i(place)
	return copy_tile
