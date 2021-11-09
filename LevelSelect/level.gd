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
var sudoku = "000000000000000000000000000000000000000000000000000000000000000000000000000000000"
var solution = "000000000000000000000000000000000000000000000000000000000000000000000000000000000"
enum Progress {SOLVED, IN_PROGRESS, FAILED, NOT_ATTEMPTED}
var progress = Progress.NOT_ATTEMPTED

func update_level_info(number, difficulty, description, sudoku, progress):
	self.number = number
	self.difficulty = difficulty
	self.description = description
	self.sudoku = sudoku
	self.progress = progress
	emit_signal("updated")

func _on_Clickable_pressed():
	Game.sudoku_to_load = {
		"name" : number + ". " + description,
		"numbers" : sudoku,
		"solution" : solution,
	}
	Game.load_stage()
