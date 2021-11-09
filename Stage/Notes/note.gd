#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Model

var locked = false

export var color = Color.white
var text = ""
var cells = []

var hidden = false
var unhoverable = false

enum Type { NORMAL, CREATE, HELP }
var note_type = Type.NORMAL

var highlighted = false

signal deleted()

signal entered()
func _on_Clickable_mouse_entered():
	emit_signal("entered")

signal exited()
func _on_Clickable_mouse_exited():
	emit_signal("exited")

signal hidden_toggled()

func get_json():
	return to_json({
		"position" : var2str(global_position),
		"locked" : locked,
		"color" : color.to_html(),
		"text" : text,
		"cells" : cells,
		"hidden" : hidden,
		"unhoverable" : unhoverable,
		"type" : note_type
	})

func load_json(json):
	json = parse_json(json)
	global_position = str2var(json["position"])
	locked = json["locked"]
	color = Color(json["color"])
	text = json["text"]
	cells = json["cells"]
	hidden = json["hidden"]
	unhoverable = json["unhoverable"]

func connect_to_controller(controller):
	connect("entered", controller, "_on_Note_entered", [self])
	connect("exited", controller, "_on_Note_exited", [self])
	connect("deleted", controller, "_on_Note_deleted", [self])
	connect("hidden_toggled", controller, "_on_Note_hidden_toggled", [self])
