extends MultiplayerSynchronizer

func _enter_tree() -> void:
	set_multiplayer_authority(get_parent().peer_id)
