extends Skill

class_name BerserkSkill

const PLAGUE_PARTICLE = preload("res://particles/plague_particle.tscn")
const CLOUD_BLACK_SMOKE = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_black_smoke.png")


func _init(_skill_owner : Entity) -> void:
	super._init(
		"Berserk",
		"When troops receive damage, their attack increases",
		 CLOUD_BLACK_SMOKE,
		PLAGUE_PARTICLE,
		Type.DAMAGE,
		_skill_owner
		)
		
	
func activate(_target : Entity):
	target = _target
	
	remove_old_effect(target, BerserkEffect)
	
	var effect = BerserkEffect.new()
	target.effects_manager.add_effect(effect)
	
	#spawn_particle(target.global_position)
	
