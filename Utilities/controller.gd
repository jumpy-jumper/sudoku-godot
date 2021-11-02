#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Node2D
class_name Controller

func _ready():
	find_model()
	initialize_checks()

func _process(dt):
	advance_timers(dt)

func _input(event):
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

var locked_checks = {}

func add_lock(lock, locked_checks = [], input_device = Device.ANY):
	if not lock in locks[input_device]:
		locks[input_device].append(lock)
	self.locked_checks[lock] = locked_checks

func release_lock(lock, input_device = Device.ANY):
	if lock in locks[input_device]:
		locks[input_device].erase(lock)

func is_locked(input_device = Device.ANY):
	return not locks[input_device].empty()

func is_check_locked(check, input_device = Device.ANY):
	for lock in locked_checks.keys():
		if lock in locks[input_device] and check in locked_checks[lock]:
			return true
	return false

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
	if not is_locked():
		for fun in checks[Device.ANY]:
			call(fun, event)
		if not is_locked(Device.MOUSE):
			for fun in checks[Device.MOUSE]:
				call(fun, event)
		if not is_locked(Device.KEYBOARD):
			for fun in checks[Device.KEYBOARD]:
				call(fun, event)
		if not is_locked(Device.JOYSTICK):
			for fun in checks[Device.JOYSTICK]:
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
