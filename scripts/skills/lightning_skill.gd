extends TargetSkill

class_name LightningSkill

const PLAGUE_PARTICLE = preload("res://particles/plague_particle.tscn")
const CLOUD_BLACK_SMOKE = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_black_smoke.png")

func _init(_skill_owner : Entity) -> void:
	super._init(
		"Electric Lightning",
		"When invoked, launch an electrical beam at a target",
		 CLOUD_BLACK_SMOKE,
		PLAGUE_PARTICLE,
		Type.SPAWN,
		_skill_owner
		)
		
	self.skill_owner = _skill_owner
	name = "ElectricLightningSkill"
	
func execute(_target : Entity):
	_target.take_damage(skill_owner.attack_points / 2)
	var lightning = preload("res://prefabs/fx/lightning.tscn").instantiate()
	_target.add_child(lightning)
	lightning.global_position = Vector2.ZERO  # raiz da cena
	lightning.strike(_target.global_position)
	
