class_name Game extends Control

@onready var move_number_label = %MoveNumberLabel
@onready var current_side_label = %CurrentSideLabel
@onready var board = %Board
@onready var pieces = %Pieces
@onready var chess_grid = %ChessGrid
var move_number: int = 1:
	set(value):
		move_number_label.text = "move number: " + str(value)
		move_number = value
		if move_number % 2 == 1:
			current_side_label.text = "white is playing"
		else:
			current_side_label.text = "black is playing"
var active_piece: Piece = null:
	set(value):
		var old_place = active_piece
		active_piece = value
		if active_piece != null:
			var old_tile = board.get_cell_atlas_coords(value.place)
			board.set_cell(value.place, 0, Vector2i(old_tile.x, old_tile.y+2))
			var tile = value.tile
			for t in tile.movable_places:
				old_tile = board.get_cell_atlas_coords(t.place)
				board.set_cell(t.place, 0, Vector2i(old_tile.x, old_tile.y+2))
		if old_place != null:
			var old_tile = board.get_cell_atlas_coords(old_place.place)
			print("old tile ", old_place.place)
			board.set_cell(old_place.place, 0, Vector2i(old_tile.x, old_tile.y-2))
			var tile = old_place.tile
			for t in tile.movable_places:
				old_tile = board.get_cell_atlas_coords(t.place)
				board.set_cell(t.place, 0, Vector2i(old_tile.x, old_tile.y-2))
		print("new active piece ", value, " old place ", old_place)

var white_piece_tiles_array = [
	Vector2i(0,0),
	Vector2i(2,0),
	Vector2i(1,1),
	Vector2i(0,1),
	Vector2i(3,0),
	Vector2i(3,1),
	Vector2i(2,1),
]

var black_piece_tiles_array = [
	Vector2i(1,0),
	Vector2i(2,2),
	Vector2i(1,3),
	Vector2i(0,3),
	Vector2i(3,2),
	Vector2i(3,3),
	Vector2i(2,3),
]

var piece_tiles_dict = {
	Vector2i(2,0):1,
	Vector2i(2,2):1,
	Vector2i(1,1):2,
	Vector2i(1,3):2,
	Vector2i(0,1):3,
	Vector2i(0,3):3,
	Vector2i(3,0):4,
	Vector2i(3,2):4,
	Vector2i(3,1):5,
	Vector2i(3,3):5,
	Vector2i(2,1):6,
	Vector2i(2,3):6
}

var board_tiles_array = [
	Vector2i(0,0),
	Vector2i(1,0),
	Vector2i(0,2),
	Vector2i(1,2),
]

var board_tiles_dict = {
	Vector2i(0,0):0,
	Vector2i(1,0):1,
	Vector2i(0,2):2,
	Vector2i(1,2):3,
}

enum Side {
	White,
	Black
}

enum Pieces {
	Empty,
	Pawn,
	Bishop,
	Knight,
	Rook,
	Queen,
	King
}

