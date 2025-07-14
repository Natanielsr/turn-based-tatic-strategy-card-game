extends Effect

class_name TestEffect

var entity_name : String

func _init(entity_name : String):
	self.entity_name = entity_name
	

func apply_effect(entity : Entity):
	print("effect aplied to ", entity.name)
