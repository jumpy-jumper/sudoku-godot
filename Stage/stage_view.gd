#  -------------------------
# |  MAIN                   |
#  -------------------------

extends View

#  -------------------------
# |  WATCHERS               |
#  -------------------------

onready var hover_border = $HoverBorder

func _on_Model_hovered_cell_changed(value):
	hover_border.position = value.global_position if value else Vector2(-128, -128)
	update_highlighted_colors()

onready var custom_sudoku_bg = $BgLayer/CustomSudokuBG
func _on_Model_no_gaps_changed(value):
	for i in range(9):
		var diff = i / 3 - 1
		for c in model.rows[i]:
			c.position.y += model.BOX_GAP * diff * -int(value)
		for c in model.columns[i]:
			c.position.x += model.BOX_GAP * diff * -int(value)
	custom_sudoku_bg.rect_position.x += model.BOX_GAP * int(value) / 2
	custom_sudoku_bg.rect_position.y += model.BOX_GAP * int(value) / 2
	custom_sudoku_bg.rect_size.y += model.BOX_GAP * 2 * -int(value)
	custom_sudoku_bg.rect_size.x += model.BOX_GAP * 2 * -int(value)

onready var all_text = [$UI/LevelName, $UI/Time, $UI/Clock, $UI/Clock/Paused]
func _on_Model_won_changed(value):
	for t in all_text:
		t.self_modulate = Settings.settings["stage_won_color"] if value \
			else Settings.settings["stage_default_color"]

onready var time = $UI/Time
func _on_Model_time_changed(value):
	value = int(value)
	var seconds = value % 60
	var minutes = (value / 60) % 60
	var hours = value / 3600
	time.text = str(hours) + ":" + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)

onready var clock = $UI/Clock
onready var pause = $UI/Clock/Paused
func _on_Model_timer_locks_changed(value):
	clock.self_modulate.a = 0 if "user" in value else 1
	pause.visible = "user" in value

onready var level_name = $UI/LevelName
func _on_Model_level_name_changed(value):
	level_name.text = value

#  -------------------------
# |  GRID                   |
#  -------------------------

func _on_Model_win_condition_met_changed(value):
	for c in model.cells:
		var t = c.get_node("View/Number")
		t.modulate = Settings.settings["stage_won_color"] if value \
			else Settings.settings["stage_default_color"]

func _on_Model_selection_changed(value):
	for c in model.cells:
		c.get_node("View/Selected").visible = c in value
		c.get_node("View/Selected").modulate = model.selected_color
	update_highlighted_colors()
	if model.note_editing:
		model.notes.update_cell_note_references()

func _on_BGScaleSlider_value_changed(value):
	custom_sudoku_bg.rect_scale.x = value*0.01
	custom_sudoku_bg.rect_scale.y = value*0.01


#  -------------------------
# |  COLOR PICKER           |
#  -------------------------

onready var color_picker = $UI/ColorPicker
onready var color_buttons = color_picker.get_children()

func _on_Model_selected_color_changed(value):
	for c in model.cells:
		c.get_node("View/Selected").modulate = value
	if model.note_editing:
		model.notes.update_cell_note_references()

func update_highlighted_colors():
	var colors = []
	if not model.selection.empty():
		for c in model.selection:
			for cl in c.colors:
				if not cl in colors:
					colors.append(cl)
	elif model.hovered_cell:
		for cl in model.hovered_cell.colors:
			if not cl in colors:
				colors.append(cl)
	for c in color_buttons:
		var foo = c.modulate
		foo.a = 1
		if foo.to_html() in colors:
			c.modulate.a = 3
		else:
			c.modulate.a = float(157)/255
