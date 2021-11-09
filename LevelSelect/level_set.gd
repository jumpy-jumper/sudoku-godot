#  -------------------------
# |  MAIN                   |
#  -------------------------

extends GridContainer

func _ready():
	initialize_levels()
	load_savedata()

#  -------------------------
# |  LEVEL INITIALIZATION   |
#  -------------------------

var level_template = preload("res://LevelSelect/level.tscn")

var levels = []

func initialize_levels():
	var levels = Game.get_file_as_text("res://LevelSelect/levels.png")
	levels = levels.replace("\n", "")
	levels = levels.replace("\r", "")
	levels = levels.split("@")
	for i in range(len(levels) / 3):
		var level = level_template.instance()
		level.name = str(i+1)
		add_child(level)
		level.difficulty = float(levels[3*i+1])
		level.description = levels[3*i+2]
		level.sudoku = levels[3*i+3]
		level.update_level_info(str(i+1), float(levels[3*i+1]), levels[3*i+2], \
			levels[3*i+3], level.Progress.NOT_ATTEMPTED)
		level.get_node("Controller/Clickable").connect("mouse_status_changed", \
			self, "_on_Level_mouse_status_changed", [level])
		self.levels.append(level)

func load_savedata():
	var save_file = File.new()
	var savedata = Game.get_savedata()
	if savedata:
		for level in levels:
			var level_savedata = {}
			if savedata.has(get_level_id(level).md5_text()):
				level_savedata = parse_json(savedata[get_level_id(level).md5_text()])
			var progress = level.Progress.NOT_ATTEMPTED
			if level_savedata:
				if level_savedata.has("won") and level_savedata["won"]:
					progress = level.Progress.SOLVED
				else:
					progress = level.Progress.IN_PROGRESS
			level.update_level_info(level.number, level.difficulty, \
				level.description, level.sudoku, progress)

onready var level_description = $UI/LevelDescription
func _on_Level_mouse_status_changed(hovered, clicked, level):
	if hovered:
		level_description.text = ((level.number + ". " if level.number != "" else "") + level.description)
	elif level_description.text == get_level_id(level):
		level_description.text = ""

func get_level_id(level):
	return ((level.number + ". " if level.number != "" else "") + level.description)
