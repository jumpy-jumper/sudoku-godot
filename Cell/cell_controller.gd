#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Controller

#  -------------------------
# |  HOVERED                |
#  -------------------------

signal hovered()
signal dehovered()

func _on_Clickable_mouse_entered():
	emit_signal("hovered")

func _on_Clickable_mouse_exited():
	emit_signal("dehovered")
