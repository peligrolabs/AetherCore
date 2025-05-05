extends MultiplayerSynchronizer

func _enter_tree() -> void:
	set_multiplayer_authority(1)
	if multiplayer.is_server():
		add_visibility_filter(_update_visibility)

func _update_visibility(peer_id: int) -> bool:
	if peer_id == 0:
		return false
	if peer_id == get_parent().peer_id:
		return true
	var other = Network.players[peer_id].character_node
	if not is_instance_valid(other):
		return false
	var my_pos: Vector2 = get_parent().global_position
	var peer_pos: Vector2 = other.global_position
	var dist = (peer_pos - my_pos).length()
	return dist < 200.0
