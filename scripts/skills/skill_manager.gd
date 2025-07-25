extends Node

class_name SkillManager

var skills : Array[Skill]
var file_manager : FileManager

const SKILL_PATHS = [
	"res://scripts/skills/bleeding_skill.gd",
	"res://scripts/skills/poison_skill.gd"
]

func _init(_file_manager : FileManager) -> void:
	file_manager = _file_manager

func add(skill : Skill):
	skills.append(skill)
	
func activate_skill_attack(target : Entity):
	for skill : Skill in skills:
		if skill.type == Skill.Type.ATTACK:
			skill.activate(target)

func add_skill_name(skill_name : String):
	if skill_name != "":
		var script_path = get_skill_path_by_name(skill_name)
		
		var script = load(script_path)
		if script:
			var skill_instance = script.new()
			add(skill_instance)
			print("Instance: ", skill_instance.name)
		else:
			push_error("SKILL SCRIPT CANT LOAD")
		
func get_skill_path_by_name(name: String) -> String:
	name = name.strip_edges().to_lower()
	for path in SKILL_PATHS:
		var file_name = path.get_file() # exemplo: poison_skill.gd
		if file_name.begins_with(name + "_"):
			return path
	
	push_error("SKILL NAME NOT FOUND IN SKILL PATH")	
	return ""
	