enum Tiles {
	White,
	Black,
	ActiveWhite,
	ActiveBlack
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var _board = get_initial_board()
	var cells = pieces.get_used_cells()
	for cell in cells:
		var source = pieces.get_cell_atlas_coords(cell)
		print("cell:", cell, " source:", source)
	for cell in chess_grid.get_children():
		cell.initialize()
		for piece in _board:
			if piece.place == cell.place:
				cell.piece = piece
				break
	get_available_moves()
	
func get_available_moves():
	print("getting available moves")
	var tiles = chess_grid.get_children()
	for tile in tiles:
		if tile.piece != null:
			tile.movable_places = get_all_moves(tile.piece, tiles)

func get_all_moves(piece: Piece, tiles: Array[Node]) -> Array:
	var movable_positions = []
	match piece.figure:
		Pieces.Rook:
			var enemy_side = Side.Black
			if piece.color != Side.White:
				enemy_side = Side.White
			for i in range(7):
				var move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x+(i+1), piece.place.y))
				if move_tile != null:
					if move_tile.piece != null:
						if move_tile.piece.color == enemy_side:
							movable_positions.append(move_tile)
						break
					movable_positions.append(move_tile)
				else:
					break
			for i in range(7):
				var move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x-(i+1), piece.place.y))
				if move_tile != null:
					if move_tile.piece != null:
						if move_tile.piece.color == enemy_side:
							movable_positions.append(move_tile)
						break
					movable_positions.append(move_tile)
				else:
					break
			for i in range(7):
				var move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x, piece.place.y-(i+1)))
				if move_tile != null:
					if move_tile.piece != null:
						if move_tile.piece.color == enemy_side:
							movable_positions.append(move_tile)
						break
					movable_positions.append(move_tile)
				else:
					break
			for i in range(7):
				var move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x, piece.place.y+(i+1)))
				if move_tile != null:
					if move_tile.piece != null:
						if move_tile.piece.color == enemy_side:
							movable_positions.append(move_tile)
						break
					movable_positions.append(move_tile)
				else:
					break
		Pieces.Knight:
			var enemy_side = Side.Black
			if piece.color != Side.White:
				enemy_side = Side.White
			var move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x-1, piece.place.y-2))
			if move_tile != null && (move_tile.piece != null && move_tile.piece.color == enemy_side || move_tile.piece == null):
				movable_positions.append(move_tile)
			move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x+1, piece.place.y-2))
			if move_tile != null && (move_tile.piece != null && move_tile.piece.color == enemy_side || move_tile.piece == null):
				movable_positions.append(move_tile)
			move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x-1, piece.place.y+2))
			if move_tile != null && (move_tile.piece != null && move_tile.piece.color == enemy_side || move_tile.piece == null):
				movable_positions.append(move_tile)
			move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x+1, piece.place.y+2))
			if move_tile != null && (move_tile.piece != null && move_tile.piece.color == enemy_side || move_tile.piece == null):
				movable_positions.append(move_tile)
			move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x-2, piece.place.y+1))
			if move_tile != null && (move_tile.piece != null && move_tile.piece.color == enemy_side || move_tile.piece == null):
				movable_positions.append(move_tile)
			move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x+2, piece.place.y+1))
			if move_tile != null && (move_tile.piece != null && move_tile.piece.color == enemy_side || move_tile.piece == null):
				movable_positions.append(move_tile)
			move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x-2, piece.place.y-1))
			if move_tile != null && (move_tile.piece != null && move_tile.piece.color == enemy_side || move_tile.piece == null):
				movable_positions.append(move_tile)
			move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x+2, piece.place.y-1))
			if move_tile != null && (move_tile.piece != null && move_tile.piece.color == enemy_side || move_tile.piece == null):
				movable_positions.append(move_tile)
		Pieces.Bishop:
			var enemy_side = Side.Black
			if piece.color != Side.White:
				enemy_side = Side.White
			for i in range(7):
				var move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x+(i+1), piece.place.y+(i+1)))
				if move_tile != null:
					if move_tile.piece != null:
						if move_tile.piece.color == enemy_side:
							movable_positions.append(move_tile)
						break
					movable_positions.append(move_tile)
				else:
					break
			for i in range(7):
				var move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x-(i+1), piece.place.y+(i+1)))
				if move_tile != null:
					if move_tile.piece != null:
						if move_tile.piece.color == enemy_side:
							movable_positions.append(move_tile)
						break
					movable_positions.append(move_tile)
				else:
					break
			for i in range(7):
				var move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x+(i+1), piece.place.y-(i+1)))
				if move_tile != null:
					if move_tile.piece != null:
						if move_tile.piece.color == enemy_side:
							movable_positions.append(move_tile)
						break
					movable_positions.append(move_tile)
				else:
					break
			for i in range(7):
				var move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x-(i+1), piece.place.y-(i+1)))
				if move_tile != null:
					if move_tile.piece != null:
						if move_tile.piece.color == enemy_side:
							movable_positions.append(move_tile)
						break
					movable_positions.append(move_tile)
				else:
					break
		Pieces.Queen:
			var enemy_side = Side.Black
			if piece.color != Side.White:
				enemy_side = Side.White
			for i in range(7):
				var move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x+(i+1), piece.place.y+(i+1)))
				if move_tile != null:
					if move_tile.piece != null:
						if move_tile.piece.color == enemy_side:
							movable_positions.append(move_tile)
						break
					movable_positions.append(move_tile)
				else:
					break
			for i in range(7):
				var move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x-(i+1), piece.place.y+(i+1)))
				if move_tile != null:
					if move_tile.piece != null:
						if move_tile.piece.color == enemy_side:
							movable_positions.append(move_tile)
						break
					movable_positions.append(move_tile)
				else:
					break
			for i in range(7):
				var move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x+(i+1), piece.place.y-(i+1)))
				if move_tile != null:
					if move_tile.piece != null:
						if move_tile.piece.color == enemy_side:
							movable_positions.append(move_tile)
						break
					movable_positions.append(move_tile)
				else:
					break
			for i in range(7):
				var move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x-(i+1), piece.place.y-(i+1)))
				if move_tile != null:
					if move_tile.piece != null:
						if move_tile.piece.color == enemy_side:
							movable_positions.append(move_tile)
						break
					movable_positions.append(move_tile)
				else:
					break
			for i in range(7):
				var move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x+(i+1), piece.place.y))
				if move_tile != null:
					if move_tile.piece != null:
						if move_tile.piece.color == enemy_side:
							movable_positions.append(move_tile)
						break
					movable_positions.append(move_tile)
				else:
					break
			for i in range(7):
				var move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x-(i+1), piece.place.y))
				if move_tile != null:
					if move_tile.piece != null:
						if move_tile.piece.color == enemy_side:
							movable_positions.append(move_tile)
						break
					movable_positions.append(move_tile)
				else:
					break
			for i in range(7):
				var move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x, piece.place.y-(i+1)))
				if move_tile != null:
					if move_tile.piece != null:
						if move_tile.piece.color == enemy_side:
							movable_positions.append(move_tile)
						break
					movable_positions.append(move_tile)
				else:
					break
			for i in range(7):
				var move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x, piece.place.y+(i+1)))
				if move_tile != null:
					if move_tile.piece != null:
						if move_tile.piece.color == enemy_side:
							movable_positions.append(move_tile)
						break
					movable_positions.append(move_tile)
				else:
					break
		Pieces.King:
			var enemy_side = Side.Black
			if piece.color != Side.White:
				enemy_side = Side.White
			var move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x-1, piece.place.y-1))
			if move_tile != null && (move_tile.piece != null && move_tile.piece.color == enemy_side || move_tile.piece == null):
				movable_positions.append(move_tile)
			move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x+1, piece.place.y-1))
			if move_tile != null && (move_tile.piece != null && move_tile.piece.color == enemy_side || move_tile.piece == null):
				movable_positions.append(move_tile)
			move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x-1, piece.place.y))
			if move_tile != null && (move_tile.piece != null && move_tile.piece.color == enemy_side || move_tile.piece == null):
				movable_positions.append(move_tile)
			move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x+1, piece.place.y))
			if move_tile != null && (move_tile.piece != null && move_tile.piece.color == enemy_side || move_tile.piece == null):
				movable_positions.append(move_tile)
			move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x-1, piece.place.y+1))
			if move_tile != null && (move_tile.piece != null && move_tile.piece.color == enemy_side || move_tile.piece == null):
				movable_positions.append(move_tile)
			move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x+1, piece.place.y+1))
			if move_tile != null && (move_tile.piece != null && move_tile.piece.color == enemy_side || move_tile.piece == null):
				movable_positions.append(move_tile)
			move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x, piece.place.y-1))
			if move_tile != null && (move_tile.piece != null && move_tile.piece.color == enemy_side || move_tile.piece == null):
				movable_positions.append(move_tile)
			move_tile = find_tile_by_position(tiles, Vector2i(piece.place.x, piece.place.y+1))
			if move_tile != null && (move_tile.piece != null && move_tile.piece.color == enemy_side || move_tile.piece == null):
				movable_positions.append(move_tile)
		Pieces.Pawn:
			var direction = -1
			var enemy_side = Side.Black
			if piece.color != Side.White:
				direction = 1
				enemy_side = Side.White
			
			# attack tiles
			var left_front_tile = find_tile_by_position(tiles, Vector2i(piece.place.x-1, piece.place.y+direction))
			if left_front_tile != null && left_front_tile.piece != null && left_front_tile.piece.color == enemy_side:
				movable_positions.append(left_front_tile)
			var right_front_tile = find_tile_by_position(tiles, Vector2i(piece.place.x+1, piece.place.y+direction))
			if right_front_tile != null && right_front_tile.piece != null && right_front_tile.piece.color == enemy_side:
				movable_positions.append(right_front_tile)
			# move tiles
			var front_tile = find_tile_by_position(tiles, Vector2i(piece.place.x, piece.place.y+direction))
			if front_tile != null && front_tile.piece == null:
				movable_positions.append(front_tile)
				if !piece.moved:
					var second_front_tile = find_tile_by_position(tiles, Vector2i(piece.place.x, piece.place.y+2*direction))
					if second_front_tile != null && second_front_tile.piece == null:
						movable_positions.append(second_front_tile)
	return movable_positions

