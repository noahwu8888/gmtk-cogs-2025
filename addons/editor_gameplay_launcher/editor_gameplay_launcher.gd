@tool
extends EditorPlugin


signal connected

var is_connected: bool
var in_valid_room: bool
var valid_room_path: String

var _play_button: Button
var _client: StreamPeerTCP = StreamPeerTCP.new()


func pprint(msg: String):
	print("[Room Player]: %s" % msg)


func _enter_tree() -> void:
	scene_changed.connect(_on_scene_changed)
	var interface = get_editor_interface()
	_play_button = Button.new()
	_play_button.pressed.connect(_on_pressed)
	_play_button.icon = interface.get_base_control().get_theme_icon("CharacterBody2D", "EditorIcons")
	_play_button.tooltip_text = "Play the current room"
	add_control_to_container(CONTAINER_TOOLBAR, _play_button)
	is_connected = false
	set_process(false)


func _on_scene_changed(root: Node):
	in_valid_room = false
	in_valid_room = root.get_script() and \
		(root.get_script() as GDScript).resource_path == "res://scripts/room.gd" and \
		FileAccess.file_exists(root.scene_file_path)
	_play_button.disabled = not in_valid_room
	valid_room_path = root.scene_file_path if in_valid_room else ""


func _on_pressed():
	if not in_valid_room:
		return
	_client.disconnect_from_host()
	is_connected = false
	get_editor_interface().play_custom_scene("res://scenes/editor_gameplay.tscn")
	pprint("ressed")
	var sucessful = await try_connect_to_server()
	if not sucessful:
		return
	await connected
	print("Sending var")
	_client.put_var({
		"command": "load_room",
		"room_path": valid_room_path
	}, true)

func try_connect_to_server() -> bool:
	for i in range(10):
		var error = _client.connect_to_host("127.0.0.1", 8484)
		if error == OK:
			set_process(true)
			return true
		else:
			pprint("Failed to initiate connection: %s" % error_string(error))
			set_process(false)
		await get_tree().create_timer(1.0).timeout
	return false


func _on_receive_data(data: Dictionary):
	pprint("Received data: %s" % data)


func _process(delta: float) -> void:
	_client.poll()
	var status = _client.get_status()
	if status == StreamPeerTCP.STATUS_CONNECTED:
		if not is_connected:
			pprint("Connected to gameplay server!")
			is_connected = true
			connected.emit()
		# Check for incoming data from the server
		if _client.get_available_bytes() > 0:
			var data = _client.get_var(true) as Dictionary
			_on_receive_data(data)
	elif status == StreamPeerTCP.STATUS_NONE or status == StreamPeerTCP.STATUS_ERROR:
		if is_connected:
			pprint("Disconnected from server.")
		else:
			pprint("Connection failed or server not available.")
		set_process(false)


func _exit_tree() -> void:
	scene_changed.disconnect(_on_scene_changed)
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, _play_button)
	_play_button.queue_free()
