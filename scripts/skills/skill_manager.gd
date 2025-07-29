extends Node

class_name SkillManager

var skills : Array[Skill]
var skill_owner : Entity

const SKILL_PATHS = [
	"res://scripts/skills/bleeding_skill.gd",
	"res://scripts/skills/poison_skill.gd",
	"res://scripts/skills/plague_skill.gd",
	"res://scripts/skills/provoke_skill.gd",
]

func _init(_skill_owner : Entity) -> void:
	skill_owner = _skill_owner
	skill_owner.attack_finished.connect(_on_attack_trigger)
	skill_owner.died.connect(_on_died_trigger)

func add(skill : Skill):
	skills.append(skill)
			
func activate_skill(target: Entity, skill_type : Skill.Type):
	for skill : Skill in skills:
		if skill.type == skill_type:
			skill.activate(target)

func add_skill_name(skill_name : String):
	if skill_name != "":
		var script_path = get_skill_path_by_name(skill_name)
		
		var script = load(script_path)
		if script:
			var skill_instance = script.new()
			if skill_instance is ProvokeSkill:
				skill_instance.set_provoker(skill_owner)
			add(skill_instance)
			print("Instance: ", skill_instance.name)
		else:
			push_error("SKILL SCRIPT CANT LOAD")
		
func get_skill_path_by_name(_name: String) -> String:
	_name = _name.strip_edges().to_lower()
	for path in SKILL_PATHS:
		var file_name = path.get_file() # exemplo: poison_skill.gd
		if file_name.begins_with(_name + "_"):
			return path
	
	push_error("SKILL NAME NOT FOUND IN SKILL PATH")	
	return ""
	
func _on_attack_trigger(_attacker : Entity, _target : Entity):
	activate_skill(_target, Skill.Type.ATTACK)
	
func _on_died_trigger(_dead_entity : Entity, killed_by : Entity):
	if not _dead_entity.is_attacking:
		activate_skill(killed_by, Skill.Type.DEATH)
