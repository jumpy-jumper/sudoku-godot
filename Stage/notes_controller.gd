#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Controller

#  -------------------------
# |  CHECKS               |
#  -------------------------

func initialize_checks():
	checks[Controller.Device.MOUSE].append("check_new_note")
	checks[Controller.Device.MOUSE].append("check_edit_note")

onready var notes = $"../../Notes"
func check_new_note(event):
	if event.is_action_released("note"):
		if entered_notes.empty() and not model.hovered_note:
			notes.spawn_note()


onready var locked_while_editing = [$"../CellWriteController", self, $"../StateController"]
onready var edit_note_controller = $"../EditNoteController"
onready var note_text = $"../../View/UI/NoteText"
onready var note_editing_sprite = $"../../View/UI/NoteEditing"
func check_edit_note(event):
	if event.is_action_released("note") and (not entered_notes.empty() or model.hovered_note):
		for c in locked_while_editing:
			c.add_lock("editing_note")
		edit_note_controller.release_lock("no_note")
		model.note_editing = model.hovered_note if model.hovered_note else entered_notes[0]
		model.selected_color = model.note_editing.color
		model.selection = model.get_cells_from_index_array(model.note_editing.cells)
		var c = model.note_editing.color
		note_text.modulate = Color(c.r * 0.5 + 0.5, c.g * 0.5 + 0.5, c.b * 0.5 + 0.5, 1)
		note_editing_sprite.visible = true
		note_editing_sprite.modulate = Color(c.r, c.g, c.b, note_editing_sprite.modulate.a)
		note_text.text = model.note_editing.text
		note_text.caret_position = len(note_text.text)
		note_text.caret_blink = true
		note_text.editable = true
		note_text.placeholder_text = "Enter note text..."
		note_text.grab_focus()

var entered_notes = []
onready var controllers = [$"../SelectionController", $"../CellWriteController", \
	$"../UIController", $"../TimerController"]
func _on_Note_entered(note):
	if not model.note_editing or note == model.note_editing:
		for c in controllers:
			c.add_lock("note")
		entered_notes.append(note)
		if not model.note_editing:
			var c = note.color
			note_text.text = note.text
			note_text.modulate = Color(c.r * 0.5 + 0.5, c.g * 0.5 + 0.5, c.b * 0.5 + 0.5)
			notes.highlight_note(note)

func _on_Note_exited(note):
	if not model.note_editing or note == model.note_editing:
		for c in controllers:
			c.release_lock("note")
		entered_notes.erase(note)
		if not model.note_editing:
			note_text.text = ""
			notes.highlight_note(null)

func clear_entered_notes():
	for c in controllers:
		c.release_lock("note")
	entered_notes.clear()
	note_text.text = ""
	notes.highlight_note(null)

func _on_Note_deleted(note):
	if note in entered_notes:
		_on_Note_exited(note)
	for c in model.cells:
		pass
	yield(get_tree(), "idle_frame")
	notes.update_cell_note_references()
	model.emit_signal("cell_state_changed")

func _on_Note_hidden_toggled(note):
	notes.update_cell_note_references()
