extends Effect

class_name PlagueEffect

const CLOUD_BLACK_SMOKE = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_black_smoke.png")
const PLAGUE_PARTICLE = preload("res://particles/plague_particle.tscn")

func _init() -> void:
	super._init("Plague", 3, Moment.START_TURN, CLOUD_BLACK_SMOKE, PLAGUE_PARTICLE)

func apply_effect(_entity : Entity):
	self.entity = _entity
	self.entity.take_damage(1)
	spawn_particle(_entity.global_position)
	print("PlagueEffect > apply_effect: %s lost 1 life by plague!" % entity.name)
