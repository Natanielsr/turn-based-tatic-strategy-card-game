extends Skill

class_name ProvokeSkill

const PLAGUE_PARTICLE = preload("res://particles/plague_particle.tscn")
const CLOUD_BLACK_SMOKE = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_black_smoke.png")
var provoker : Entity

var target : Entity


func _init() -> void:
	super._init(
		"Provoke",
		"when this troop attacks an opponent it provokes him to attack only this troop",
		 CLOUD_BLACK_SMOKE,
		PLAGUE_PARTICLE,
		Type.ATTACK
		)
		
func set_provoker(_provoker : Entity):
	provoker = _provoker
	
func activate(_target : Entity):
	target = _target
	var old_effect = target.effects_manager.get_provoke_effect()
	if old_effect:
		target.effects_manager.remove_effect(old_effect)
	
	var effect = ProvokeEffect.new(provoker, target)
	target.effects_manager.add_effect(effect)
	spawn_particle(target.global_position)
	
