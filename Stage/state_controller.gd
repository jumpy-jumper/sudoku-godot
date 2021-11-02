#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Controller

#  -------------------------
# |  CHECKS               |
#  -------------------------

func initialize_checks():
	checks[Controller.Device.MOUSE].append("check_undo")
	checks[Controller.Device.MOUSE].append("check_redo")

signal undo()
signal redo()

func check_undo(event):
	if InputWatcher.is_action_firing("undo") and not InputWatcher.is_action_firing("redo"):
		emit_signal("undo")

func check_redo(event):
	if InputWatcher.is_action_firing("redo"):
		emit_signal("redo")
