#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Controller

#  -------------------------
# |  CHECKS               |
#  -------------------------

func initialize_checks():
	checks[Controller.Device.ANY].append("check_selection")
	checks[Controller.Device.ANY].append("check_keep_selection")

#  -------------------------
# |  SELECTION INPUT        |
#  -------------------------

signal start_selection()
signal expand_selection()
signal end_selection()

func check_selection(event):
	if event.is_action_pressed("select"):
		if is_timer_done("double_click_left"):
			emit_signal("start_selection")
			start_timer("double_click_left", DOUBLE_CLICK_LENIENCY)
		else:
			emit_signal("expand_selection")
	elif event.is_action_released("select"):
		emit_signal("end_selection")

signal keep_selection()
signal stop_keep_selection()

func check_keep_selection(event):
	if event.is_action_pressed("keep_selection"):
		emit_signal("keep_selection")
	elif event.is_action_released("keep_selection"):
		emit_signal("stop_keep_selection")
