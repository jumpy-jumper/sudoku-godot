#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Node2D

onready var level = get_parent()
onready var difficulty_highlight = $DifficultyHighlight
onready var label = $Label
onready var thick_border = $ThickBorder

func _on_Level_updated():
	label.text = level.number
	
	if level.difficulty == 0:
		difficulty_highlight.modulate.r = 0
		difficulty_highlight.modulate.g = 1
		difficulty_highlight.modulate.b = 1
	else:
		difficulty_highlight.modulate.g = 1 - (level.difficulty/10)
		difficulty_highlight.modulate.b = 1 - (level.difficulty/10)
	
	match(level.progress):
		level.Progress.SOLVED:
			label.modulate = Color.gold
		level.Progress.IN_PROGRESS:
			label.modulate = Color.cyan
		level.Progress.FAILED:
			label.modulate = Color.lightcoral
		level.Progress.NOT_ATTEMPTED:
			label.modulate = Color.white

func _on_Clickable_mouse_status_changed(hovered, clicked):
	thick_border.visible = hovered or clicked
