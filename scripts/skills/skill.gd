extends Node

class_name Skill

var skill_name : String
var description : String
var image : Texture2D

enum Type{
	ATTACK,
	SPAWN,
	AREA
}
var type : Type

func _init(_skill_name : String, _description : String, _image : Texture2D) -> void:
	self.skill_name = _skill_name
	self.description = _description
	self.image = _image
	

func activate(_target : Entity):
	pass
