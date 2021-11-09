#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Node

func _ready():
	load_settings()
	apply_settings()

func _input(event):
	check_settings_input(event)

#  -------------------------
# |  SETTINGS               |
#  -------------------------

var settings = {
	"check_for_updates" : true,
	# Display
	"fullscreen" : false,
	"resolution" : Vector2(1280, 720),
	# Stage
	"autosave" : true,
	"box_selection" : false,
	"keep_selection" : false,
	"secondary_marks" : false,
	# Stage - View
	"no_gaps" : false,
	"reverse_numpad" : true,
	"cell_alpha" : 0.5,
	"candidates_all_visible_alpha" : 0.1,
	"candidates_9_alpha" : 0.05,
	"candidates_8_alpha" : 0.25,
	"candidates_7_alpha" : 0.3,
	"candidates_6_alpha" : 0.35,
	"candidates_5_alpha" : 0.4,
	"candidates_4_alpha" : 0.5,
	"candidates_3_alpha" : 0.8,
	"candidates_2_alpha" : 0.9,
	"candidates_1_alpha" : 1,
	"notes_grid_snap" : Vector2(32, 32),
	"notes_grid_offset" : Vector2(0, 0),
	# Stage - Assist
	"autofill" : true,
	"warn_impossible_number" : true,
	"warn_incorrect_number" : false,
	"warn_solution_not_in_candidates" : false,
	"highlight_naked_singles" : true,
	"highlight_hidden_singles" : false,
	"fill_naked_singles" : true,
	"fill_hidden_singles" : true,
	"highlight_bivalue_cells" : true,
	# Colors
	"stage_default_color" : Color.white,
	"stage_givens_color" : Color.lightcyan,
	"stage_won_color" : Color.lightgoldenrod,
	"stage_error_color" : Color.lightcoral,
	"stage_singles_color" : Color.gold,
	"stage_pairs_color" : Color.cyan,
}

func load_settings():
	var settings_file = File.new()
	if settings_file.file_exists("user://settings.json"):
		settings_file.open("user://settings.json", File.READ)
		var new_settings = parse_json(settings_file.get_as_text())
		if new_settings:
			var regex_is_vector2 = RegEx.new()
			regex_is_vector2.compile("([0-9]+, [0-9]+)") # check if it's Vector2
			var regex_vector2_values = RegEx.new()
			regex_vector2_values.compile("[0-9]+")
			
			var regex_is_color = RegEx.new()
			regex_is_color.compile("[0-9]+\\.?[0-9]*,[0-9]+\\.?[0-9]*,[0-9]+\\.?[0-9]*,[0-9]+\\.?[0-9]*") # check if it's Color
			var regex_color_values = RegEx.new()
			regex_color_values.compile("[0-9]+\\.?[0-9]*")
			
			for key in settings.keys():
				if new_settings.has(key):
					if new_settings[key] is String and regex_is_vector2.search(new_settings[key]):
						var result = regex_vector2_values.search_all(new_settings[key])
						settings[key] = Vector2(int(result[0].get_string()), int(result[1].get_string()))
					elif new_settings[key] is String and regex_is_color.search(new_settings[key]):
						var result = regex_color_values.search_all(new_settings[key])
						settings[key] = Color(float(result[0].get_string()), \
							float(result[1].get_string()), \
							float(result[2].get_string()), \
							float(result[3].get_string()))
					else:
						settings[key] = new_settings[key]
	settings_file.close()

signal settings_changed()

func apply_settings():
	if settings["fullscreen"]:
		#OS.set_borderless_window(true)
		#OS.set_window_size(OS.get_screen_size())
		#OS.set_window_position(Vector2.ZERO)
		OS.window_fullscreen = true
	else:
		#OS.set_borderless_window(false)
		#OS.set_window_size(settings["resolution"])
		#OS.set_window_position(Vector2.ZERO)
		OS.window_fullscreen = false
	
	var settings_file = File.new()
	settings_file.open("user://settings.json", File.WRITE)
	settings_file.store_line(to_json(settings))
	settings_file.close()	
	
	emit_signal("settings_changed")


func check_settings_input(event):
	if event.is_action_pressed("fullscreen"):
		settings["fullscreen"] = not settings["fullscreen"]
		apply_settings()
