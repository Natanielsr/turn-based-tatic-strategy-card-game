extends Skill

class_name PoisonSkill

const POISON_PARTICLE = preload("res://particles/poison_particle.tscn")
const CLOUD_POISON_0 = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_poison0.png")

func _init(_skill_owner : Entity) -> void:
	super._init(
		"Poison",
		"Deal 1 Damage against opponent in the end of opponent turn",
		 CLOUD_POISON_0,
		POISON_PARTICLE,
		Type.ATTACK,
		_skill_owner
		)
	
func activate(_target : Entity):
	self.target = _target
	var effect = PoisonedEffect.new()
	self.target.effects_manager.add_effect(effect)
	spawn_particle(target.global_position)
	
