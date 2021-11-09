#  -------------------------
# |  MAIN                   |
#  -------------------------

extends View

func _ready():
	Settings.connect("settings_changed", self, "_on_Settings_settings_changed")
	_on_Settings_settings_changed()
	
func _process(dt):
	update_secondary_marks()

var flipped_marks = false
func _on_Settings_settings_changed():
	if Settings.settings["reverse_numpad"] != flipped_marks:
		flipped_marks = Settings.settings["reverse_numpad"]
		var top_main = [marks_children[0], marks_children[1], marks_children[2]]
		var bot_main = [marks_children[6], marks_children[7], marks_children[8]]
		var top_secondary = [secondary_marks_children[0], secondary_marks_children[1], secondary_marks_children[2]]
		var bot_secondary = [secondary_marks_children[6], secondary_marks_children[7], secondary_marks_children[8]]

		for i in range(3):
			top_main[i].valign = VALIGN_BOTTOM if not flipped_marks else VALIGN_TOP
			top_secondary[i].valign = VALIGN_BOTTOM if not flipped_marks else VALIGN_TOP
			bot_main[i].valign = VALIGN_BOTTOM if flipped_marks else VALIGN_TOP
			bot_secondary[i].valign = VALIGN_BOTTOM if flipped_marks else VALIGN_TOP
	$Square.modulate.a = Settings.settings["cell_alpha"]
	update_primary_marks()

#  -------------------------
# |  WATCHERS               |
#  -------------------------

onready var marks = $Marks/Fixed
onready var marks_children = marks.get_children()
func _on_Stage_cell_state_changed():
	if model.number == 0:
		update_primary_marks()

func _on_Model_hidden_single_changed(value):
	for i in range(9):
		marks_children[i].modulate = Settings.settings["stage_singles_color"] \
			if i == (value-1) else Settings.settings["stage_default_color"]

func update_primary_marks():
	for i in range(9):
		marks_children[i].visible = model.is_marked(i+1)
	
	var count = 0
	for i in range(1, 10):
		if model.is_marked(i):
			count += 1

	marks.modulate = Settings.settings["stage_default_color"]

	if model.solution > 0 and \
		Settings.settings["warn_solution_not_in_candidates"] \
		and not model.is_marked(model.solution):
				marks.modulate = Settings.settings["stage_error_color"]
	
	elif model.hidden_single == 0 and count > 0:
		if count == 1 and Settings.settings["highlight_naked_singles"]:
			marks.modulate = Settings.settings["stage_singles_color"]
		elif count == 2 and Settings.settings["highlight_bivalue_cells"]:
			marks.modulate = Settings.settings["stage_pairs_color"]
		else:
			marks.modulate.a = Settings.settings["candidates_" + str(count) + "_alpha"]

onready var secondary_marks = $Marks/Dots
onready var secondary_marks_children = secondary_marks.get_children()
func update_secondary_marks():
	if model.number == 0:
		for i in range(9):
			secondary_marks_children[i].modulate.a = 1 if model.marked_secondary[i] else \
				(0.25 if model.secondary_marks_highlighted and model in model.stage.selection else 0)

onready var number = $Number
onready var blur = $Blur
func _on_Model_number_changed(value):
	number.text = str(value) if value > 0 else ""
	marks.visible = not model.number > 0
	secondary_marks.visible = not model.number > 0
	if number.modulate != Settings.settings["stage_won_color"]:
		number.modulate = Settings.settings["stage_givens_color"] if model.locked else \
			Settings.settings["stage_error_color"] if \
				Settings.settings["warn_incorrect_number"] and (value != model.solution and model.solution > 0) else \
				Settings.settings["stage_default_color"]
	blur.visible = not model.locked and ((value != model.solution and model.solution > 0) \
		or (model.solution == 0 and value == 0) \
		or (model.number > 0 and not Settings.settings["warn_incorrect_number"]))

#  -------------------------
# |  COLORS                 |
#  -------------------------

onready var square = $Square
onready var colors = $Colors
const COLOR_SLANT = 25
var color_template = preload("res://Cell/cell_color.tscn")
func _on_Model_colors_changed(value):
	update_colors()

func _on_Model_notes_changed(value):
	update_colors()

func update_colors():
	for c in colors.get_children():
		c.free()
	var all_colors = model.colors + []
	for n in model.notes:
		all_colors.append(n.color)
	for i in range (len(all_colors)):
		var new_color = color_template.instance()
		colors.add_child(new_color)
		new_color.radial_initial_angle = 360/len(all_colors) * (i) + COLOR_SLANT
		new_color.radial_fill_degrees = 360/len(all_colors)
		new_color.tint_progress = Color(all_colors[i])
		new_color.modulate.a = 1

onready var highlight_border = $HighlightBorder
func _on_Model_highlighted_note_changed(value):
	var idx = model.notes.find(value) + len(model.colors)
	if idx >= len(model.colors):
		for i in range(colors.get_child_count()):
			var ani_player = colors.get_child(i).get_node("AnimationPlayer")
			ani_player.play("default")
			if i == idx:
				ani_player.play("highlighted")
	else:
		for i in range(colors.get_child_count()):
			colors.get_child(i).get_node("AnimationPlayer").play("default")
	if value:
		highlight_border.visible = model in model.stage.get_cells_from_index_array(value.cells)
		if highlight_border.visible:
			highlight_border.modulate = value.color
	else:
		highlight_border.visible = false
