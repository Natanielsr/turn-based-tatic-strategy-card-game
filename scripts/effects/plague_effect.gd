extends Effect

class_name PlagueEffect

const CLOUD_BLACK_SMOKE = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_black_smoke.png")
const PLAGUE_PARTICLE = preload("res://particles/plague_particle.tscn")
const PLAGUE_3 = preload("res://sounds/plague3.ogg")

func _init() -> void:
	super._init("Plague", 3, Moment.START_TURN, CLOUD_BLACK_SMOKE, PLAGUE_PARTICLE)

func apply_effect(_entity : Entity):
	self.entity = _entity
	sound_fx.play_temp_sound_with_volume(PLAGUE_3, _entity.position, 0)
	self.entity.take_damage(1)
	spawn_particle(_entity.global_position)
