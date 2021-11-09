#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Controller

func _ready():
	initialize_secondary_marks()

#  -------------------------
# |  CHECKS               |
#  -------------------------

func initialize_checks():
	checks[Controller.Device.ANY].append("check_number")
	checks[Controller.Device.ANY].append("check_clear")
	checks[Controller.Device.ANY].append("check_number_wheel")
	checks[Controller.Device.ANY].append("check_secondary_marks")

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

signal toggle_secondary_marks(active)

func initialize_secondary_marks():
	call_deferred("emit_signal", "toggle_secondary_marks", Settings.settings["secondary_marks"])

func check_secondary_marks(event):
	if event.is_action_pressed("secondary_marks_toggle") \
		and not Input.is_action_pressed("secondary_marks_hold"):
			Settings.settings["secondary_marks"] = not Settings.settings["secondary_marks"]
			Settings.apply_settings()
			emit_signal("toggle_secondary_marks", Settings.settings["secondary_marks"])
	elif event.is_action_pressed("secondary_marks_hold"):
		emit_signal("toggle_secondary_marks", not Settings.settings["secondary_marks"])
	elif event.is_action_released("secondary_marks_hold"):
		emit_signal("toggle_secondary_marks", Settings.settings["secondary_marks"])

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
			if model.hovered_cell:
				emit_signal("clear")
	
	if event.is_action_pressed("number_wheel"):
		if not model.hovered_cell and model.selection.empty():
			model.fill_singles()

func _on_NumberWheelSelected(num):
	if not is_locked():
		emit_signal("write_number", num)
	emit_signal("number_wheel_exited")
