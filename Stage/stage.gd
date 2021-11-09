#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Model

func _ready():
	connect("cell_state_changed", self, "_on_cell_state_changed")
	initialize_grid_caches()
	connect_with_cells()
	Settings.connect("settings_changed", self, "_on_Settings_settings_changed")
	_on_Settings_settings_changed()
	load_sudoku(Game.sudoku_to_load)

func _process(dt):
	update_highlighted_note()
	update_selection()
	update_time(dt)

# Prevents some properties from being tracked
func initialize_tracked():
	.initialize_tracked()
	tracked.remove("cells")

func _on_Settings_settings_changed():
	no_gaps = Settings.settings["no_gaps"]

#  -------------------------
# |  GRID HELPERS           |
#  -------------------------

onready var cells = $Grid.get_children()
var rows = [[],[],[],[],[],[],[],[],[]]
var columns = [[],[],[],[],[],[],[],[],[]]
var boxes = [[],[],[],[],[],[],[],[],[]]
var cell_to_row = {}
var cell_to_column = {}
var cell_to_box = {}

func initialize_grid_caches():
	for i in range(81):
		rows[i/9].append(cells[i])
		cell_to_row[cells[i]] = rows[i/9]
		columns[i%9].append(cells[i])
		cell_to_column[cells[i]] = columns[i%9]
		var box = (i/27*3)+(i%9)/3
		boxes[box].append(cells[i])
		cell_to_box[cells[i]] = boxes[box]

func get_cell_position_in_grid(cell):
	var idx = cells.find(cell)
	return Vector2(idx%9, idx/9)

func get_cells_inside(x1, x2, y1, y2, zero_ordering = false):
	if not zero_ordering:
		x1 -= 1
		x2 -= 1
		y1 -= 1
		y2 -= 1
	var ret = []
	for i in range(81):
		if i/9 >= y1 and i/9 <= y2 and i%9 >= x1 and i%9 <= x2:
			ret.append(cells[i])
	return ret

func get_cells_from_index_array(array):
	var ret = []
	for i in array:
		ret.append(cells[i])
	return ret

func get_cell_size():
	return cells[0].get_node("View/Square").texture.get_size()

func is_mouse_inside_grid():
	var pos = get_global_mouse_position()
	return pos.x > cells[0].global_position.x \
		and pos.x < cells[80].global_position.x \
		and pos.y > cells[0].global_position.y \
		and pos.y < cells[80].global_position.y 

#  -------------------------
# |  CELLS                  |
#  -------------------------

func connect_with_cells():
	for c in cells:
		c.connect("hovered", self, "_on_Cell_hovered", [c])
		c.connect("dehovered", self, "_on_Cell_dehovered", [c])

#  -------------------------
# |  CELL HOVERING          |
#  -------------------------

var hovered_cell = null
var hovered_note = null

func _on_Cell_hovered(cell):
	hovered_cell = cell
	selection_controller.reset_timers()

func update_highlighted_note():
	if hovered_cell:
		if hovered_note:
			hovered_note.highlighted = false
		hovered_note = hovered_cell.get_hovered_note()
		if hovered_note:
			hovered_note.highlighted = true
		notes.highlight_note(hovered_note)

func _on_Cell_dehovered(cell):
	if hovered_cell == cell:
		hovered_cell = null
		notes.highlight_note(null)
		if hovered_note:
			hovered_note.highlighted = false
		hovered_note = null
	selection_controller.reset_timers()

#  -------------------------
# |  SELECTION              |
#  -------------------------

onready var selection_controller = $Controllers/SelectionController
var selecting = false
var selection = []
var initial_cell = null
var initial_selection = []
var keep_selection = false

var selected_color = Color.lightpink

func get_selection_as_index_array():
	var ret = []
	for i in range (81):
		if cells[i] in selection:
			ret.append(i)
	return ret

