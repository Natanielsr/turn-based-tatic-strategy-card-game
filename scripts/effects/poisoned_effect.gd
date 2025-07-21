extends Effect

class_name PoisonedEffect

const POISON_PARTICLE = preload("res://particles/poison_particle.tscn")
const CLOUD_POISON_0 = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_poison0.png")

var entity : Entity

func _init() -> void:
	super._init("Poisoned", 3, Moment.END_TURN, CLOUD_POISON_0, POISON_PARTICLE)

func apply_effect(_entity : Entity):
	self.entity = _entity
	self.entity.take_damage(1)
	spawn_particle(_entity.global_position)
	print("%s lost 1 life by poison!" % entity.name)
