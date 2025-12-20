class_name Game extends Control

@onready var dead_counters = %DeadCounters
@onready var choosable_pieces = %ChoosablePieces
@onready var move_number_label = %MoveNumberLabel
@onready var current_side_label = %CurrentSideLabel
@onready var board = %Board
@onready var pieces = %Pieces
@onready var chess_grid = %ChessGrid
@onready var current_side = Side.White
var move_number: int = 1:
	set(value):
		move_number_label.text = "move number: " + str(value)
		move_number = value
		if move_number % 2 == 1:
			current_side = Side.White
			current_side_label.text = "white is playing"
		else:
			current_side = Side.Black
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
			for t in tile.special_moves:
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
			for t in tile.special_moves:
				old_tile = board.get_cell_atlas_coords(t.place)
				board.set_cell(t.place, 0, Vector2i(old_tile.x, old_tile.y-2))
		print("new active piece ", value, " old place ", old_place)
var pawn_to_transfigure: Piece = null

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

func _set_scale():
	var _scale = chess_grid.size.x/8/16
	print("size ", chess_grid.size, "scale ", _scale)
	board.apply_scale(Vector2(_scale/board.scale.x, _scale/board.scale.y))
	pieces.apply_scale(Vector2(_scale/pieces.scale.x, _scale/pieces.scale.y))
	

func _ready():
	chess_grid.resized.connect(_set_scale)
	var _board = get_test_initial_board()
	for cell in chess_grid.get_children():
		cell.initialize()
		for piece in _board:
			if piece.place == cell.place:
				cell.piece = piece
				piece.tile = cell
				break
	get_available_moves(chess_grid.get_children())
	
func pawn_to_figure(figure: Pieces):
	if pawn_to_transfigure != null:
		pawn_to_transfigure.change_figure_on_grid(figure)
		pawn_to_transfigure = null

func new_round(grid: Array, pawn: ChessTile):
	var fake_grid = copy_chess_grid(grid)
	get_available_moves(fake_grid)
	var has_moves = reduce_moves(fake_grid, current_side)
	has_moves = castle_moves(fake_grid, current_side, has_moves)
	has_moves = enpassant(pawn, fake_grid, current_side, has_moves)
	if has_moves:
		realize_moves(fake_grid)
	else:
		loose(current_side)
	
func loose(side):
	print(Side.keys()[side], " player lost")

func enpassant(pawn: ChessTile, grid: Array, side: Side, has_moves: bool):
	if pawn == null:
		print("pawn == null")
		return has_moves
	var a_pawn = find_tile_by_position(grid, pawn.place)
	var enpassant_pos = Vector2i(a_pawn.place)
	var direction = -1
	if pawn.piece.color == Side.White:
		enpassant_pos.y += 1
		direction = 1
	else:
		enpassant_pos.y -= 1
	var enpassant_tile = find_tile_by_position(grid, enpassant_pos)
	# TODO add has_moves update
	for t in grid:
		if t.piece != null && t.piece.figure == Pieces.Pawn && t.piece.color == side:
			print("enemy pawn found")
			print("t place: ", t.place, " enpassant pos: ", enpassant_pos, " direction: ", direction)
			if abs(t.place.x - enpassant_pos.x) == 1 && enpassant_pos.y - t.place.y == direction:
				print("enemy pawn that can enpassant found")
				var simulated_grid = simulate_move(a_pawn, enpassant_tile, grid)
				simulated_grid = simulate_move(t, enpassant_tile, simulated_grid)
				get_available_moves(simulated_grid)
				var killers = get_king_killers(side, simulated_grid)
				if len(killers) > 0:
					continue
				t.special_moves.append(enpassant_tile)
				if len(a_pawn.special_moves) > 1:
					print("pawn already has special moves")
					continue
				a_pawn.special_moves.append(enpassant_tile)
	return has_moves