func find_tile_by_position(tiles: Array[Node], _position: Vector2i) -> ChessTile:
	for tile in tiles:
		if tile.place == _position:
			return tile
	return null

func get_initial_board():
	var _board = [
		Piece.new(Vector2i(0,0), Pieces.Rook, Side.Black),
		Piece.new(Vector2i(1,0), Pieces.Knight, Side.Black),
		Piece.new(Vector2i(2,0), Pieces.Bishop, Side.Black),
		Piece.new(Vector2i(3,0), Pieces.Queen, Side.Black),
		Piece.new(Vector2i(4,0), Pieces.King, Side.Black),
		Piece.new(Vector2i(5,0), Pieces.Bishop, Side.Black),
		Piece.new(Vector2i(6,0), Pieces.Knight, Side.Black),
		Piece.new(Vector2i(7,0), Pieces.Rook, Side.Black),
		Piece.new(Vector2i(0,1), Pieces.Pawn, Side.Black),
		Piece.new(Vector2i(1,1), Pieces.Pawn, Side.Black),
		Piece.new(Vector2i(2,1), Pieces.Pawn, Side.Black),
		Piece.new(Vector2i(3,1), Pieces.Pawn, Side.Black),
		Piece.new(Vector2i(4,1), Pieces.Pawn, Side.Black),
		Piece.new(Vector2i(5,1), Pieces.Pawn, Side.Black),
		Piece.new(Vector2i(6,1), Pieces.Pawn, Side.Black),
		Piece.new(Vector2i(7,1), Pieces.Pawn, Side.Black),
		Piece.new(Vector2i(0,7), Pieces.Rook),
		Piece.new(Vector2i(1,7), Pieces.Knight),
		Piece.new(Vector2i(2,7), Pieces.Bishop),
		Piece.new(Vector2i(3,7), Pieces.Queen),
		Piece.new(Vector2i(4,7), Pieces.King),
		Piece.new(Vector2i(5,7), Pieces.Bishop),
		Piece.new(Vector2i(6,7), Pieces.Knight),
		Piece.new(Vector2i(7,7), Pieces.Rook),
		Piece.new(Vector2i(0,6), Pieces.Pawn),
		Piece.new(Vector2i(1,6), Pieces.Pawn),
		Piece.new(Vector2i(2,6), Pieces.Pawn),
		Piece.new(Vector2i(3,6), Pieces.Pawn),
		Piece.new(Vector2i(4,6), Pieces.Pawn),
		Piece.new(Vector2i(5,6), Pieces.Pawn),
		Piece.new(Vector2i(6,6), Pieces.Pawn),
		Piece.new(Vector2i(7,6), Pieces.Pawn)
	]
	return _board

func copy_chess_grid(grid: Array):
	# TODO make copying of chess grid
	var new_grid = []
	for tile in grid:
		var copyTile = ChessTileModel.new()
		new_grid.append(copyTile)
	return new_grid

func get_king_killers(side: Side, grid: Array):
	var enemy_side = Side.White
	if side == Side.White:
		enemy_side = Side.Black
	var killers = []
	for tile in grid:
		if tile.piece != null && tile.piece.side == enemy_side:
			for place in tile.movable_places:
				if place.piece != null && place.piece.figure == Pieces.King && place.piece.side == side:
					killers.append(place)
	return killers
	
