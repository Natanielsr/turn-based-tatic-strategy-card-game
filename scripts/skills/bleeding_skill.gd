extends Skill

class_name BleedingSkill

const BLEEDING_PARTICLE = preload("res://particles/blood_particle.tscn")
const BLOOD_RED_3 = preload("res://textures/crawl-tiles Oct-5-2010/dc-misc/blood_red3.png")

var target : Entity

func _init() -> void:
	super._init(
		"Bleeding",
		"Deal 2 Damage against opponent at the beginning of opponent turn",
		 BLOOD_RED_3,
		BLEEDING_PARTICLE,
		Type.ATTACK
		)
	
func activate(_target : Entity):
	self.target = _target
	var effect = BleedingEffect.new()
	self.target.effects_manager.add_effect(effect)
	spawn_particle(target.global_position)
	