func castle_moves(grid: Array, side: Side, has_moves: bool):
	var movable_pieces = 0
	var king = null
	var rooks = []
	for tile in grid:
		if tile.piece != null && tile.piece.color == side && !tile.piece.moved:
			if tile.piece.figure == Pieces.King:
				king = tile
			if tile.piece.figure == Pieces.Rook:
				rooks.append(tile)
	if len(rooks) == 0 || king == null:
		return has_moves
	var left_side = false
	var right_side = false
	for p in king.movable_places:
		if p.place.x == 3:
			left_side = true
		if p.place.x == 5:
			right_side = true
	if !(right_side || left_side):
		return has_moves
	var free_rooks = []
	for r in rooks:
		if r.place.x == 0:
			var first = false
			var second = false
			var third = false
			for p in r.movable_places:
				if p.place.x == 1:
					first = true
				if p.place.x == 2:
					second = true
				if p.place.x == 3:
					third = true
			if first && second && third:
				free_rooks.append(r)
		if r.place.x == 7:
			var first = false
			var second = false
			for p in r.movable_places:
				if p.place.x == 6:
					first = true
				if p.place.x == 5:
					second = true
			if first && second:
				free_rooks.append(r)
	if len(free_rooks) == 0:
		return has_moves
	for r in free_rooks:
		var king_pos = 2
		var rook_pos = 3
		var king_place
		var rook_place
		if r.place.x == 0:
			king_pos = 2
			rook_pos = 3
		if r.place.x == 7:
			king_pos = 6
			rook_pos = 5
		for p in grid:
			if p.place.x == rook_pos:
				rook_place = p
			if p.place.x == king_pos:
				king_place = p
		var simulated_grid = simulate_move(r, rook_place, grid)
		simulated_grid = simulate_move(king, king_place, simulated_grid)
		get_available_moves(simulated_grid)
		var killers = get_king_killers(side, simulated_grid)
		if len(killers) > 0:
			break
		# TODO add special moves as array to tile moving system
		r.special_moves.append(rook_place)
		king.special_moves.append(king_place)
		movable_pieces+=1
	return movable_pieces > 0 || has_moves

func get_available_moves(grid: Array):
	for tile in grid:
		if tile.piece != null:
			tile.movable_places = get_all_moves(tile.piece, grid)

func find_tile_by_position(tiles: Array, _position: Vector2i):
	for tile in tiles:
		if tile.place == _position:
			return tile
	return null

func copy_chess_grid(grid: Array):
	var new_grid = []
	for tile in grid:
		var copy_tile = tile.convert_to_model()
		new_grid.append(copy_tile)
	for tile in new_grid:
		var mov_pos = tile.movable_places
		var spec_movs = tile.special_moves
		tile.movable_places = []
		tile.special_moves = []
		for pos in mov_pos:
			tile.movable_places.append(find_tile_by_position(new_grid, pos.place))
		for pos in spec_movs:
			# TODO for some reason special moves are fucking endless
			tile.special_moves.append(find_tile_by_position(new_grid, pos.place))
	return new_grid

func realize_moves(grid: Array):
	for tile in grid:
		for t in chess_grid.get_children():
			if tile.place == t.place:
				if t.piece != null:
					t.movable_places = tile.convert_movable_places(chess_grid.get_children())
					t.special_moves = tile.convert_special_moves(chess_grid.get_children())

func get_king_killers(side: Side, grid: Array):
	var enemy_side = Side.White
	if side == Side.White:
		enemy_side = Side.Black
	var killers = []
	for tile in grid:
		if tile.piece != null && tile.piece.color == enemy_side:
			for place in tile.movable_places:
				if place.piece != null && place.piece.figure == Pieces.King && place.piece.color == side:
					killers.append(place)
					#print("killer of my pingas ", place.place)
	return killers
	
func reduce_moves(grid: Array, side):
	var movable_pieces = 0
	for tile in grid:
		var not_movable_places = []
		for place in tile.movable_places:
			var simulated_grid = simulate_move(tile, place, grid)
			get_available_moves(simulated_grid)
			#print_grid(simulated_grid)
			var killers = get_king_killers(side, simulated_grid)
			if len(killers) > 0:
				not_movable_places.append(place)
		for place in not_movable_places:
			tile.movable_places.erase(place)
		if tile.piece != null && tile.piece.color == side && len(tile.movable_places) > 0:
			movable_pieces += 1
	return movable_pieces > 0

func print_grid(grid: Array):
		#print("start")
	for tile in grid:
		if tile.piece != null:
			var piece = tile.piece
			var place = tile.place
			print("Pos:", place, " Fig:", Pieces.keys()[piece.figure], " Color:", Side.keys()[piece.color])

# simulate_move duplicates grid and deletes piece on the old tile and places it on the new tile on duplicated grid
func simulate_move(tile, place, grid):
	var new_grid = []
	for t in grid:
		var new_tile = t.make_copy()
		if new_tile.piece != null && new_tile.piece.place == tile.piece.place:
			new_tile.piece = null
		if new_tile.place == place.place:
			# TODO maybe problem is that it thinks that tiles have special moves
			new_tile.piece = tile.piece.make_copy()
			new_tile.piece.tile_model = new_tile
		new_grid.append(new_tile)
	
	return new_grid

func get_test_initial_board():
	var _board = [
		Piece.new(Vector2i(4,7), Pieces.King),
		Piece.new(Vector2i(3,6), Pieces.Pawn),
		Piece.new(Vector2i(4,4), Pieces.Pawn, Side.Black),
	]
	return _board

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


func get_all_moves(piece: Piece, tiles: Array) -> Array:
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
