extends Skill

class_name ProvokeSkill

const PLAGUE_PARTICLE = preload("res://particles/plague_particle.tscn")
const CLOUD_BLACK_SMOKE = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_black_smoke.png")
var provoker : Entity

func _init(_skill_owner : Entity) -> void:
	super._init(
		"Provoke",
		"when this troop attacks an opponent it provokes him to attack only this troop",
		 CLOUD_BLACK_SMOKE,
		PLAGUE_PARTICLE,
		Type.ATTACK,
		_skill_owner
		)
	
func activate(_target : Entity):
	target = _target
	
	remove_old_effect(target, ProvokeEffect)
	
	var effect = ProvokeEffect.new(skill_owner, target)
	target.effects_manager.add_effect(effect)
	spawn_particle(target.global_position)
	
