extends Effect

class_name PoisonedEffect

const POISON_PARTICLE = preload("res://particles/poison_particle.tscn")
var entity : Entity

func _init() -> void:
	super._init("Poisoned", 3, Moment.END_TURN)

func apply_effect(entity : Entity):
	self.entity = entity
	self.entity.take_damage(1)
	spawn_poison_particle()
	print("%s lost 1 life by poison!" % entity.name)

func spawn_poison_particle():
	var part = POISON_PARTICLE.instantiate()
	self.entity.add_child(part)
	part.global_position = entity.global_position
	part.emitting = true
