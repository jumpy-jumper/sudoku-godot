#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Model

onready var stage = get_parent().get_parent()

signal stage_cell_state_changed()

#  -------------------------
# |  NUMBER                 |
#  -------------------------

var locked = false
export var number = 0
var solution = 0

#  -------------------------
# |  PENCIL MARKS           |
#  -------------------------

var marked = [false, false, false, false, false, false, false, false, false]
var marked_secondary = [false, false, false, false, false, false, false, false, false]
var secondary_marks_highlighted = false
var hidden_single = 0

var trivial_impossibles = [false, false, false, false, false, false, false, false, false]

func is_marked(n):
	return number == 0 and marked[n-1] and not trivial_impossibles[n-1]

#  -------------------------
# |  COLORS                 |
#  -------------------------

signal color_hovered()

var colors = []

func add_color(color):
	color = Color(color).to_html()
	if not color in colors:
		colors.append(color)
		colors.sort()

func remove_color(color):
	color = Color(color).to_html()
	if color in colors:
		colors.erase(color)

func remove_color_completely(color):
	color = Color(color).to_html()
	while color in colors:
		colors.erase(color)

func toggle_color(color):
	color = Color(color).to_html()
	if color in colors:
		colors.erase(color)
	else:
		colors.append(color)
		colors.sort()

#  -------------------------
# |  NOTES                  |
#  -------------------------

signal note_color_hovered()

var notes = []
var highlighted_note = null

const COLOR_SLANT = 25
func get_hovered_note():
	if notes.empty():
		return null
	var mouse_pos_in_cell = get_global_mouse_position() - (global_position + stage.get_cell_size()/2)
	var theta = fmod(atan2(mouse_pos_in_cell.y, mouse_pos_in_cell.x) + 2*PI + deg2rad(COLOR_SLANT*2), 2*PI)
	var color_count = len(colors)+len(notes)
	var mouse_idx = floor(theta / (2*PI) * color_count)
	
	if mouse_idx >= len(colors):
		var note = notes[mouse_idx-len(colors)]
		return null if note.hidden or note.unhoverable else note
	return null

#  -------------------------
# |  SELECTION              |
#  -------------------------

signal hovered()
signal dehovered()

func _on_Controller_hovered():
	emit_signal("hovered")

func _on_Controller_dehovered():
	emit_signal("dehovered")
