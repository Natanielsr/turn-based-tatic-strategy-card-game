extends Node

class_name Skill

var skill_name : String
var description : String
var image : Texture2D
var particle

enum Type{
	ATTACK,
	SPAWN,
	AREA
}
var type : Type

func _init(
	_skill_name : String,
	_description : String,
	_image : Texture2D,
	_particle
	) -> void:
		
	self.skill_name = _skill_name
	self.description = _description
	self.image = _image
	self.particle = _particle
	
	

func activate(_target : Entity):
	pass
	
func spawn_particle(pos : Vector2):
	var part = particle.instantiate()
	self.target.add_child(part)
	part.global_position = pos
	part.emitting = true