func _on_SelectionController_start_selection():
	if hovered_cell:
		selecting = true
		if not (keep_selection or Settings.settings["keep_selection"]):
			selection.clear()
		initial_cell = hovered_cell
		if initial_cell in selection:
			selection.erase(initial_cell)
		else:
			selection.append(initial_cell)
		initial_selection = selection + []
	elif not is_mouse_inside_grid():
		selection.clear()

func _on_SelectionController_expand_selection():
	if hovered_cell:
		var cells_to_select = []
		
		var is_number_done = true
		if hovered_cell.number > 0:
			for c in cells:
				if c.is_marked(hovered_cell.number):
					is_number_done = false
					break
		
		var pos = get_cell_position_in_grid(hovered_cell)
		var is_outer = pos.x == 0 or pos.x == 8 or pos.y == 0 or pos.y == 8
		
		var mouse_pos_in_cell = get_global_mouse_position() - (hovered_cell.global_position + get_cell_size()/2)
		var theta = fmod(atan2(mouse_pos_in_cell.y, mouse_pos_in_cell.x) + 2*PI, 2*PI)
		var select_row = (theta > 3*PI/4 and theta < 5*PI/4) or \
			(((theta + PI) > 3*PI/4 and (theta + PI) < 5*PI/4))
		
		if hovered_note:
			var note_cells = get_cells_from_index_array(hovered_note.cells)
			if not note_cells.empty():
				selection = note_cells
		elif not hovered_cell.colors.empty():
			for c in cells:
				if hovered_cell.colors[0] in c.colors:
					cells_to_select.append(c)
		elif is_outer:
			if select_row:
				for c in cell_to_row[hovered_cell]:
					if not c in cells_to_select:
						cells_to_select.append(c)
			else:
				for c in cell_to_column[hovered_cell]:
					if not c in cells_to_select:
						cells_to_select.append(c)
		elif not is_number_done:
			for c in cells:
				if c.is_marked(hovered_cell.number):
					cells_to_select.append(c)
		else:
			for c in cell_to_box[hovered_cell]:
					cells_to_select.append(c)
		
		if hovered_cell in selection:
			for c in cells_to_select:
				if not c in selection:
					selection.append(c)
		else:
			for c in cells_to_select:
				if c in selection:
					selection.erase(c)
			

func _on_SelectionController_select_all():
	if len(selection) == len(cells):
		selection.clear()
	else:
		selection = cells + []

func _on_SelectionController_end_selection():
	selecting = false

func _on_SelectionController_keep_selection():
	keep_selection = true

func _on_SelectionController_stop_keep_selection():
	keep_selection = false

func update_selection():
	if selecting:
		if Settings.settings["box_selection"]:
			recalculate_selection_box()
		else:
			recalculate_selection_single()

func recalculate_selection_single():
	if hovered_cell:
		if initial_cell in selection:
			if not hovered_cell in selection:
				selection.append(hovered_cell)
		else:
			if hovered_cell in selection:
				selection.erase(hovered_cell)

func recalculate_selection_box():
	if hovered_cell:
		selection = initial_selection + []
		var initial = get_cell_position_in_grid(initial_cell)
		var final = get_cell_position_in_grid(hovered_cell)
		var x1 = min(initial.x, final.x)
		var x2 = max(initial.x, final.x)
		var y1 = min(initial.y, final.y)
		var y2 = max(initial.y, final.y)
		if initial_cell in selection:
			for c in get_cells_inside(x1, x2, y1, y2, true):
				if not c in selection:
					selection.append(c)
		else:
			for c in get_cells_inside(x1, x2, y1, y2, true):
				if c in selection:
					selection.erase(c)

#  -------------------------
# |  CELL NUMBER / MARKS    |
#  -------------------------

signal cell_state_changed()

var wheel_cell = null

func _on_CellWriteController_number_wheel_spawned():
	wheel_cell = hovered_cell

func _on_CellWriteController_number_wheel_exited():
	wheel_cell = null

