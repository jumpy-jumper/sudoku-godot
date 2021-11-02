#  -------------------------
# |  MAIN                   |
#  -------------------------

extends Node2D

func _ready():
	if not Settings.settings["check_for_updates"]:
		queue_free()
	request_hash()

func _process(dt):
	update_text(dt)

func _input(event):
	pass

#  -------------------------
# |  SIGNAL RESPONSES       |
#  -------------------------

func _on_HashRequest_request_completed(result, response_code, headers, body):
	receive_hash(result, response_code, headers, body)

func _on_PckRequest_request_completed(result, response_code, headers, body):
	receive_pck(result, response_code, headers, body)

func _on_UpdateButton_pressed():
	request_pck()

#  -------------------------
# |  REQUESTS               |
#  -------------------------

export(String, MULTILINE) var hash_url = ""
export(String, MULTILINE) var pck_url = ""
var cur_dir = ""
var pck_hash = ""
var received = false

var act_time = 0
func update_text(dt):
	if (not received) and $HashRequest.get_http_client_status() > 0 and act_time >= 5:
		$"CanvasLayer/Label".text = "Connecting to server... (" + str($HashRequest.get_http_client_status()) + ")"
	act_time += dt

func request_hash():
	var path = Array(OS.get_executable_path().split("/"))
	path.pop_back()
	for dir in path:
		cur_dir += dir + "/"
	var foo = File.new()
	pck_hash = foo.get_sha256(cur_dir + "/sudoku_godot.pck")
	print(pck_hash)
	foo.close()
	$HashRequest.request(hash_url)

func receive_hash(result, response_code, headers, body):
	received = true
	match(result):
		HTTPRequest.RESULT_SUCCESS:
			print(body.get_string_from_utf8())
			if len(body) != 64:
				$"CanvasLayer/Label".text = "ERROR: Received wrong file (please report)."
				return
			if body.get_string_from_utf8().to_upper() != pck_hash.to_upper():
				$"CanvasLayer/UpdateButton".visible = true
			disconnect("request_completed", self, "_version_request_completed")
			$"CanvasLayer/Label".text = ""
		HTTPRequest.RESULT_CHUNKED_BODY_SIZE_MISMATCH :
			$"CanvasLayer/Label".text = "ERROR: "
		HTTPRequest.RESULT_CANT_CONNECT:
			$"CanvasLayer/Label".text = "ERROR: Failed while connecting."
		HTTPRequest.RESULT_CANT_RESOLVE:
			$"CanvasLayer/Label".text = "ERROR: Failed while resolving."
		HTTPRequest.RESULT_CONNECTION_ERROR :
			$"CanvasLayer/Label".text = "ERROR: Failed due to connection (read/write) error."
		HTTPRequest.RESULT_SSL_HANDSHAKE_ERROR :
			$"CanvasLayer/Label".text = "ERROR: Failed SSL Handshake."
		HTTPRequest.RESULT_NO_RESPONSE :
			$"CanvasLayer/Label".text = "ERROR: No response."
		HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED :
			$"CanvasLayer/Label".text = "ERROR: Exceeded maximum size limit."
		HTTPRequest.RESULT_REQUEST_FAILED :
			$"CanvasLayer/Label".text = "ERROR: Failed."
		HTTPRequest.RESULT_DOWNLOAD_FILE_CANT_OPEN :
			$"CanvasLayer/Label".text = "ERROR: Could not open the download file."
		HTTPRequest.RESULT_DOWNLOAD_FILE_WRITE_ERROR :
			$"CanvasLayer/Label".text = "ERROR: Could not write to the download file."
		HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED :
			$"CanvasLayer/Label".text = "ERROR: Redirect limit reached."
		HTTPRequest.RESULT_TIMEOUT :
			$"CanvasLayer/Label".text = "ERROR: Timed out."

func request_pck():
	$"CanvasLayer/UpdateButton".visible = false
	$PckRequest.request(pck_url)
	$"CanvasLayer/Label".text = "Downloading..."

func receive_pck(result, response_code, headers, body):
	var file = File.new()
	file.open(cur_dir + "sudoku_godot.pck", File.WRITE)
	file.store_buffer(body)
	file.close()
	
	$"CanvasLayer/Label".text = "Done. Restarting."
	
	OS.execute(OS.get_executable_path(), [], false)
	get_tree().quit()
