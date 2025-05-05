extends Node

signal player_connected(peer_id: int)
signal player_disconnected(peer_id: int)

const SERVER_MAX_CONNECTIONS = 200

var players: Dictionary[int, PlayerInfo]

var scene_multiplayer: SceneMultiplayer

func _ready() -> void:
	scene_multiplayer = multiplayer
	
	scene_multiplayer.peer_connected.connect(_on_peer_connected)
	scene_multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	scene_multiplayer.connected_to_server.connect(_on_connected_to_server)
	scene_multiplayer.connection_failed.connect(_on_connected_failed)
	scene_multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	scene_multiplayer.auth_callback = _auth_callback
	scene_multiplayer.peer_authenticating.connect(_on_peer_authenticating)
	scene_multiplayer.peer_authentication_failed.connect(_on_peer_authentication_failed)

func start_server() -> Error:
	var port = ArgParse.get_arg_value("--port")
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, SERVER_MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	_print("Server started on port %s" % peer.host.get_local_port())
	return OK

func start_client(server_addr: String, server_port: int) -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(server_addr, server_port)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	_print("Starting client")
	return OK

func _on_peer_authenticating(peer_id: int) -> void:
	if not scene_multiplayer.is_server():
		_print("Sending auth to server")
		scene_multiplayer.send_auth(1, var_to_bytes({}))
		scene_multiplayer.complete_auth(1)

func _on_peer_authentication_failed(peer_id: int) -> void:
	_print("Authentiation failed (peer_id = %s)" % peer_id)

func _auth_callback(peer_id: int, data_bytes: PackedByteArray) -> void:
	if not scene_multiplayer.is_server():
		return
	
	var data = bytes_to_var(data_bytes)
	_print("Received auth (peer_id = %s, data = %s)" % [peer_id, data])
	
	if data is not Dictionary:
		scene_multiplayer.disconnect_peer(peer_id)
		return
	
	var player_info = PlayerInfo.new()
	players[peer_id] = player_info
	scene_multiplayer.complete_auth(peer_id)

func _on_peer_connected(peer_id: int) -> void:
	if scene_multiplayer.is_server():
		assert(peer_id in players)
		_print("Player %s connected!" % peer_id)
		player_connected.emit(peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	_print("Player %s disconnected" % peer_id)
	player_disconnected.emit(peer_id)
	var player_info = players[peer_id]
	if is_instance_valid(player_info.character_node):
		player_info.character_node.queue_free()
	players.erase(peer_id)

func _on_connected_to_server() -> void:
	_print("Connected to server")

func _on_connected_failed() -> void:
	_print("Connection failed")

func _on_server_disconnected() -> void:
	_print("Server disconnected")

func _print(msg: String) -> void:
	var id = scene_multiplayer.get_unique_id()
	if id == 1:
		id = "SERVER"
	print("[Network ", id, "] ", msg)

class PlayerInfo:
	var character_node: Node
