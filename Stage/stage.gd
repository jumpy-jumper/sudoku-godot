#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Model

func _ready():
	connect("cell_state_changed", self, "_on_cell_state_changed")
	initialize_grid_caches()
	connect_with_cells()
	load_sudoku(Game.sudoku_to_load)

func _process(dt):
	update_selection()

# Prevents some properties from being tracked
func initialize_tracked():
	.initialize_tracked()
	tracked.remove("cells")

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

func _on_Cell_hovered(cell):
	hovered_cell = cell
	selection_controller.reset_timers()

func _on_Cell_dehovered(cell):
	if hovered_cell == cell:
		hovered_cell = null
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
	if not selection.empty() and hovered_cell:
		if initial_cell in selection:
			for c in cell_to_box[initial_cell]:
				if not c in selection:
					selection.append(c)
		else:
			for c in cell_to_box[initial_cell]:
				if c in selection:
					selection.erase(c)

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
		(not Settings.settings["autofill"] or not c.trivial_impossibles[num-1]):
			var marks = c.marked_secondary if marks_are_secondary else c.marked
			marks[num-1] = not is_on_all
	emit_signal("cell_state_changed")

func _on_CellWriteController_clear():
	if not selection.empty():
		clear_marks(selection + [])
	elif hovered_cell:
		clear_number([hovered_cell] if not wheel_cell else [wheel_cell])

func clear_marks(cells):
	for c in cells:
		if not c.locked:
			if c.number > 0:
				c.number = 0
			else:
				for i in range(9):
					c.marked[i] = false
					c.marked_secondary[i] = false
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

func _on_cell_state_changed():
	process_new_cell_state()
	append_state(get_cell_state())

func process_new_cell_state():
	if Settings.settings["autofill"]:
		set_trivial_impossibles()
	if Settings.settings["highlight_hidden_singles"]:
		highlight_hidden_singles()

func get_cell_state():
	var ret = ""
	for c in cells:
		ret += str(c.number)
	for c in cells:
		for i in range(9):
			ret += str(int(c.marked[i]))
	for c in cells:
		for i in range(9):
			ret += str(int(c.marked_secondary[i]))
	return ret

func load_cell_state(state):
	var i = 0
	for c in cells:
		c.number = int(state[i])
		i += 1
	for c in cells:
		for j in range(9):
			c.marked[j] = bool(int(state[i]))
			i += 1
	for c in cells:
		for j in range(9):
			c.marked_secondary[j] = bool(int(state[i]))
			i += 1
	#print(str(cur_state_index+1) + "/" + str(len(states)))
	process_new_cell_state()

var states = []
var cur_state_index = -1

func append_state(state):
	if len(states) > 0:
		var last_state = states[len(states)-1]
		if last_state == state:
			return
	if len(states) > 1:
		var second_to_last_state = states[len(states)-2]
		if second_to_last_state == state:
			states.pop_back()
			cur_state_index -= 1
			#print(str(cur_state_index+1) + "/" + str(len(states)))
			return
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

func _on_StateController_redo():
	redo()

func redo():
	if cur_state_index + 1 < len(states):
		cur_state_index += 1
		load_cell_state(states[cur_state_index])


#  -------------------------
# |  SUDOKU	                |
#  -------------------------

#  -------------------------
# |  BOARD	                |
#  -------------------------

func load_sudoku(sudoku):
	if sudoku.has("numbers"):
		for i in range(81):
			var num = int(sudoku["numbers"][i])
			cells[i].number = num
			cells[i].locked = num > 0
	if sudoku.has("solution"):
		for i in range(81):
			cells[i].solution = int(sudoku.solution[i])
	if Settings.settings["autofill"]:
		for c in cells:
			for i in range(9):
				c.marked[i] = true
	emit_signal("cell_state_changed")

#  -------------------------
# |  ASSIST                 |
#  -------------------------

func set_trivial_impossibles():
	for c in cells:
		if not c.locked:
			for i in range(9):
				c.trivial_impossibles[i] = false
	for c in cells:
		if c.number > 0:
			for c2 in cell_to_box[c] + cell_to_column[c] + cell_to_row[c]:
				c2.trivial_impossibles[c.number-1] = true

func highlight_hidden_singles():
	for c in cells:
		c.hidden_single = 0
	for region in (rows + columns + boxes):
		var found = [0, 0, 0, 0, 0, 0, 0, 0, 0]
		for c in region:
			if not c.locked and c.number == 0:
				for i in range (9):
					if c.marked[i] and not c.trivial_impossibles[i]:
						found[i] += 1
		for c in region:
			if not c.locked and c.number == 0:
				for i in range (9):
					if c.marked[i] and not c.trivial_impossibles[i] and found[i] == 1:
						c.hidden_single = i+1
