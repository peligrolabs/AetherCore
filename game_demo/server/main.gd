extends Node

var zone: Node

@onready var zone_root: Node2D = $ZoneRoot

func _ready() -> void:
	if not ArgParse.has_arg("--zone"):
		push_error("--zone is required for the server")
		get_tree().quit(1)
		return
	
	zone_root.initialize_zone(ArgParse.get_arg_value("--zone"))
	
	Network.player_connected.connect(_on_player_connected)
	Network.player_disconnected.connect(_on_player_disconnected)
	
	Network.start_server()

func _on_player_connected(peer_id: int) -> void:
	zone_root.spawn_player(peer_id)

func _on_player_disconnected(peer_id: int) -> void:
	zone_root.despawn_player(peer_id)
