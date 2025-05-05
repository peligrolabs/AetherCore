extends CharacterBody2D

const SPEED = 100.0

@export var input: Dictionary = { left = false, right = false, up = false, down = false }

var peer_id: int = 1: set = set_peer_id

func _enter_tree() -> void:
	set_multiplayer_authority(peer_id)

func _ready() -> void:
	position = Vector2(100, 100)
	reset_physics_interpolation.call_deferred()

func _process(delta: float) -> void:
	if is_multiplayer_authority():
		for a in ["left", "right", "up", "down"]:
			input[a] = Input.is_action_pressed(a)
		if Input.is_action_just_pressed("action"):
			_action_rpc.rpc_id(1)
	elif multiplayer.is_server():
		var v = Vector2(int(input.right) - int(input.left), int(input.down) - int(input.up))
		velocity = v * SPEED
		move_and_slide()

func set_peer_id(v: int) -> void:
	assert(not is_inside_tree(), "peer_id must be set before being added to the tree")
	assert(not is_node_ready(), "peer_id must be set before being added to the tree")
	peer_id = v

@rpc("any_peer", "call_remote", "reliable")
func _action_rpc() -> void:
	if not multiplayer.is_server():
		return
	print("action!")