var marks_are_secondary = false

func _on_CellWriteController_toggle_secondary_marks(active):
	marks_are_secondary = active
	for c in cells:
		if not c.locked:
			c.secondary_marks_highlighted = active

func _on_CellWriteController_write_number(num):
	if not selection.empty():
		write_mark(selection + [], num)
	elif hovered_cell or wheel_cell:
		write_number([hovered_cell] if not wheel_cell else [wheel_cell], num)

func write_number(cells, num):
	for c in cells:
		if not c.locked:
			c.number = num if (c.number != num) else 0
	emit_signal("cell_state_changed")

func write_mark(cells, num):
	var is_on_all = true
	for c in cells:
		if not c.locked and c.number == 0:
			var marks = c.marked_secondary if marks_are_secondary else c.marked
			if not marks[num-1]:
				is_on_all = false
				break
	for c in cells:
		if not c.locked and c.number == 0 and \
		(not Settings.settings["autofill"] or not c.trivial_impossibles[num-1] or marks_are_secondary):
			var marks = c.marked_secondary if marks_are_secondary else c.marked
			marks[num-1] = not is_on_all
	emit_signal("cell_state_changed")

func _on_CellWriteController_clear():
	if not selection.empty():
		clear_marks(selection + [])
	elif hovered_cell:
		clear_number([hovered_cell] if not wheel_cell else [wheel_cell])

func clear_marks(cells):
	var all_are_full = true
	for c in cells:
		if not c.locked:
			c.number = 0
			if false in c.marked:
				all_are_full = false
			for i in range(9):
				c.marked_secondary[i] = false
	for c in cells:
		if not c.locked:
			for i in range(9):
				c.marked[i] = Settings.settings["autofill"]
	emit_signal("cell_state_changed")

func clear_number(cells):
	for c in cells:
		if not c.locked:
			if c.number == 0:
				for i in range (9):
					c.marked[i] = false
					c.marked_secondary[i] = false
			c.number = 0
	emit_signal("cell_state_changed")

#  -------------------------
# |  STATE                  |
#  -------------------------

var win_condition_met = false
var won = false

func _on_cell_state_changed(append_new=true):
	process_new_cell_state()
	check_win()
	for c in cells:
		c.emit_signal("stage_cell_state_changed")
	if append_new:
		append_state(get_cell_state())
	if Settings.settings["autosave"]:
		save_to_savedata()

func get_number_marks_string():
	var ret = ""
	for c in cells:
		ret += str(c.number)
	return ret

func get_primary_marks_string():
	var ret = ""
	for c in cells:
		for i in range(9):
			ret += str(int(c.marked[i]))
	return ret

func get_secondary_marks_string():
	var ret = ""
	for c in cells:
		for i in range(9):
			ret += str(int(c.marked_secondary[i]))
	return ret

func get_colors_string():
	var ret = {}
	for i in range(81):
		if not cells[i].colors.empty():
			var colors = []
			for c in cells[i].colors:
				colors.append(c)
			ret[i] = to_json(colors)
	return to_json(ret)

func get_cell_state():
	var ret = {
		"numbers" : get_number_marks_string(),
		"marks" : get_primary_marks_string(),
		"secondary_marks" : get_secondary_marks_string(),
		"colors" : get_colors_string(),
		"notes" : notes.get_notes_as_json(),
	}
	return to_json(ret)

func load_cell_state(state):
	state = parse_json(state)
	for i in range(81*9):
		if state.has("numbers"):
			cells[i/9].number = int(state["numbers"][i/9])
		if state.has("marks"):
			cells[i/9].marked[i%9] = bool(int(state["marks"][i]))
		if state.has("secondary_marks"):
			cells[i/9].marked_secondary[i%9] = bool(int(state["secondary_marks"][i]))
		if i%9 == 0:
			if state.has("colors"):
				cells[i/9].colors.clear()
				var colors = parse_json(state["colors"])
				if colors.has(str(i/9)):
					for cl in parse_json(colors[str(i/9)]):
						cells[i/9].colors.append(cl)
			if state.has("notes"):
				cells[i/9].notes.clear()
				cells[i/9].highlighted_note = null
	if state.has("notes"):
		notes.load_notes_from_json(state["notes"])
		notes.update_cell_note_references()
		$Controllers/NotesController.clear_entered_notes()
		hovered_note = null
	_on_cell_state_changed(false)

