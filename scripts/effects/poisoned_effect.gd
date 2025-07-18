extends Effect

class_name PoisonedEffect

const POISON_PARTICLE = preload("res://particles/poison_particle.tscn")
const CLOUD_POISON_0 = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_poison0.png")

var entity : Entity

func _init() -> void:
	super._init("Poisoned", 3, Moment.END_TURN, CLOUD_POISON_0)

func apply_effect(_entity : Entity):
	self.entity = _entity
	self.entity.take_damage(1)
	spawn_poison_particle()
	print("%s lost 1 life by poison!" % entity.name)

func spawn_poison_particle():
	var part = POISON_PARTICLE.instantiate()
	self.entity.add_child(part)
	part.global_position = entity.global_position
	part.emitting = true
