extends Node

class_name Effect

var effect_name
var duration
var apply_momment : Moment
enum Moment{
	START_TURN,
	END_TURN,
	FIX
}

func _init(_effect_name : String, _duration_turn: int, _apply_momment: Moment):
	self.effect_name = _effect_name
	self.duration = _duration_turn
	self.apply_momment = _apply_momment

func apply_effect(_entity : Entity):
	pass

func expire(_enitity : Entity):
	pass
