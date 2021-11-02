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
			levels[3*i+3], 0)

func load_savedata():
	var save_file = File.new()
	if save_file.file_exists("user://savedata.json"):
		save_file.open("user://savedata.json", File.READ)
		var savedata = parse_json(save_file.get_as_text())
		if savedata:
			var regex = RegEx.new()
			regex.compile("{.*}")
			for level in $"Levels".get_children():
				var sudoku = regex.sub(level.sudoku, "")
				if savedata.has(sudoku):
					var marks = 0
					var stop_counting = false
					for c in sudoku:
						if not stop_counting and c == "0":
							marks += 1
						elif c == "[":
							stop_counting = true
						elif c == "]":
							stop_counting = false
					var empty_marks = savedata[sudoku].substr(0, marks).count("0")
					var proportion = ((float(marks - empty_marks) / marks))
					
					var progress = level.Progress.NOT_ATTEMPTED
					if "無" in savedata[sudoku]:
						progress = level.Progress.FAILED
					elif proportion == 1:
						progress = level.Progress.SOLVED
					elif proportion > 0:
						progress = level.Progress.IN_PROGRESS
					
					level.update_level_info(level.number, level.difficulty, \
						level.description, level.sudoku, progress)
