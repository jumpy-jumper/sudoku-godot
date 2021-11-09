#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Node2D

func _ready():
	randomize()
	initialize_backgrounds()

func _process(dt):
	if len(backgrounds) > 1 and Input.is_action_just_pressed("select") and Input.is_action_pressed("number_wheel"):
		$BG/BgSprite/AnimationPlayer.play("switch")

#  -------------------------
# |  PERSISTENT VARIABLES   |
#  -------------------------

var sudoku_to_load = {
	#"name" : "159 Thermo",
	#"numbers" : "000000000000000000000000000000000000000000000000000000000000000000000000000000000",
	#"solution" : "832465917157829346496173582589714623763982154214356798678541239945237861321698475",
	#"name" : "Chaos Construction: Minesweeper",
	#"numbers" : "000000000200000000000000001000000000000000000570010000000001000020000000000000000",
	#"solution" : "348165729261983475857439261492578613615392847573614982984721536126857394739246158",
	#"uses_boxes" : false,
	#"no_gaps" : true,
	#"name" : "Ghost Digit",
	#"numbers" : "000000000000000000000000000000000000000000000000000000000000000000000000000000009",
	#"solution" : "924715386138496572675382194412873965589261437763954218891547623257639841346128759",
	#"no_gaps" : true,
	"name" : "Araf Sudoku",
	"numbers" : "000000000000000000000000000000000000000000000000000000000000000000000000000000000",
	"solution" : "951372486823416795674958321219564837748139652536287914397621548185743269462895173",
	"no_gaps" : true,
}

const SAVE_PROFILES = ["user://savedata1.json", "user://savedata2.json", "user://savedata3.json"]
var cur_profile = 0

func get_save_path():
	return "user://savedata" + str(cur_profile) + ".json"

func get_savedata():
	var save_file = File.new()
	var savedata = null
	if save_file.file_exists(get_save_path()):
		save_file.open(get_save_path(), File.READ)
		savedata = parse_json(save_file.get_as_text())
		if not savedata:
			savedata = null
	return savedata

#  -------------------------
# |  HELPERS                |
#  -------------------------

func get_file_as_text(path):
	var file = File.new()
	file.open(path, File.READ)
	var text = file.get_as_text()
	file.close()
	return text

func _on_Back_pressed():
	get_tree().change_scene("res://Title/title.tscn")

#  -------------------------
# |  BACKGROUNDS	        |
#  -------------------------

var backgrounds = []

func initialize_backgrounds():
	var cur_dir = ""
	var path = Array(OS.get_executable_path().split("/"))
	path.pop_back()
	for dir in path:
		cur_dir += dir + "/"
	
	var dir = Directory.new()
	if dir.dir_exists(cur_dir + "bg"):
		dir.open(cur_dir + "bg")
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "":
				break
			if file == "." or file == "..":
				continue
			var image = Image.new()
			var texture = ImageTexture.new()
			var error = image.load(cur_dir + "bg/" + file)
			if error == OK:
				texture.create_from_image(image)
				backgrounds.append(texture)
	
	if len(backgrounds) > 0:
		change_background()

func change_background():
	var foo = backgrounds + []
	if $BG/BgSprite.texture in foo:
		foo.erase($BG/BgSprite.texture)
	$BG/BgSprite.texture = foo[randi() % len(foo)]

var stage = preload("res://Stage/stage.tscn")
func load_stage():
	#get_tree().change_scene_to(stage)
	get_tree().root.get_node("LevelSelect").run_stage(sudoku_to_load)
