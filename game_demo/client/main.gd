extends Node

func _ready() -> void:
	Network.start_client("127.0.0.1", ArgParse.get_arg_value("--port"))
