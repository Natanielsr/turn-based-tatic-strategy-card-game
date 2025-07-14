extends Node

class_name SkillManager

var skills : Array[Skill]

func add(skill : Skill):
	skills.append(skill)
	
func activate_skill_attack(target : Entity):
	for skill : Skill in skills:
		if skill.type == Skill.Type.ATTACK:
			skill.activate(target)
