#  -------------------------
# |  MAIN                   |
#  -------------------------

extends View

#  -------------------------
# |  WATCHERS               |
#  -------------------------

func _on_Model_cells_changed(value):
	update_line()

func _on_Model_padding_changed(value):
	update_line()

func update_line():
	pass
