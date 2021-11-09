#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Model

#  -------------------------
# |  CONSTRAINT             |
#  -------------------------

var rules = []

enum Location { GLOBAL, CELLS, INTERSECTION }
var location_type = Location.GLOBAL

func is_met(cells):
	for rule in rules:
		if not is_rule_met(rule, cells):
			return false
	return true

#  -------------------------
# |  RULES                   |
#  -------------------------

func is_rule_met(rule, cells):
	pass
