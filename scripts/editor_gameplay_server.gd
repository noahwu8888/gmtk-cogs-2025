extends Node


@export var _level_manager: LevelManager


var server = TCPServer.new()
var client: StreamPeerTCP


func pprint(msg: String):
	print("[Editor Gameplay]: %s" % msg)


func _ready() -> void:
	_level_manager.level_finished.connect(_level_manager.restart_level)
	server.listen(8484)


func _process(delta: float) -> void:
	if server.is_connection_available():
		if client:
			client.disconnect_from_host()
		client = server.take_connection()
		pprint("Accepted client: %s:%s" % [client.get_connected_host(), client.get_connected_port()])
	
	if client:
		client.poll()
		if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			if client.get_available_bytes() > 0:
				var data = client.get_var(true) as Dictionary
				_on_receive_data(data)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		server.stop()


func _on_receive_data(data: Dictionary):
	pprint("Received data: %s" % data)
	if data.command == "load_level":
		var level = load(data.level_path) as Level
		_level_manager.load_level(level)
	elif data.command == "load_room":
		var room = load(data.room_path) as PackedScene
		var level = Level.new()
		level.name = "Test %s" % room.resource_name
		level.room_prefabs.append(room)
		_level_manager.load_level(level)
