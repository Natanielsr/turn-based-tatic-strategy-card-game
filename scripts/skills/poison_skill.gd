extends Skill

class_name PoisonSkill

const POISON_PARTICLE = preload("res://particles/poison_particle.tscn")

var target : Entity

func _init() -> void:
	pass
	
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
