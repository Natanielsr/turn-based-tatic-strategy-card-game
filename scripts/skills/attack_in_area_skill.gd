extends Skill

class_name AttackInAreaSkill

const PLAGUE_PARTICLE = preload("res://particles/plague_particle.tscn")
const CLOUD_BLACK_SMOKE = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_black_smoke.png")

var grid_controller : GridController


func _init(_skill_owner : Entity) -> void:
	super._init(
		"Attack in Area",
		"when attacking it hits opponents near the target",
		 CLOUD_BLACK_SMOKE,
		PLAGUE_PARTICLE,
		Type.ATTACK,
		_skill_owner
		)
		
	self.skill_owner = _skill_owner
	name = "AttackInAreaSkill"
	
func _ready() -> void:
	grid_controller = get_node("/root/Base/Controllers/GridController")
	
func activate(_target : Entity):
	target = _target
	if _target is MobileTroop:
		var troop = _target as MobileTroop
		
		var radius: int = 1
		var center_tile_pos: Vector2i = troop.get_tile_pos()

		for x_offset in range(-radius, radius + 1):
			for y_offset in range(-radius, radius + 1):
				var test_pos = center_tile_pos + Vector2i(x_offset, y_offset)
				
				spawn_particle(grid_controller.get_tile_to_world_pos(test_pos))
				var test_target = grid_controller.get_entity_in_pos(test_pos)
				
				if not test_target:
					continue
					
				if test_target == target:
					continue
				
				if test_target.faction == skill_owner.faction:
					continue
				
				test_target.take_damage_with_attacker(skill_owner.attack_points, skill_owner)
				
