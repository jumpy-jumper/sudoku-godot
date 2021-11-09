#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Node

func _ready():
	initialize_rapid_fire()

func _process(dt):
	update_rapid_fire(dt)

#  -------------------------
# |  DICTS                  |
#  -------------------------

var rapid_fire_group = { 
	"undo" : "default",
	"redo" : "default",
	"number_wheel" : "default",
}

var rapid_fire_wait = { # How long to wait before rapid fire is active
	"default" : 0.15,
}

var rapid_fire_interval = { # How long to wait before allowing the action to fire again
	"default" : 0.03,
}

var rapid_fire_hold = { # How long to wait until rapid fire must be reinitialized
	"default" : 0.1,
}

#  -------------------------
# |  RAPID FIRE             |
#  -------------------------

var time_held = rapid_fire_group.duplicate()
var time_since_fired
var time_since_released = rapid_fire_hold.duplicate()

func initialize_rapid_fire():
	for key in time_held.keys():
		time_held[key] = 0
	time_since_fired = time_held.duplicate()

func update_rapid_fire(dt):
	for action in time_held:
		var group = rapid_fire_group[action]
		if Input.is_action_pressed(action):
			if time_since_released[group] <= rapid_fire_hold[group]:
				time_held[action] = rapid_fire_wait[group]
			if time_held[action] > rapid_fire_wait[group]:
				time_since_released[group] = rapid_fire_hold[group]
			time_held[action] += dt
			time_since_fired[action] += dt
		elif Input.is_action_just_released(action):
			if (time_held[action] > rapid_fire_wait[group]):
				time_since_released[group] = 0 
			time_held[action] = 0
		else:
			time_since_released[group] += dt
	
	for action in fired:
		time_since_fired[action] = 0
	fired.clear()

var fired = []

func is_action_firing(action):
	var pressed = Input.is_action_just_pressed(action) \
		or (time_held[action] > rapid_fire_wait[rapid_fire_group[action]] and \
			time_since_fired[action] >= rapid_fire_interval[rapid_fire_group[action]])
	
	if pressed:
		fired.append(action)
		return true
		
	return false

#  -------------------------
# |  DIRECTIONAL INPUT      |
#  -------------------------

var directional_groups = {
}

func get_direction(action_group):
	var dir = Vector2.ZERO
	if is_action_firing(directional_groups[action_group][0]):
		dir.x += 1
	if is_action_firing(directional_groups[action_group][1]):
		dir.y += 1
	if is_action_firing(directional_groups[action_group][2]):
		dir.x -= 1
	if is_action_firing(directional_groups[action_group][3]):
		dir.y -= 1
	return dir
