extends Effect

class_name BerserkEffect

const CLOUD_BLACK_SMOKE = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_black_smoke.png")
const PLAGUE_PARTICLE = preload("res://particles/plague_particle.tscn")

func _init() -> void:
	super._init("Berserk", 1, Moment.FIXED, CLOUD_BLACK_SMOKE, PLAGUE_PARTICLE)
	
func apply_effect(_entity : Entity):
	entity = _entity
	await get_tree().create_timer(1.0).timeout
	spawn_particle(entity.global_position)
	entity.attack_points += 3
	entity.update_atk_label()
	print("BerserkEffect > apply_effect: berserk aplied")
	
