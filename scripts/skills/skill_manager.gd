extends Node

class_name SkillManager

var skills : Array[Skill]
var skill_owner : Entity

const SKILL_PATHS = [
	"res://scripts/skills/bleeding_skill.gd",
	"res://scripts/skills/poison_skill.gd",
	"res://scripts/skills/plague_skill.gd",
	"res://scripts/skills/provoke_skill.gd",
	"res://scripts/skills/berserk_skill.gd",
	"res://scripts/skills/attack_in_area_skill.gd",
	"res://scripts/skills/lightning_skill.gd",
	"res://scripts/skills/slow_skill.gd",
]

func _init(_skill_owner : Entity) -> void:
	skill_owner = _skill_owner
	skill_owner.attack_finished.connect(_on_attack_trigger)
	skill_owner.died.connect(_on_died_trigger)
	skill_owner.damaged.connect(_on_damage_trigger)
	skill_owner.spawned.connect(_on_spawned_trigger)
	name = "SkillManager"

func add(skill : Skill):
	skills.append(skill)
	add_child(skill)
			
func activate_skill(target: Entity, skill_type : Skill.Type):
	for skill : Skill in skills:
		if skill.type == skill_type:
			skill.activate(target)

func add_skill_name(skill_name : String):
	if skill_name != "":
		var script_path = get_skill_path_by_name(skill_name)
		
		var script = load(script_path)
		if script:
			var skill_instance = script.new(skill_owner)
			add(skill_instance)
		else:
			push_error("SKILL SCRIPT CANT LOAD")
		
func get_skill_path_by_name(_name: String) -> String:
	_name = _name.strip_edges().to_lower()
	for path in SKILL_PATHS:
		var file_name = path.get_file() # exemplo: poison_skill.gd
		if file_name.begins_with(_name + "_"):
			return path
	
	push_error("SKILL: ",_name," NAME NOT FOUND IN SKILL PATH")	
	return ""
	
func _on_attack_trigger(_attacker : Entity, _target : Entity):
	if _target:
		activate_skill(_target, Skill.Type.ATTACK)
	
func _on_died_trigger(_dead_entity : Entity, killed_by : Entity):
	if not _dead_entity.is_attacking:
		activate_skill(killed_by, Skill.Type.DEATH)
		
func _on_damage_trigger(_entity: Entity):
		activate_skill(skill_owner, Skill.Type.DAMAGE)
		
func _on_spawned_trigger(_entity: Entity):
		activate_skill(skill_owner, Skill.Type.SPAWN)
	
