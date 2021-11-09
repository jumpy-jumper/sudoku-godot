#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Sprite

func _process(dt):
	if is_visible_in_tree():
		update_mouse_status()

func _input(event):
	if is_visible_in_tree():
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

var hovered = false
var clicked = false

func update_mouse_status():
	var previously_hovered = hovered
	
	var rect = texture.get_size() * global_scale
	var pos = get_global_mouse_position() - global_position
	pos = pos.rotated(-global_rotation)
	if centered:
		pos += rect / 2
	hovered = pos.x > 0 and pos.x < rect.x and pos.y > 0 and pos.y < rect.y
	
	if hovered != previously_hovered:
		emit_signal("mouse_status_changed", hovered, clicked)
		emit_signal("mouse_entered" if hovered else "mouse_exited")

export var action_button = BUTTON_LEFT

func check_mouse_press(event):
	if event is InputEventMouseButton and event.button_index == action_button:
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

onready var initial_alpha = modulate.a

export var clicked_alpha_increase = 0.15
export var hovered_alpha_increase = 0.25

func _on_Clickable_mouse_status_changed(hovered, clicked):
	modulate.a = clicked_alpha_increase + hovered_alpha_increase + initial_alpha if clicked else \
		(hovered_alpha_increase + initial_alpha if hovered else initial_alpha)
