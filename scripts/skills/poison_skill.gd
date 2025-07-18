extends Skill

class_name PoisonSkill

const POISON_PARTICLE = preload("res://particles/poison_particle.tscn")
const CLOUD_POISON_0 = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_poison0.png")
var target : Entity

func _init() -> void:
	super._init("Poison", "Deal 1 Damage in the end of turn", CLOUD_POISON_0)
	
func activate(_target : Entity):
	self.target = _target
	var effect = PoisonedEffect.new()
	self.target.effects_manager.add_effect(effect)
	spawn_poison_particle()
	

func spawn_poison_particle():
	var part = POISON_PARTICLE.instantiate()
	self.target.add_child(part)
	part.global_position = target.global_position
	part.emitting = true
