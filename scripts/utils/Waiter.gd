extends Node2D

class_name Waiter

static var _instance : Waiter

func _ready():
	_instance = self

static func wait(seconds: float) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var timer := tree.create_timer(seconds)
	await timer.timeout
