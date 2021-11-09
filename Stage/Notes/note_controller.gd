#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Controller

#  -------------------------
# |  CHECKS               |
#  -------------------------

func initialize_checks():
	checks[Controller.Device.MOUSE].append("check_drag_and_drop")
	checks[Controller.Device.MOUSE].append("check_delete")
	checks[Controller.Device.MOUSE].append("check_state_change")

onready var clickable = $"../../View/Clickable"
onready var window =  Vector2(ProjectSettings.get_setting("display/window/size/width"), \
	ProjectSettings.get_setting("display/window/size/height"))
var initial_position = Vector2.ZERO
const DRAG_MINIMUM = 8
func check_drag_and_drop(event):
	if clickable.clicked:
		var mouse_pos = get_global_mouse_position()
		if (mouse_pos - initial_position).length() > DRAG_MINIMUM:
			initial_position = Vector2(-1000, -1000)
			if mouse_pos.x > 0 and mouse_pos.x < window.x:
					model.global_position.x = mouse_pos.x
			if mouse_pos.y > 0 and mouse_pos.y < window.y:
					model.global_position.y = mouse_pos.y
			model.global_position = model.global_position.snapped(\
				Settings.settings["notes_grid_snap"]) + Settings.settings["notes_grid_offset"]

onready var animator = $"../../View/Clickable/AnimationPlayer"
func check_delete(event):
	if not clickable.hovered or event.is_action_released("delete_note"):
		animator.play("default")
	elif clickable.hovered and event.is_action_pressed("delete_note"):
		animator.play("delete")

func _on_Clickable_mouse_status_changed(hovered, clicked):
	initial_position = get_global_mouse_position()

var make_unhoverable = true
var mouse_initial_position = Vector2.ZERO
func check_state_change(event):
	if clickable.hovered:
		if event.is_action_pressed("note_change_state"):
				mouse_initial_position = get_global_mouse_position()
		elif event.is_action_released("note_change_state") \
			and (get_global_mouse_position() - mouse_initial_position).length() < DRAG_MINIMUM:
				model.hidden = not model.hidden
				model.emit_signal("hidden_toggled")
				if not model.hidden:
					make_unhoverable = true
					start_timer("make_unhoverable", 0.5)
					mouse_initial_position = model.global_position
		if make_unhoverable:
			if model.global_position != mouse_initial_position or \
				not Input.is_action_pressed("note_change_state"):
					make_unhoverable = false
			elif is_timer_done("make_unhoverable") and Input.is_action_pressed("note_change_state"):
				model.unhoverable = not model.unhoverable
				model.hidden = false
				model.emit_signal("hidden_toggled")
