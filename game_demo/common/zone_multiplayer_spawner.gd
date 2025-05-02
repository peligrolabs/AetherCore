extends MultiplayerSpawner

const PLAYER_CHARACTER = preload("res://common/actors/player_character/player_character.tscn")

func _ready() -> void:
	spawn_function = _spawn

func _spawn(data: Variant) -> Node:
	print("[%s] zone_multiplayer_spawner._spawn(%s)" % [multiplayer.get_unique_id(), data])
	assert(data is Dictionary)
	assert(data.zone_name is String)
	
	var zone_path = "res://common/zones/{0}/{0}.tscn".format([data.zone_name])
	var zone_scene: PackedScene = load(zone_path)
	
	if not zone_scene:
		push_error("Failed to load zone \"%s\"" % zone_path)
		get_tree().quit(1)
		return null
	
	var zone = zone_scene.instantiate()
	
	return zone
