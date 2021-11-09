#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Controller

#  -------------------------
# |  CHECKS               |
#  -------------------------

func initialize_checks():
	checks[Controller.Device.MOUSE].append("check_pause")

signal pause()

func check_pause(event):
	if event.is_action_pressed("pause"):
		emit_signal("pause")

func _on_ClockClickable_pressed():
	emit_signal("pause")
