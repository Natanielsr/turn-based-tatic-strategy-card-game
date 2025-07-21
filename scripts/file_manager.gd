extends Node

class_name FileManager

const SKILLS_FOLDER := "res://scripts/skills/"
var _dir : DirAccess

func _ready() -> void:
	pass

func get_dir() -> DirAccess:
	if _dir:
		return _dir
	else:
		return DirAccess.open(SKILLS_FOLDER)
		
func get_skill_script_path(skill_name: String) -> String:
	var dir = get_dir()
	if not dir:
		push_error("CANT OPEN THE FOLDER: ",SKILLS_FOLDER)
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			file_name = dir.get_next()
			continue
			
		if not file_name.ends_with("_skill.gd"):
			file_name = dir.get_next()
			continue
			
		if not file_name.begins_with(skill_name):
			file_name = dir.get_next()
			continue
			
		dir.list_dir_end()
		
		var script_path = SKILLS_FOLDER + file_name
		return script_path
	
	dir.list_dir_end()
	push_error("SKILL SCRIPT NOT FOUND")
	return ""