func check_win():
	if "0" in solution:
		win_condition_met = not "0" in get_number_marks_string()
	else:
		win_condition_met = get_number_marks_string() == solution
	if not won and win_condition_met:
		won = win_condition_met
		timer_locks.append("won")

func process_new_cell_state():
	if Settings.settings["autofill"]:
		set_trivial_impossibles()
	if Settings.settings["highlight_hidden_singles"]:
		highlight_hidden_singles()

var states = []
var cur_state_index = -1

func append_state(state):
	if len(states) > 0 and cur_state_index == len(states) - 1:
		var last_state = states[cur_state_index-1]
		if last_state == state:
			states.pop_back()
			cur_state_index -= 1
			#print(str(cur_state_index+1) + "/" + str(len(states)))
			return
	#if len(states) > 1:
	#	var second_to_last_state = states[len(states)-2]
	#	if second_to_last_state == state:
	#		states.pop_back()
	#		cur_state_index -= 2
	#		print(str(cur_state_index+1) + "/" + str(len(states)))
	#		return
	while cur_state_index + 1 < len(states):
		states.pop_back()
	states.append(state)
	cur_state_index += 1
	#print(str(cur_state_index+1) + "/" + str(len(states)))

func _on_StateController_undo():
	undo()

func undo():
	if cur_state_index > 0:
		cur_state_index -= 1
		load_cell_state(states[cur_state_index])
	#print(str(cur_state_index+1) + "/" + str(len(states)))

func _on_StateController_redo():
	redo()

func redo():
	if cur_state_index + 1 < len(states):
		cur_state_index += 1
		load_cell_state(states[cur_state_index])
	#print(str(cur_state_index+1) + "/" + str(len(states)))

#  -------------------------
# |  SUDOKU	                |
#  -------------------------

var level_name = ""
var solution = "000000000000000000000000000000000000000000000000000000000000000000000000000000000"

func clear_sudoku():
	selection.clear()
	states.clear()
	cur_state_index = -1
	timer_locks.clear()
	time = 0
	won = false
	if note_editing:
		$Controllers/EditNoteController.confirm_note()
	$Controllers/NotesController.entered_notes.clear()
	for c in controllers:
		c.release_all_locks()
	$Controllers/EditNoteController.add_lock("no_note")
	for n in notes.get_children():
		n.queue_free()
	for c in cells:
		c.locked = false
		c.number = 0
		c.solution = 0
		for i in range(9):
			c.marked[i] = false
			c.marked_secondary[i] = false
		c.colors.clear()

func load_sudoku(sudoku):
	clear_sudoku()
	if sudoku.has("name"):
		level_name = sudoku["name"]
	if sudoku.has("numbers"):
		for i in range(81):
			var num = int(sudoku["numbers"][i])
			cells[i].number = num
			cells[i].locked = num > 0
	if sudoku.has("solution"):
		for i in range(81):
			cells[i].solution = int(sudoku["solution"][i])
		solution = sudoku["solution"]
	if sudoku.has("no_gaps"):
		no_gaps = sudoku["no_gaps"]
	else:
		no_gaps = false
	if sudoku.has("uses_boxes"):
		uses_boxes = sudoku["uses_boxes"]
	else:
		uses_boxes = true
	if Settings.settings["autofill"]:
		for c in cells:
			for i in range(9):
				c.marked[i] = true
	load_from_savedata()
	emit_signal("cell_state_changed")

