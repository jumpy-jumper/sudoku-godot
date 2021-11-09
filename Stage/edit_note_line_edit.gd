#  -------------------------
# |  MAIN                   |
#  -------------------------

extends LineEdit

func _process(_dt):
	editable = is_visible_in_tree()
