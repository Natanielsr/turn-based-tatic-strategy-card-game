extends Effect

class_name PoisonedEffect

const POISON_PARTICLE = preload("res://particles/poison_particle.tscn")
const CLOUD_POISON_0 = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_poison0.png")
const SWALLOW_04 = preload("res://sounds/swallow-04.ogg")


func _init() -> void:
	super._init("Poisoned", 3, Moment.END_TURN, CLOUD_POISON_0, POISON_PARTICLE)

func apply_effect(_entity : Entity):
	self.entity = _entity
	self.entity.take_damage(1)
	spawn_particle(_entity.global_position)
	sound_fx.play_temp_sound(SWALLOW_04, _entity.position)
	print("PoisonedEffect > apply_effect %s lost 1 life by poison!" % entity.name)
