#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Controller

#  -------------------------
# |  CHECKS               |
#  -------------------------

func initialize_checks():
	checks[Controller.Device.ANY].append("check_selection")
	checks[Controller.Device.ANY].append("check_selection_end")
	free_checks.append("check_selection_end")
	checks[Controller.Device.ANY].append("check_keep_selection")

#  -------------------------
# |  SELECTION INPUT        |
#  -------------------------

signal start_selection()
signal expand_selection()
signal select_all()
signal end_selection()

var initially_empty_selection = false

func check_selection(event):
	if event.is_action_pressed("select"):
		if is_timer_done("double_click_left"):
			initially_empty_selection = model.selection.empty()
			emit_signal("start_selection")
			start_timer("double_click_left", DOUBLE_CLICK_LENIENCY)
		else:
			if model.hovered_cell:
				emit_signal("expand_selection")
			elif initially_empty_selection:
				emit_signal("select_all")
	elif event.is_action_pressed("select_all") and not model.note_editing:
			emit_signal("select_all")

func check_selection_end(event):
	if event.is_action_released("select"):
		emit_signal("end_selection")

signal keep_selection()
signal stop_keep_selection()

func check_keep_selection(event):
	if event.is_action_pressed("keep_selection"):
		emit_signal("keep_selection")
	elif event.is_action_released("keep_selection"):
		emit_signal("stop_keep_selection")
