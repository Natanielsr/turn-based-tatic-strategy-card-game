extends Node2D

class_name Card

signal hovered
signal hovered_off

var card_id
var type
var attack_points : int
var life_points: int

var start_position

func _ready() -> void:
	#All cards must be a child of CardManager or this will error
	get_parent().connect_card_signals(self)

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
	
