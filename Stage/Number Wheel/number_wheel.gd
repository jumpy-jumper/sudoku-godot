extends Node2D

signal selected(number)

var hovered_number = 5

const THETA_TO_NUMBER = {
	0 : 6,
	1 : 3,
	2 : 2,
	3 : 1,
	4 : 4,
	5 : 7,
	6 : 8,
	7 : 9,
}

const MIN_LENGTH_FOR_OUTER = 1028

var action_confirm = "number_wheel"
var action_cancel = "mouse_right"

func _process(_delta):
	var relative_mouse_pos = get_global_mouse_position() - global_position
	if relative_mouse_pos.length_squared() > MIN_LENGTH_FOR_OUTER:
		var theta = atan2(relative_mouse_pos.y, relative_mouse_pos.x)
		theta += PI / 16
		while theta < 0:
			theta += 2 * PI
		theta = int(theta / 2 / PI * 8)
		hovered_number = THETA_TO_NUMBER[theta]
		$Circle.visible = false
		$Cone.visible = true
		$Cone.rotation = theta * deg2rad(45)
	else:
		hovered_number = 5
		$Circle.visible = true
		$Cone.visible = false
	$"Number".text = str(hovered_number)
	
	if Input.is_action_just_released(action_confirm):
		emit_signal("selected", hovered_number)
		queue_free()

func change_colors(color):
	pass #lol
