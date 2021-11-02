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

func _on_Model_selection_changed(value):
	for c in model.cells:
		c.get_node("View/ThinBorder").modulate = Color.green if c in value else Color.white
