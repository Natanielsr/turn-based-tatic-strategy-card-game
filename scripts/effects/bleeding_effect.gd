extends Effect

class_name BleedingEffect

const BLEEDING_PARTICLE = preload("res://particles/blood_particle.tscn")
const BLOOD_RED_3 = preload("res://textures/crawl-tiles Oct-5-2010/dc-misc/blood_red3.png")

var entity : Entity

func _init() -> void:
	super._init("Bleeding", 1, Moment.START_TURN, BLOOD_RED_3, BLEEDING_PARTICLE)

func apply_effect(_entity : Entity):
	self.entity = _entity
	self.entity.take_damage(2) #DAMAGE
	spawn_particle(_entity.global_position)
	print("BleedingEffect > apply_effect: %s lost 2 life by bleeding!" % entity.name)
