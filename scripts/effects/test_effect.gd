extends Effect

class_name TestEffect

var entity_name : String

func _init(_entity_name : String):
	self.entity_name = _entity_name
	

func apply_effect(entity : Entity):
	print("Effect > apply_effect: effect aplied to ", entity.name)
