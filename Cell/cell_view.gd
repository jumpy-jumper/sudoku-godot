#  -------------------------
# |  MAIN                   |
#  -------------------------

extends View

#  -------------------------
# |  WATCHERS               |
#  -------------------------

onready var marks = $Marks/Fixed
onready var marks_children = marks.get_children()
func _on_Model_marked_changed(value):
	update_primary_marks()

func _on_Model_trivial_impossibles_changed(value):
	update_primary_marks()

func update_primary_marks():
	for i in range(9):
		marks_children[i].visible = model.marked[i] and not model.trivial_impossibles[i]
	
	var count = 0
	for i in range(9):
		if model.marked[i] and not model.trivial_impossibles[i]:
			count += 1
			if count > 2:
				break
	if model.hidden_single == 0:
		if count == 1 and Settings.settings["highlight_naked_singles"]:
			marks.modulate = Settings.settings["stage_singles_color"]
		elif count == 2 and Settings.settings["highlight_bivalue_cells"]:
			marks.modulate = Settings.settings["stage_pairs_color"]
		else:
			marks.modulate = Settings.settings["stage_default_color"]
	
	if model.solution > 0 and \
		Settings.settings["warn_solution_not_in_candidates"] \
		and (model.marked[model.solution-1] == false \
			or model.trivial_impossibles[model.solution-1] == true):
				marks.modulate = Settings.settings["stage_error_color"]

func _on_Model_hidden_single_changed(value):
	if value > 0:
		marks.modulate = Settings.settings["stage_default_color"]
	for i in range (9):
		marks_children[i].modulate = Settings.settings["stage_singles_color"] \
			if i == value-1 else Settings.settings["stage_default_color"]

onready var secondary_marks = $Marks/Dots
onready var secondary_marks_children = secondary_marks.get_children()
func _on_Model_marked_secondary_changed(value):
	for i in range(9):
		secondary_marks_children[i].visible = value[i]

onready var number = $Number
func _on_Model_number_changed(value):
	number.text = str(value) if value > 0 else ""
	marks.visible = not model.number > 0
	secondary_marks.visible = not model.number > 0
	number.modulate = Settings.settings["stage_givens_color"] if model.locked else \
		Settings.settings["stage_default_color"]
