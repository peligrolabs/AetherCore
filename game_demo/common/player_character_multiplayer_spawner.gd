extends MultiplayerSpawner

const PLAYER_CHARACTER = preload("res://common/actors/player_character/player_character.tscn")

func _ready() -> void:
	spawn_function = _spawn

func _spawn(data: Variant) -> Node:
	print("[%s] player_character_multiplayer_spawner._spawn(%s)" % [multiplayer.get_unique_id(), data])
	assert(data is Dictionary)
	assert(data.peer_id is int)
	var player_character = PLAYER_CHARACTER.instantiate()
	player_character.name = "PlayerCharacter%s" % [data.peer_id]
	player_character.peer_id = data.peer_id
	return player_character
