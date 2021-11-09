#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Node2D
class_name Controller

func _ready():
	find_model()
	initialize_checks()
	model.controllers.append(self)

func _process(dt):
	advance_timers(dt)

func _input(event):
	if is_visible_in_tree():
		do_checks(event)

enum Device { ANY, MOUSE, KEYBOARD, JOYSTICK }

var model = null

#  -------------------------
# |  INPUT VARIABLES        |
#  -------------------------

const DOUBLE_CLICK_LENIENCY = 0.25

#  -------------------------
# |  CONSTRAINTS            |
#  -------------------------

var locks = {
	Device.ANY : [],
	Device.MOUSE : [],
	Device.KEYBOARD : [],
	Device.JOYSTICK : [],
}

var free_checks = []

func add_lock(lock, locked_checks = [], input_device = Device.ANY):
	if not lock in locks[input_device]:
		locks[input_device].append(lock)

func release_lock(lock, input_device = Device.ANY):
	if lock in locks[input_device]:
		locks[input_device].erase(lock)

func release_all_locks():
	locks = {
		Device.ANY : [],
		Device.MOUSE : [],
		Device.KEYBOARD : [],
		Device.JOYSTICK : [],
}

func is_locked(input_device = Device.ANY):
	return not locks[input_device].empty()

#  -------------------------
# |  CHECKS                 |
#  -------------------------

var checks = {
	Device.ANY : [],
	Device.MOUSE : [],
	Device.KEYBOARD : [],
	Device.JOYSTICK : [],
}

func find_model():
	model = get_parent()
	while "controller" in model.name.to_lower():
		model = model.get_parent()

func initialize_checks():
	pass

func do_checks(event):
	var is_locked = [is_locked(), is_locked(Device.MOUSE), \
		is_locked(Device.KEYBOARD), is_locked(Device.JOYSTICK)]
	for fun in checks[Device.ANY] + checks[Device.MOUSE] + checks[Device.KEYBOARD] + checks[Device.JOYSTICK]:
		if fun in free_checks or not is_locked[0]:
			call(fun, event)

#  -------------------------
# |  TIMERS                 |
#  -------------------------

var timers = {}

func advance_timers(dt):
	for timer in timers.keys() + []:
		timers[timer] -= dt
		if timers[timer] < 0:
			timers.erase(timer)

func start_timer(timer, duration):
	timers[timer] = duration

func is_timer_done(timer):
	return not timers.has(timer)

func reset_timers():
	timers.clear()
