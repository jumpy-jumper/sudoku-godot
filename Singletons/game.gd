#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Node2D

func _ready():
	randomize()

#  -------------------------
# |  PERSISTENT VARIABLES   |
#  -------------------------

var sudoku_to_load = {
	"numbers" : "020000600000090070500001000000600003700005001060370080004000008800002007071040200",
	"solution" : "923587614618493572547261839485619723739825461162374985254736198896152347371948256",
}

#  -------------------------
# |  HELPERS                |
#  -------------------------

func get_file_as_text(path):
	var file = File.new()
	file.open(path, File.READ)
	var text = file.get_as_text()
	file.close()
	return text

func _on_Back_pressed():
	get_tree().change_scene("res://Title/title.tscn")
