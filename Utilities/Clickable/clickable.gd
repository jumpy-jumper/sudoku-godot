#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Sprite

func _process(dt):
	update_mouse_status()

func _input(event):
	check_mouse_press(event)

#  -------------------------
# |  ENTER AND EXIT         |
#  -------------------------

signal mouse_status_changed(hovered, clicked)
signal mouse_entered()
signal mouse_exited()
signal clicked()
signal pressed()
signal released()

export var actionate_on_press = false

onready var rect = texture.get_size() * global_scale

var hovered = false
var clicked = false

func update_mouse_status():
	var previously_hovered = hovered
	
	var pos = get_global_mouse_position() - global_position
	pos /= global_scale
	pos = pos.rotated(rotation)
	hovered = pos.x > 0 and pos.x < rect.x and pos.y > 0 and pos.y < rect.y
	
	if hovered != previously_hovered:
		emit_signal("mouse_status_changed", hovered, clicked)
		emit_signal("mouse_entered" if hovered else "mouse_exited")

func check_mouse_press(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if hovered:
				if actionate_on_press:
					emit_signal("mouse_status_changed", hovered, clicked)
					emit_signal("pressed")
				elif hovered:
					clicked = true
					emit_signal("mouse_status_changed", hovered, clicked)
					emit_signal("clicked")
		else:
			if hovered and clicked:
				clicked = false
				emit_signal("mouse_status_changed", hovered, clicked)
				emit_signal("pressed")
			elif clicked:
				clicked = false
				emit_signal("mouse_status_changed", hovered, clicked)
				emit_signal("released")

const not_hovered_alpha = 0.65

func _on_Clickable_mouse_status_changed(hovered, clicked):
	modulate.a = 1 if hovered or clicked else 0.65
