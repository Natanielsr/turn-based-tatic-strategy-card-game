extends Skill

class_name Plague

const PLAGUE_PARTICLE = preload("res://particles/plague_particle.tscn")
const CLOUD_BLACK_SMOKE = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_black_smoke.png")
const PLAGUE_3 = preload("res://sounds/plague3.ogg")

func _init(_skill_owner : Entity) -> void:
	super._init(
		"Plague",
		"When dies, causes a plague to the opponent who attacked him",
		 CLOUD_BLACK_SMOKE,
		PLAGUE_PARTICLE,
		Type.DEATH,
		_skill_owner
		)
	
func activate(_target : Entity):
	self.target = _target
	var effect = PlagueEffect.new()
	if target != null:
		sound_fx.play_temp_sound(PLAGUE_3, _target.position)
		self.target.effects_manager.add_effect(effect)
		spawn_particle(target.global_position)
	
