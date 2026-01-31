class_name BoardLogic extends Node

# TODO replace with actual logic
static func lose(side):
	if MultiplayerManager.player_side == side:
		GlobalPopup.show_popup("You lost", true)
	else:
		GlobalPopup.show_popup("You won", true)


static func enpassant(pawn: ChessTile, grid: Array, side: Game.Side, has_moves: bool):
	if pawn == null:
		print("pawn == null")
		return has_moves
	var a_pawn = find_tile_by_position(grid, pawn.place)
	var enpassant_pos = Vector2i(a_pawn.place)
	var direction = -1
	if pawn.piece.color == Game.Side.White:
		enpassant_pos.y += 1
		direction = 1
	else:
		enpassant_pos.y -= 1
	var enpassant_tile = find_tile_by_position(grid, enpassant_pos)
	# TODO add has_moves update
	for t in grid:
		if t.piece != null && t.piece.figure == Game.Pieces.Pawn && t.piece.color == side:
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

static func castle_moves(grid: Array, side: Game.Side, has_moves: bool):
	var movable_pieces = 0
	var king = null
	var rooks = []
	for tile in grid:
		if tile.piece != null && tile.piece.color == side && !tile.piece.moved:
			if tile.piece.figure == Game.Pieces.King:
				king = tile
			if tile.piece.figure == Game.Pieces.Rook:
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
			if p.place.x == rook_pos and p.place.y == r.place.y:
				rook_place = p
			if p.place.x == king_pos and p.place.y == r.place.y:
				king_place = p
		var simulated_grid = simulate_move(r, rook_place, grid)
		simulated_grid = simulate_move(king, king_place, simulated_grid)
		get_available_moves(simulated_grid)
		var killers = get_king_killers(side, simulated_grid)
		if len(killers) > 0:
			break
		r.special_moves.append(rook_place)
		king.special_moves.append(king_place)
		movable_pieces+=1
	return movable_pieces > 0 || has_moves

static func get_available_moves(grid: Array):
	for tile in grid:
		if tile.piece != null:
			tile.movable_places = get_all_moves(tile.piece, grid)

static func find_tile_by_position(tiles: Array, _position: Vector2i):
	for tile in tiles:
		if tile.place == _position:
			return tile
	return null

static func copy_chess_grid(grid: Array):
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
			tile.special_moves.append(find_tile_by_position(new_grid, pos.place))
	return new_grid

static func realize_moves(grid: Array, chess_grid):
	for tile in grid:
		for t in chess_grid.get_children():
			if tile.place == t.place:
				if t.piece != null:
					t.movable_places = tile.convert_movable_places(chess_grid.get_children())
					t.special_moves = tile.convert_special_moves(chess_grid.get_children())

static func get_king_killers(side: Game.Side, grid: Array):
	var enemy_side = Game.Side.White
	if side == Game.Side.White:
		enemy_side = Game.Side.Black
	var killers = []
	for tile in grid:
		if tile.piece != null && tile.piece.color == enemy_side:
			for place in tile.movable_places:
				if place.piece != null && place.piece.figure == Game.Pieces.King && place.piece.color == side:
					killers.append(place)
					#print("killer of my pingas ", place.place)
	return killers
	
static func reduce_moves(grid: Array, side: Game.Side):
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
			print("Pos:", place, " Fig:", Game.Pieces.keys()[piece.figure], " Color:", Game.Side.keys()[piece.color])

# simulate_move duplicates grid and deletes piece on the old tile and places it on the new tile on duplicated grid
static func simulate_move(tile, place, grid):
	var new_grid = []
	for t in grid:
		var new_tile = t.make_copy()
		if new_tile.piece != null && new_tile.piece.place == tile.piece.place:
			new_tile.piece = null
		if new_tile.place == place.place:
			new_tile.piece = tile.piece.make_copy()
			new_tile.piece.tile_model = new_tile
		new_grid.append(new_tile)
	
	return new_grid


static func get_all_moves(piece: Piece, tiles: Array) -> Array:
	var movable_positions = []
	match piece.figure:
		Game.Pieces.Rook:
			var enemy_side = Game.Side.Black
			if piece.color != Game.Side.White:
				enemy_side = Game.Side.White
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
		Game.Pieces.Knight:
			var enemy_side = Game.Side.Black
			if piece.color != Game.Side.White:
				enemy_side = Game.Side.White
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
		Game.Pieces.Bishop:
			var enemy_side = Game.Side.Black
			if piece.color != Game.Side.White:
				enemy_side = Game.Side.White
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
		Game.Pieces.Queen:
			var enemy_side = Game.Side.Black
			if piece.color != Game.Side.White:
				enemy_side = Game.Side.White
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
		Game.Pieces.King:
			var enemy_side = Game.Side.Black
			if piece.color != Game.Side.White:
				enemy_side = Game.Side.White
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
		Game.Pieces.Pawn:
			var direction = -1
			var enemy_side = Game.Side.Black
			if piece.color != Game.Side.White:
				direction = 1
				enemy_side = Game.Side.White
			
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
