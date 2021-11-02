#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Control

#  -------------------------
# |  SIGNAL RESPONSES       |
#  -------------------------


#  -------------------------
# |  LEVEL INFO             |
#  -------------------------

signal updated()

var number = ""
var description = ""
var difficulty = 0
var sudoku = ""
enum Progress {SOLVED, IN_PROGRESS, FAILED, NOT_ATTEMPTED}
var progress = Progress.IN_PROGRESS

func update_level_info(number, difficulty, description, sudoku, progress):
	self.number = number
	self.difficulty = difficulty
	self.description = description
	self.sudoku = sudoku
	self.progress = progress
	emit_signal("updated")
