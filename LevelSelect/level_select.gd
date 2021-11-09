extends Node2D

const FADE_TIME = 0.0625

func switch_to_level_select():
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property($Stage, "modulate:a", 1, 0, FADE_TIME, \
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(get_tree().create_timer(FADE_TIME), "timeout")
	tween.interpolate_property($LeftSet, "modulate:a", 0, 1, FADE_TIME, \
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	$Stage.visible = false
	$LeftSet.visible = true
	$LeftSet.load_savedata()
	yield(get_tree().create_timer(FADE_TIME), "timeout")
	tween.queue_free()

func run_stage(sudoku):
	var tween = Tween.new()
	add_child(tween)
	var thread = Thread.new()
	#thread.start($Stage, "load_sudoku", sudoku)
	$Stage.load_sudoku(sudoku)
	tween.interpolate_property($LeftSet, "modulate:a", 1, 0, FADE_TIME, \
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(get_tree().create_timer(FADE_TIME), "timeout")
	$LeftSet.visible = false
	tween.interpolate_property($Stage, "modulate:a", 0, 1, FADE_TIME, \
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	$Stage.visible = true
	yield(get_tree().create_timer(FADE_TIME), "timeout")
	tween.queue_free()
