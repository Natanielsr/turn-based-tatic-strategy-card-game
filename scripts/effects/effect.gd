extends Node

class_name Effect

var effect_name
var duration
var apply_momment : Moment
var image : CompressedTexture2D
var particle
var entity

var sound_fx : SoundFX

enum Moment{
	START_TURN,
	END_TURN,
	FIXED
}

func _init(
	_effect_name : String,
	_duration_turn: int,
	_apply_momment: Moment,
	_image : CompressedTexture2D,
	_partcile
	):
	self.effect_name = _effect_name
	self.duration = _duration_turn
	self.apply_momment = _apply_momment
	self.image = _image
	self.particle = _partcile

func _ready() -> void:
	sound_fx = get_node("/root/Base/Sound/SoundFX")

func apply_effect(_entity : Entity):
	pass

func expire(_enitity : Entity):
	pass
	
func get_moment_string():
	match apply_momment:
		Moment.START_TURN:
			return "Start Turn"
		Moment.END_TURN:
			return "End Turn" 
		Moment.FIXED:
			return "Fixed" 
			
func spawn_particle(pos : Vector2):
	var part = particle.instantiate()
	self.entity.add_child(part)
	part.global_position = pos
	part.emitting = true
	
