extends Node

@onready var white_pawn_counter = %WhitePawnCounter
var white_pawn: int = 0:
	set(value):
		white_pawn = value
		white_pawn_counter.text = str(white_pawn)
		var particle = white_pawn_counter.get_child(0) as CPUParticles2D
		particle.emitting = true
@onready var white_knight_counter = %WhiteKnightCounter
var white_knight: int = 0:
	set(value):
		white_knight = value
		white_knight_counter.text = str(white_knight)
		var particle = white_knight_counter.get_child(0) as CPUParticles2D
		particle.emitting = true
@onready var white_bishop_counter = %WhiteBishopCounter
var white_bishop: int = 0:
	set(value):
		white_bishop = value
		white_bishop_counter.text = str(white_bishop)
		var particle = white_bishop_counter.get_child(0) as CPUParticles2D
		particle.emitting = true
@onready var white_rook_counter = %WhiteRookCounter
var white_rook: int = 0:
	set(value):
		white_rook = value
		white_rook_counter.text = str(white_rook)
		var particle = white_rook_counter.get_child(0) as CPUParticles2D
		particle.emitting = true
@onready var white_queen_counter = %WhiteQueenCounter
var white_queen: int = 0:
	set(value):
		white_queen = value
		white_queen_counter.text = str(white_queen)
		var particle = white_queen_counter.get_child(0) as CPUParticles2D
		particle.emitting = true
@onready var black_pawn_counter = %BlackPawnCounter
var black_pawn: int = 0:
	set(value):
		black_pawn = value
		black_pawn_counter.text = str(black_pawn)
		var particle = black_pawn_counter.get_child(0) as CPUParticles2D
		particle.emitting = true
@onready var black_knight_counter = %BlackKnightCounter
var black_knight: int = 0:
	set(value):
		black_knight = value
		black_knight_counter.text = str(black_knight)
		var particle = black_knight_counter.get_child(0) as CPUParticles2D
		particle.emitting = true
@onready var black_bishop_counter = %BlackBishopCounter
var black_bishop: int = 0:
	set(value):
		black_bishop = value
		black_bishop_counter.text = str(black_bishop)
		var particle = black_bishop_counter.get_child(0) as CPUParticles2D
		particle.emitting = true
@onready var black_rook_counter = %BlackRookCounter
var black_rook: int = 0:
	set(value):
		black_rook = value
		black_rook_counter.text = str(black_rook)
		var particle = black_rook_counter.get_child(0) as CPUParticles2D
		particle.emitting = true
@onready var black_queen_counter = %BlackQueenCounter
var black_queen: int = 0:
	set(value):
		black_queen = value
		black_queen_counter.text = str(black_queen)
		var particle = black_queen_counter.get_child(0) as CPUParticles2D
		particle.emitting = true

func set_count(color: Game.Side, fig: Game.Pieces):
	if color == Game.Side.White:
		if fig == Game.Pieces.Pawn:
			white_pawn += 1
		if fig == Game.Pieces.Knight:
			white_knight += 1
		if fig == Game.Pieces.Bishop:
			white_bishop += 1
		if fig == Game.Pieces.Rook:
			white_rook += 1
		if fig == Game.Pieces.Queen:
			white_queen += 1
	else:
		if fig == Game.Pieces.Pawn:
			black_pawn += 1
		if fig == Game.Pieces.Knight:
			black_knight += 1
		if fig == Game.Pieces.Bishop:
			black_bishop += 1
		if fig == Game.Pieces.Rook:
			black_rook += 1
		if fig == Game.Pieces.Queen:
			black_queen += 1
