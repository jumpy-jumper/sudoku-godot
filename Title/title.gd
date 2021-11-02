#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Node2D

func _ready():
	pass

func _process(dt):
	pass

func _input(event):
	pass

#  -------------------------
# |  SIGNAL RESPONSES       |
#  -------------------------

func _on_StartButton_pressed():
	get_tree().change_scene("res://LevelSelect/level_select.tscn")
