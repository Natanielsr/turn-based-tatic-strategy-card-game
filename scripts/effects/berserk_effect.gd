extends Effect

class_name BerserkEffect

const CLOUD_BLACK_SMOKE = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_black_smoke.png")
const PLAGUE_PARTICLE = preload("res://particles/plague_particle.tscn")
const BERSERK = preload("res://sounds/berserk.ogg")

func _init() -> void:
	super._init("Berserk", 1, Moment.FIXED, CLOUD_BLACK_SMOKE, PLAGUE_PARTICLE)
	
func apply_effect(_entity : Entity):
	entity = _entity
	await get_tree().create_timer(0.5).timeout
	
	sound_fx.play_temp_sound_with_volume(BERSERK , _entity.position, -10)
	spawn_particle(entity.global_position)
	entity.attack_points += 3
	entity.update_atk_label()
	print("BerserkEffect > apply_effect: berserk aplied")
	
