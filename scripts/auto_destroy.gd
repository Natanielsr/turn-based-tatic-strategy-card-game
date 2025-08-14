extends Node

@export var time_to_destroy: float = 1.0 # time in seconds

func _ready() -> void:
	await get_tree().create_timer(time_to_destroy).timeout
	queue_free()
