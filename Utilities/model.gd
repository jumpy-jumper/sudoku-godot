#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Node2D
class_name Model

onready var view = $View
var controllers = []

func _ready():
	initialize_tracked()
	initialize_state()
	if view:
		connect("property_changed", view, "_on_Model_property_changed")

func _process(dt):
	call_deferred("recalculate_state")

func add_controller_lock(lock):
	for c in controllers:
		c.add_lock(lock)

func release_controller_lock(lock):
	for c in controllers:
		c.release_lock(lock)

#  -------------------------
# |  STATE TRACKING         |
#  -------------------------

signal state_changed()
signal property_changed(name, value)

# Only track name, position, rotation, and scale by default.
const blacklist = ["Node", "editor_description", "_import_path", "pause_mode", \
	"filename", "owner", "multiplayer", "custom_multiplayer", \
	"process_priority", "CanvasItem", "Visibility", "visible", "modulate", \
	"self_modulate", "show_behind_parent", "show_on_top", "light_mask", \
	"Material", "material", "use_parent_material", "Node2D", "Transform", \
	"rotation_degrees", "transform", "global_position", "global_rotation", \
	"global_rotation_degrees", "global_scale", "global_transform", "Z Index", \
	"z_index", "z_as_relative",	"script", "Script Variables", "view", \
	"controller", "tracked", "last_state", "blacklist"]
var tracked = []
var last_state = {}

func initialize_tracked():
	for property in get_property_list():
		if not property.name in blacklist:
			tracked.append(property.name)

func initialize_state():
	for property in tracked:
		last_state[property] = get(property)
		if last_state[property] is Array or last_state[property] is Dictionary:
			last_state[property] = last_state[property].hash()

func recalculate_state():
	if not is_visible_in_tree():
		return
	var properties_changed = {}
	for property in last_state.keys():
		var value = get(property)
		var hsh = value
		if value is Array or value is Dictionary:
			hsh = value.hash()
		if hsh != last_state[property]:
			last_state[property] = hsh
			properties_changed[property] = value
	
	for property in properties_changed.keys():
		emit_signal("property_changed", property, properties_changed[property])
	if not properties_changed.empty():
		emit_signal("state_changed")
