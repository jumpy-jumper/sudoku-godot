#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Model

#  -------------------------
# |  NUMBER                 |
#  -------------------------

var locked = false
export var number = 0
var solution = 0

#  -------------------------
# |  PENCIL MARKS           |
#  -------------------------

var marked = [false, false, false, false, false, false, false, false, false]
var marked_secondary = [false, false, false, false, false, false, false, false, false]
var trivial_impossibles = [false, false, false, false, false, false, false, false, false]
var hidden_single = 0

#  -------------------------
# |  SELECTION              |
#  -------------------------

signal hovered()
signal dehovered()

func _on_Controller_hovered():
	emit_signal("hovered")

func _on_Controller_dehovered():
	emit_signal("dehovered")
