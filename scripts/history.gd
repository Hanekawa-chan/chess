class_name History extends Node

enum CastlingType {
	None,
	Short,
	Long
}

enum CheckMate {
	None,
	Check,
	Mate
}

static func add_move(old, new: Vector2i, piece, second_piece: Game.Pieces, converted: bool, castling_type: CastlingType, check_mate: CheckMate, player_place, move_number: int, first_history, second_history: RichTextLabel):
	if player_place == 0:
		return
	print("adding move old: ", old, " new: ", new, " piece: ", Game.Pieces.keys()[piece], " 2nd piece: ", Game.Pieces.keys()[second_piece], " player ", player_place)
	var text_to_edit = second_history 
	if player_place == 1:
		text_to_edit = first_history

	var piece_moved = piece_converter(piece)
	var second_piece_letter = piece_converter(second_piece)
			
	var old_place = place_converter(old)
	var new_place = place_converter(new)
	var take = ""
	if second_piece != Game.Pieces.Empty && !converted:
		take = "x"
	var checkmate = ""
	match check_mate:
		CheckMate.Check:
			checkmate = "+"
		CheckMate.Mate:
			checkmate = "#"
	match castling_type: 
		CastlingType.None:
			text_to_edit.append_text(str(move_number)+". "+piece_moved + old_place + take + second_piece_letter + new_place + checkmate + "\n")
		CastlingType.Short:
			text_to_edit.append_text(str(move_number)+". 0-0\n")
		CastlingType.Long:
			text_to_edit.append_text(str(move_number)+". 0-0-0\n")

static func place_converter(place: Vector2i) -> String:
	var letters = ["a", "b", "c", "d", "e", "f", "g", "h"]
	var litera = letters[place.x]+str(abs(place.y-8))
	return litera

static func piece_converter(piece: Game.Pieces):
	var piece_letter = ""
	match piece:
		Game.Pieces.Pawn:
			piece_letter = "P"
		Game.Pieces.Bishop:
			piece_letter = "B"
		Game.Pieces.Knight:
			piece_letter = "N"
		Game.Pieces.Rook:
			piece_letter = "R"
		Game.Pieces.Queen:
			piece_letter = "Q"
		Game.Pieces.King:
			piece_letter = "K"
	return piece_letter
