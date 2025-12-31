class_name ChessTile extends Button

@onready
var game: Game = $"../../../../../../../../../.."
@onready
var pieces = %Pieces

#TODO make setter a distinct function with grid as argument, because we need to find tile in it
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
		else:
			movable_places = []
			special_moves = []
		piece = value
		var new_tile =  Vector2i(-1,-1)
		if piece != null:
			piece.tile = self
			if piece.color == Game.Side.White:
				new_tile = game.white_piece_tiles_array[piece.figure]
			else:
				new_tile = game.black_piece_tiles_array[piece.figure]
		pieces.set_cell(place, 0, new_tile)
		if value != null:
			if value.figure == Game.Pieces.Pawn && ((place.y==0 && value.color == Game.Side.White) || (place.y==7 && value.color == Game.Side.Black)):
				print("pawn can be changed to other figures")
				game.pawn_to_transfigure = value

@export
var place: Vector2i
@export
var movable_places: Array
@export
var special_moves: Array
@export
var tile_id: int = 0

# Called when the node enters the scene tree for the first time.
func initialize():
	var n = String(name)
	var y = String(n[0]).to_int()
	var x = String(n[1]).to_int()
	place = Vector2i(x, y)
	tile_id = x + y * 8
	button_up.connect(_on_button_up)
	#var atlas = pieces.get_cell_atlas_coords(place)
	#piece = Piece.new(place, game.piece_tiles_dict.get(atlas))


func _set_active_piece(_piece: Piece):
	if _piece != null:
		set_active_piece.rpc(_piece.place)
	else:
		set_active_piece.rpc(Vector2i(-1,-1))

func _set_piece(_piece: Piece):
	if _piece != null:
		set_piece.rpc(_piece.place)
	else:
		set_piece.rpc(Vector2i(-1,-1))

@rpc("any_peer", "call_local")
func set_active_piece(piece_place: Vector2i):
	print("did it happen? set_active_piece ", MultiplayerManager.player_name)
	var _piece: Piece = null
	if piece_place != Vector2i(-1,-1):
		_piece = game.find_tile_by_position(game.chess_grid.get_children(), piece_place).piece
	game.active_piece = _piece

@rpc("any_peer", "call_local")
func set_piece(piece_place: Vector2i):
	print("did it happen? set_piece ", MultiplayerManager.player_name)
	var _piece: Piece = null
	if piece_place != Vector2i(-1,-1):
		_piece = game.find_tile_by_position(game.chess_grid.get_children(), piece_place).piece
	piece = _piece

@rpc("any_peer", "call_local")
func increase_move_number():
	print("did it happen? increase_move_number ", MultiplayerManager.player_name)
	game.move_number += 1

@rpc("any_peer", "call_local")
func set_dead_count(color, figure):
	print("did it happen? set_dead_count ", MultiplayerManager.player_name)
	game.dead_counters.set_count(color, figure)

func _on_button_up():
	print("player side ", MultiplayerManager.player_side)
	print("current side ", game.current_side)
	if game.current_side == MultiplayerManager.player_side:
		if piece != null && ((game.active_piece == null && MultiplayerManager.player_side == piece.color) || (game.active_piece != null && MultiplayerManager.player_side != piece.color)):
			#print("clicked me! Pos:", place, " Fig:", Game.Pieces.keys()[piece.figure], " Color:", Game.Side.keys()[piece.color], " Available moves:", movable_places)
			if game.active_piece != null:
				if game.active_piece.color == piece.color:
					_set_active_piece(piece)
				else:
					var active_piece = game.active_piece
					_set_active_piece(null)
					for pos in active_piece.tile.movable_places:
						if pos.place == place:
							# PIECE MOVES
							set_dead_count.rpc(piece.color, piece.figure)
							#print("active", active_piece)
							_set_piece(active_piece)
							increase_move_number.rpc()
							game.new_round.rpc(Vector2i(-1,-1))
							break
			else:
				_set_active_piece(piece)
		else:
			#print("clicked me! Pos:", place, " Empty")
			var active_piece = game.active_piece
			if active_piece != null:
				_set_active_piece(null)
				for pos in active_piece.tile.movable_places:
					if pos.place == place:
						# PIECE MOVES
						#print("active", active_piece)
						var is_enpassantable = false
						if active_piece.figure == Game.Pieces.Pawn && abs(active_piece.place.y - pos.place.y) == 2:
							is_enpassantable = true
						_set_piece(active_piece)
						increase_move_number.rpc()
						if is_enpassantable:
							game.new_round.rpc(self.place)
						else:
							game.new_round.rpc(Vector2i(-1,-1))
						break
				for pos in active_piece.tile.special_moves:
					if pos.place == place:
						# PIECE DOES SPECIAL MOVE
						#print("active", active_piece)
						if active_piece.figure == Game.Pieces.King:
							for t in game.chess_grid.get_children():
								if place.x == 2:
									if t.piece != null && t.piece.color == active_piece.color && t.piece.figure == Game.Pieces.Rook && len(t.special_moves) > 0 && t.place.x == 0:
										var rook_place = game.find_tile_by_position(game.chess_grid.get_children(), Vector2i(3, active_piece.place.y))
										rook_place._set_piece(t.piece)
										break
								if place.x == 6:
									if t.piece != null && t.piece.color == active_piece.color && t.piece.figure == Game.Pieces.Rook && len(t.special_moves) > 0 && t.place.x == 7:
										var rook_place = game.find_tile_by_position(game.chess_grid.get_children(), Vector2i(5, active_piece.place.y))
										rook_place._set_piece(t.piece)
										break
						if active_piece.figure == Game.Pieces.Pawn:
							for t in game.chess_grid.get_children():
								if t.piece != null && t.piece.figure == Game.Pieces.Pawn && t.piece.color != active_piece.color:
									if len(t.special_moves) > 0:
										set_dead_count.rpc(t.piece.color, t.piece.figure)
										t._set_piece(null)
										break
						_set_piece(active_piece)
						increase_move_number.rpc()
						game.new_round.rpc(Vector2i(-1,-1))
						break
					
func convert_to_model():
	var copy_tile = ChessTileModel.new()
	if piece != null:
		var _piece = piece.make_copy()
		_piece.tile_model = copy_tile
		copy_tile.piece = _piece
	copy_tile.movable_places = movable_places
	copy_tile.special_moves = special_moves
	copy_tile.place = Vector2i(place)
	return copy_tile

func change_figure_tile():
	var new_tile =  Vector2i(-1,-1)
	if piece.color == Game.Side.White:
		new_tile = game.white_piece_tiles_array[piece.figure]
	else:
		new_tile = game.black_piece_tiles_array[piece.figure]
	pieces.set_cell(place, 0, new_tile)
