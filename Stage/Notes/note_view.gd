#  -------------------------
# |  MAIN                   |
#  -------------------------

extends View

#  -------------------------
# |  WATCHERS               |
#  -------------------------

onready var clickable = $Clickable
func _on_Model_color_changed(value):
	var foo = clickable.modulate.a
	clickable.modulate = value
	clickable.modulate.a = foo

onready var hidden = $Hidden
func _on_Model_hidden_changed(value):
	hidden.visible = value
	unhoverable.visible = false if value else model.unhoverable

onready var unhoverable = $Unhoverable
func _on_Model_unhoverable_changed(value):
	unhoverable.visible = value and not model.hidden

func _on_Model_highlighted_changed(value):
	modulate.a = 1 + (0.5 if value else 0)
