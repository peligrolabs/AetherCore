extends Node2D

@onready var player_character_multiplayer_spawner: MultiplayerSpawner = %PlayerCharacterMultiplayerSpawner
@onready var zone_multiplayer_spawner: MultiplayerSpawner = %ZoneMultiplayerSpawner

func initialize_zone(zone_name: String) -> void:
	assert(multiplayer.is_server())
	zone_multiplayer_spawner.spawn({ zone_name = zone_name })

func spawn_player(peer_id: int) -> void:
	assert(multiplayer.is_server())
	Network.players[peer_id].character_node = player_character_multiplayer_spawner.spawn({ peer_id = peer_id })

func despawn_player(peer_id: int) -> void:
	assert(multiplayer.is_server())
	Network.players[peer_id].character_node.queue_free()
