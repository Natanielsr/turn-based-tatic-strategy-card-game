extends Node

class_name SkillManager

var skills : Array[Skill]
var file_manager : FileManager

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
		var script_path = file_manager.get_skill_script_path(skill_name)
		var script = load(script_path)
		if script:
			var skill_instance = script.new()
			add(skill_instance)
			print("Instance: ", skill_instance.name)
		else:
			push_error("SKILL SCRIPT CANT LOAD")
		
