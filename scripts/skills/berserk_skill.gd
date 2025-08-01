extends Skill

class_name BerserkSkill

const PLAGUE_PARTICLE = preload("res://particles/plague_particle.tscn")
const CLOUD_BLACK_SMOKE = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_black_smoke.png")
var provoker : Entity

var target : Entity

func _init() -> void:
	super._init(
		"Berserk",
		"When troops receive damage, their attack increases",
		 CLOUD_BLACK_SMOKE,
		PLAGUE_PARTICLE,
		Type.DAMAGE
		)
		
func set_provoker(_provoker : Entity):
	provoker = _provoker
	
func activate(_target : Entity):
	target = _target
	
	remove_old_effect(target, BerserkEffect)
	
	var effect = BerserkEffect.new(provoker, target)
	target.effects_manager.add_effect(effect)
	
	spawn_particle(target.global_position)
	
