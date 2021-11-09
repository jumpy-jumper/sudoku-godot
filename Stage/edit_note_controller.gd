#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Controller

#  -------------------------
# |  CHECKS               |
#  -------------------------

func initialize_checks():
	checks[Controller.Device.MOUSE].append("check_confirm")

onready var notes_controller = $"../NotesController"
onready var locked_while_editing = [$"../CellWriteController", notes_controller, $"../StateController"]
onready var note_text = $"../../View/UI/NoteText"
onready var note_editing_sprite = $"../../View/UI/NoteEditing"
func check_confirm(event):
	if event.is_action_released("confirm_note"):
		confirm_note()

onready var notes = model.get_node("Notes")
func confirm_note():
		note_text.placeholder_text = ""
		note_text.editable = false
		model.note_editing.text = note_text.text
		model.note_editing.cells = model.get_selection_as_index_array()
		model.selection.clear()
		model.note_editing = null
		note_editing_sprite.visible = false
		for c in locked_while_editing:
			c.call_deferred("release_lock", "editing_note")
		notes.update_cell_note_references()
		model.emit_signal("cell_state_changed")
		notes.highlight_note(notes_controller.entered_notes[0] if not notes_controller.entered_notes.empty() else null)
		add_lock("no_note")