#  -------------------------
# |  BOARD	                |
#  -------------------------

var no_gaps = false

const BOX_GAP = 8

#  -------------------------
# |  ASSIST                 |
#  -------------------------

var uses_boxes = true

func set_trivial_impossibles():
	for c in cells:
		if not c.locked:
			for i in range(9):
				c.trivial_impossibles[i] = false
	for c in cells:
		if c.number > 0:
			for c2 in (cell_to_box[c] if uses_boxes else []) + cell_to_column[c] + cell_to_row[c]:
				c2.trivial_impossibles[c.number-1] = true

func highlight_hidden_singles():
	for c in cells:
		c.hidden_single = 0
	for region in (rows + columns + (boxes if uses_boxes else [])):
		var found = [0, 0, 0, 0, 0, 0, 0, 0, 0]
		for c in region:
			if not c.locked and c.number == 0:
				for i in range (9):
					if c.is_marked(i+1):
						found[i] += 1
		for c in region:
			if not c.locked and c.number == 0:
				for i in range (9):
					if c.is_marked(i+1) and found[i] == 1:
						c.hidden_single = i+1

func fill_singles():
	var found_naked = Settings.settings["fill_naked_singles"] and fill_naked_singles()
	var found_hidden = Settings.settings["fill_hidden_singles"] and fill_hidden_singles()
	if found_naked or found_hidden:
		emit_signal("cell_state_changed")

func fill_naked_singles():
	var found = false
	for c in cells:
		if c.number == 0:
			var count = 0
			var last = 0
			for i in range(9):
				if c.is_marked(i+1):
					count += 1
					last = i+1
					if count > 1:
						break
			if count == 1:
				c.number = last
				found = true
	return found

func fill_hidden_singles():
	var found = false
	for c in cells:
		if c.hidden_single > 0:
			c.number = c.hidden_single
			found = true
	return found

#  -------------------------
# |  TIME TRACKING          |
#  -------------------------

var time = 0
var timer_locks = []

func update_time(dt):
	if timer_locks.empty():
		time += dt

func _on_TimerController_pause():
	if "user" in timer_locks:
		timer_locks.erase("user")
	else:
		timer_locks.append("user")

#  -------------------------
# |  NOTES                  |
#  -------------------------

onready var notes = $Notes
var note_editing = null

#  -------------------------
# |  SAVEDATA               |
#  -------------------------

func get_level_id():
	return level_name.md5_text()

func get_savedata_string():
	var ret = {
		"cell_state" : get_cell_state(),
		"won" : won,
		"time" : time,
	}
	return to_json(ret)
	
func save_to_savedata():
	var level_savedata = get_savedata_string()
	
	var save_file = File.new()
	var savedata = {}
	if save_file.file_exists(Game.get_save_path()):
		save_file.open(Game.get_save_path(), File.READ)
		savedata = parse_json(save_file.get_as_text())
		if not savedata:
			savedata = {}
		save_file.close()
	
	save_file.open(Game.get_save_path(), File.WRITE)
	savedata[get_level_id()] = level_savedata
	save_file.store_line(to_json(savedata))
	save_file.close()

func load_savedata_string(string):	
	var savedata = parse_json(string)
	if savedata.has("cell_state"):
		load_cell_state(savedata["cell_state"])
	if savedata.has("won"):
		won = savedata["won"]
		if won:
			timer_locks.append("won")
	if savedata.has("time"):
		time = savedata["time"]

func load_from_savedata():
	var savedata = Game.get_savedata()
	
	if not savedata or not savedata.has(get_level_id()):
		return
	
	load_savedata_string(savedata[get_level_id()])

#  -------------------------
# |  SETTING                |
#  -------------------------

func get_sudoku():
	var sudoku = {
		"name" : level_name,
		"numbers" : "",
		"solution" : solution,
	}
	for c in cells:
		sudoku["numbers"] += str(c.number) if c.locked else "0"
	return sudoku
