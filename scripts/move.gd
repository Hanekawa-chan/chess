class_name Move extends Resource

var old: Vector2i
var new: Vector2i
var piece: Game.Pieces
var second_piece: Game.Pieces
var converted: bool
var castling_type: History.CastlingType
var check_mate: History.CheckMate
var player_place: int
