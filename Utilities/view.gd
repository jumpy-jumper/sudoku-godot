#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Node2D
class_name View

onready var model = get_parent()

func _ready():
	initialize_watchers()

#  -------------------------
# |  RESPONSES              |
#  -------------------------

func _on_Model_property_changed(property, value):
	try_call_watcher(property, value)

#  -------------------------
# |  PROPERTY WATCHERS      |
#  -------------------------

var watchers = {}
var watcher_method_regex = RegEx.new()

func initialize_watchers():
	watcher_method_regex.compile("_on_Model_(.+)_changed")
	for fun in get_method_list():
		var result = watcher_method_regex.search(fun.name)
		if result and result.get_string(1) != "property":
			watchers[result.get_string(1)] = fun.name

func try_call_watcher(property, value):
	if watchers.has(property):
		call(watchers[property], value)
