#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Controller

#  -------------------------
# |  CHECKS               |
#  -------------------------

func initialize_checks():
	checks[Controller.Device.ANY].append("check_number")
	checks[Controller.Device.ANY].append("check_clear")
	checks[Controller.Device.ANY].append("check_number_wheel")

#  -------------------------
# |  NUMBER INPUT           |
#  -------------------------

signal write_number(num)

func check_number(event):
	for i in range(1, 10):
		if event.is_action_pressed(str(i)):
			emit_signal("write_number", i)

signal clear()

func check_clear(event):
	if event.is_action_pressed("clear"):
		emit_signal("clear")

#  -------------------------
# |  NUMBER WHEEL           |
#  -------------------------

signal number_wheel_spawned()
signal number_wheel_exited()

var number_wheel = preload("res://Stage/Number Wheel/number_wheel.tscn")

func check_number_wheel(event):
	if event.is_action_pressed("number_wheel"):
		if model.hovered_cell and model.hovered_cell.number == 0 or not model.selection.empty():
			var new_wheel = number_wheel.instance()
			add_child(new_wheel)
			new_wheel.global_position = (model.hovered_cell.global_position + model.get_cell_size() / 2) \
				if model.hovered_cell else get_global_mouse_position()
			new_wheel.connect("selected", self, "_on_NumberWheelSelected")
			emit_signal("number_wheel_spawned")
		elif model.selection.empty():
			emit_signal("clear")

func _on_NumberWheelSelected(num):
	if not is_locked():
		emit_signal("write_number", num)
	emit_signal("number_wheel_exited")
