#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Controller

func _ready():
	initialize_color_picker()

#  -------------------------
# |  CHECKS                  |
#  -------------------------

func _on_Back_pressed():
	model.get_parent().switch_to_level_select()

#  -------------------------
# |  UI Lock                |
#  -------------------------

onready var controllers = [$"../SelectionController", $"../CellWriteController"]

func _on_UI_mouse_status_changed(hovered, clicked):
	if not hovered and not clicked:
		for c in controllers:
			c.release_lock("ui")
	else:
		for c in controllers:
			c.add_lock("ui")

#  -------------------------
# |  COLOR PICKER           |
#  -------------------------

export(NodePath) var color_picker = ""

func initialize_color_picker():
	for c in get_node(color_picker).get_children():
		c.connect("pressed", self, "_on_Color_pressed", [c])

func _on_Color_pressed(color):
	if not model.note_editing:
		color_cells(color)
	else:
		change_note_editing_color(color)

func color_cells(color):
	var foo = color.modulate
	foo.a = 1
	if foo == Color.white:
		var no_colored_cells_found = true
		for c in model.selection:
			if not c.colors.empty():
				no_colored_cells_found = false
		if not no_colored_cells_found:
			for c in model.selection:
				if not c.colors.empty():
					c.colors.clear()
			model.emit_signal("cell_state_changed")
			return
	
	model.selected_color = color.modulate
	model.selected_color.a = 1
	var color_in_all = true
	for c in model.selection:
		if not model.selected_color.to_html() in c.colors:
			color_in_all = false
			break
	if color_in_all:
		for c in model.selection:
			c.remove_color_completely(model.selected_color.to_html())
	else:
		for c in model.selection:
			c.add_color(model.selected_color.to_html())

	model.emit_signal("cell_state_changed")

onready var editing_note_sprite = $"../../View/UI/NoteEditing"
onready var note_text = $"../../View/UI/NoteText"
func change_note_editing_color(color):
	model.selected_color = color.modulate
	model.selected_color.a = 1
	model.note_editing.color = model.selected_color
	var a = editing_note_sprite.modulate.a
	editing_note_sprite.modulate = model.selected_color
	editing_note_sprite.modulate.a = a
	var c = editing_note_sprite.modulate
	note_text.modulate = Color(c.r * 0.5 + 0.5, c.g * 0.5 + 0.5, c.b * 0.5 + 0.5)
