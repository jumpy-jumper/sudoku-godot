#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Node2D

onready var stage = $".."

var note_template = preload("res://Stage/Notes/note.tscn")
func get_new_note():
	var new_note = note_template.instance()
	add_child(new_note)
	return new_note

func spawn_note():
	var note = get_new_note()
	note.global_position = get_global_mouse_position().snapped(\
		Settings.settings["notes_grid_snap"]) + Settings.settings["notes_grid_offset"]
	note.color = Color(stage.selected_color)
	note.cells = stage.get_selection_as_index_array()
	note.connect_to_controller(stage.get_node("Controllers/NotesController"))
	for c in stage.selection:
		c.remove_color(note.color)
	stage.selection.clear()
	update_cell_note_references()
	stage.emit_signal("cell_state_changed")
	return note

func update_cell_note_references():
	for c in stage.cells:
		c.notes.clear()
	for n in get_children():
		if not n.hidden and not n.is_queued_for_deletion():
			for c in stage.get_cells_from_index_array(n.cells):
				c.notes.append(n)
	if stage.note_editing:
		for cell in stage.get_cells_from_index_array(stage.note_editing.cells):
			cell.get_node("View").update_colors()

func get_notes_as_json():
	var json = []
	for n in get_children():
		json.append(n.get_json())
	return to_json(json)

onready var notes_controller = $"../Controllers/NotesController"
func load_notes_from_json(json):
	json = parse_json(json)
	for n in get_children():
		n.free()
	for n in json:
		var new_note = get_new_note()
		new_note.load_json(n)
		new_note.connect_to_controller(notes_controller)

onready var note_text = stage.get_node("View/UI/NoteText")
func highlight_note(note):
	for c in stage.cells:
		c.highlighted_note = note
	if not stage.note_editing:
		if note:
			note_text.text = note.text
			var c = note.color
			note_text.modulate = Color(c.r * 0.5 + 0.5, c.g * 0.5 + 0.5, c.b * 0.5 + 0.5, 1)
		else:
			note_text.text = ""
