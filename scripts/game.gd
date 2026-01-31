class_name Game extends Control

@onready var player_name_label = %PlayerNameLabel
@onready var dead_counters = %DeadCounters
@onready var choosable_pieces = %ChoosablePieces
@onready var move_number_label = %MoveNumberLabel
@onready var current_side_label = %CurrentSideLabel
@onready var first_player_history: RichTextLabel = %FirstPlayerHistory
@onready var second_player_history: RichTextLabel = %SecondPlayerHistory
@onready var options_button = %OptionsButton
@onready var board = %Board
@onready var pieces = %Pieces
@onready var chess_grid = %ChessGrid
@onready var current_side = Side.White
@onready var ended: bool = false
var move_number: int = 1:
	set(value):
		move_number_label.text = " move number: " + str(value)
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
var last_move: Move = null

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

@rpc("any_peer", "call_local")
func set_last_move(move: Move):
	last_move = move

func _set_scale():
	var _scale = chess_grid.size.x/8/16
	print("size ", chess_grid.size, "scale ", _scale)
	board.apply_scale(Vector2(_scale/board.scale.x, _scale/board.scale.y))
	pieces.apply_scale(Vector2(_scale/pieces.scale.x, _scale/pieces.scale.y))

func _ready():
	choosable_pieces.visible = false
	player_name_label.text = " name: "+MultiplayerManager.player_name
	chess_grid.resized.connect(_set_scale)
	options_button.pressed.connect(_open_options)
	var _board = get_transfigure_test_initial_board()
	for cell in chess_grid.get_children():
		cell.initialize()
		for piece in _board:
			if piece.place == cell.place:
				cell.piece = piece
				piece.tile = cell
				break
	BoardLogic.get_available_moves(chess_grid.get_children())
	
func _open_options():
	Options.open(_switch_visible)

func _switch_visible():
	self.visible = !self.visible
	
@rpc("any_peer", "call_local")
func pawn_to_figure(figure: Pieces):
	last_move.converted = true
	last_move.second_piece = figure
	pawn_to_transfigure.change_figure_on_grid(figure)
	pawn_to_transfigure = null
	new_round(Vector2i(-1,-1))

@rpc("any_peer", "call_local")
func new_round(_pawn: Vector2i):
	print("new round happened? ", MultiplayerManager.player_name)
	move_number += 1
	var fake_grid = BoardLogic.copy_chess_grid(chess_grid.get_children())
	var pawn: ChessTile
	if _pawn.x == -1:
		pawn = null
	else:
		pawn = BoardLogic.find_tile_by_position(chess_grid.get_children(), _pawn)
	BoardLogic.get_available_moves(fake_grid)
	var has_moves =  BoardLogic.reduce_moves(fake_grid, current_side)
	has_moves = BoardLogic.castle_moves(fake_grid, current_side, has_moves)
	has_moves = BoardLogic.enpassant(pawn, fake_grid, current_side, has_moves)
	var killers = BoardLogic.get_king_killers(current_side, fake_grid)
	if len(killers) > 0:
		last_move.check_mate = History.CheckMate.Check
	if has_moves:
		BoardLogic.realize_moves(fake_grid, chess_grid)
	else:
		BoardLogic.lose(current_side)
		ended = true
		last_move.check_mate = History.CheckMate.Mate
	if pawn == null:
		if last_move.player_place != 0:
			add_to_history.rpc(last_move.old, last_move.new, last_move.piece, last_move.second_piece, last_move.converted, last_move.castling_type, last_move.check_mate, last_move.player_place)
		last_move = null
	choosable_pieces.visible = false

@rpc("any_peer","call_local")
func add_to_history(old, new: Vector2i, piece, second_piece: Pieces, converted: bool, castling_type: History.CastlingType, check_mate: History.CheckMate, player_place: int):
	History.add_move(old, new, piece, second_piece, converted, castling_type, check_mate, player_place, first_player_history, second_player_history)

func get_end_test_initial_board():
	var _board = [
		Piece.new(Vector2i(4,7), Pieces.King),
		Piece.new(Vector2i(2,2), Pieces.Queen),
		Piece.new(Vector2i(3,2), Pieces.Queen),
		Piece.new(Vector2i(4,2), Pieces.Queen),
		Piece.new(Vector2i(5,2), Pieces.Queen),
		Piece.new(Vector2i(4,0), Pieces.King, Side.Black),
		Piece.new(Vector2i(7,0), Pieces.Rook, Side.Black),
	]
	return _board
	
func get_transfigure_test_initial_board():
	var _board = [
		Piece.new(Vector2i(4,7), Pieces.King),
		Piece.new(Vector2i(2,1), Pieces.Pawn),
		Piece.new(Vector2i(4,0), Pieces.King, Side.Black),
		Piece.new(Vector2i(7,0), Pieces.Rook, Side.Black),
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
