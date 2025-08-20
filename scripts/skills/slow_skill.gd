extends Skill

const CLOUD_PARTICLE = preload("res://particles/plague_particle.tscn")
const CLOUD_BLACK_SMOKE = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_black_smoke.png")


func _init(_skill_owner : Entity) -> void:
	super._init(
		"Slow",
		"Reduces walk points to 1",
		 CLOUD_BLACK_SMOKE,
		CLOUD_PARTICLE,
		Type.SPAWN,
		_skill_owner
		)

func activate(_target):
	var troop : MobileTroop = skill_owner as MobileTroop
	troop.set_total_walk_points(1)
