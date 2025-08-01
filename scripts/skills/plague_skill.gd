extends Skill

class_name Plague

const PLAGUE_PARTICLE = preload("res://particles/plague_particle.tscn")
const CLOUD_BLACK_SMOKE = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_black_smoke.png")
var target : Entity

func _init() -> void:
	super._init(
		"Plague",
		"When dies, causes a plague to the opponent who attacked him",
		 CLOUD_BLACK_SMOKE,
		PLAGUE_PARTICLE,
		Type.DEATH
		)
	
func activate(_target : Entity):
	self.target = _target
	var effect = PlagueEffect.new()
	self.target.effects_manager.add_effect(effect)
	spawn_particle(target.global_position)
	
