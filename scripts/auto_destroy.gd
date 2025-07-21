extends Node

@export var lifetime: float = 1.0 # time in seconds

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()
