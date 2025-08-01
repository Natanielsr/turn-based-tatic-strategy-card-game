extends Effect

class_name BerserkEffect

const CLOUD_BLACK_SMOKE = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_black_smoke.png")
const PLAGUE_PARTICLE = preload("res://particles/plague_particle.tscn")

func _init() -> void:
	super._init("Berserk by ", 3, Moment.FIXED, CLOUD_BLACK_SMOKE, PLAGUE_PARTICLE)
	
func apply_effect(_entity : Entity):
	self.entity = _entity
	spawn_particle(_entity.global_position)
	print("BerserkEffect > apply_effect: berserk aplied")
	
	
