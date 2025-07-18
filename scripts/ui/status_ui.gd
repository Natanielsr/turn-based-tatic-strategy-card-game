extends Control

class_name StatusUI

const EFFECTS_PREVIEW_UI = preload("res://prefabs/effects_preview_ui.tscn")
const TROOP_PREVIEW_UI = preload("res://prefabs/troop_preview_ui.tscn")
const SKILLS_PREVIEW_UI = preload("res://prefabs/skills_preview_ui.tscn")

const EFFECTS_HEIGHT = 40
const SKILLS_HEIGHT = 76

const STATUS_WIDTH = 242

@onready var troop_manager: TroopManager = $"../../TroopManager"

@onready var point_a: Marker2D = $PointA
@onready var point_b: Marker2D = $PointB

@onready var window: Node2D = $Window

var troop_preview : Node
var effects_ui : Array[Node]
var skills_ui : Array[Node]
var troop : MobileTroop

var status_pos_top_left : Vector2

func _ready() -> void:
	troop_manager.mouse_on_troop.connect(_on_mouse_troop)
	troop_manager.mouse_left_troop.connect(_on_mouse_left_troop)

func _on_mouse_troop(_troop: MobileTroop):
	if self.troop != null and self.troop != _troop:
		clean_status()
	
	self.troop = _troop
	
	status_pos_top_left = Vector2(
			troop.global_position.x - 110,
			troop.global_position.y - 20
		)
	
	window.global_position = status_pos_top_left	
	
	show_troop_preview()
	show_troop_skills()
	show_troop_effects()
	
	position_status_in_screen()

	queue_redraw()
	
func position_status_in_screen():
	if window.global_position.y < point_a.global_position.y :
		window.global_position.y = point_a.global_position.y
		
	var status_pos_right = window.global_position.x + STATUS_WIDTH
	
	if status_pos_right > point_b.global_position.x:
		window.global_position.x = point_b.global_position.x - STATUS_WIDTH
	
func _on_mouse_left_troop(_troop):
	if self.troop == _troop:
		clean_status()
		
	queue_redraw()
			
func clean_status():
	if troop_preview != null:
		troop_preview.queue_free()
		troop_preview = null
		
	for effect in effects_ui.duplicate():
		effects_ui.erase(effect)
		effect.queue_free()
	
	for skill in skills_ui.duplicate():
		skills_ui.erase(skill)
		skill.queue_free()
		
	troop = null

func _draw(): 
	var view_color = Color(1, 0, 0, 0.5)  # vermelho com 50% de transparência
	
	var view_rect_area = rect_view_area()
	draw_rect(view_rect_area, view_color, false) 
	
	if troop == null:
		return

	var status_rect = status_area_rect()
	
	var border_color = Color(1, 0, 0, 0.5)  # vermelho com 50% de transparência
	draw_rect(status_rect, border_color, false)  # false = só a borda
	
func status_area_rect():
	var effects_height = effects_ui.size() * EFFECTS_HEIGHT
	var skills_height = (skills_ui.size() * SKILLS_HEIGHT) + EFFECTS_HEIGHT
	
	var heigth = 0
	if effects_height > skills_height:
		heigth = effects_height
	else:
		heigth = skills_height
	
	var _size = Vector2(STATUS_WIDTH, heigth)
	
	var rect = Rect2(status_pos_top_left, _size)  # posição e tamanho
	
	return rect

func is_rect_inside_screen(rect: Rect2) -> bool:
	var screen_rect = rect_view_area()
	return screen_rect.encloses(rect)
	
func rect_view_area():
	var top_left = point_a.global_position
	var _size = Vector2(
		abs(point_a.global_position.x - point_b.global_position.x),
		abs(point_a.global_position.y - point_b.global_position.y)
	)
	
	var rect = Rect2(top_left, _size)  # posição e tamanho
	
	return rect
	
func show_troop_effects():
	var effects : Array[Effect] = troop.effects_manager.effects
	
	for i in range(effects.size()):
		var effect = effects[i]
		
		var status_ui = EFFECTS_PREVIEW_UI.instantiate()
		status_ui.name = "effect_"+effect.effect_name+"_"+str(randi())
		status_ui.get_node("Name").text = effect.effect_name
		status_ui.get_node("Duration").text = str(effect.duration)
		status_ui.get_node("Moment").text = effect.get_moment_string()
		status_ui.get_node("Image").texture = effect.image
		
		var y_offset = -((i * EFFECTS_HEIGHT - 20))
		var pos_effect = Vector2(
			troop.global_position.x + 20,
			troop.global_position.y - y_offset
		)
		window.add_child(status_ui)
		status_ui.global_position = pos_effect
		
		effects_ui.append(status_ui)
		
func show_troop_skills():
	var skills : Array[Skill] = troop.skill_manager.skills
	
	for i in range(skills.size()):
		var skill : Skill = skills[i]
		
		var skill_ui = SKILLS_PREVIEW_UI.instantiate()
		skill_ui.name = "Skill_"+skill.skill_name+"_"+str(randi())
		skill_ui.get_node("Name").text = skill.skill_name
		skill_ui.get_node("Description").text = skill.description
		skill_ui.get_node("Image").texture = skill.image
		
		var y_offset = -((i * SKILLS_HEIGHT + 20))
		var pos_effect = Vector2(
			troop.global_position.x - 110,
			troop.global_position.y - y_offset
		)
		
		window.add_child(skill_ui)
		skill_ui.global_position = pos_effect
		skills_ui.append(skill_ui)
		

func show_troop_preview():
	if troop_preview == null:
		troop_preview = TROOP_PREVIEW_UI.instantiate()
		troop_preview.name = "Preview_"+troop.name+"_"+str(randi())
		troop_preview.get_node("Name").text = troop.card_id
		troop_preview.get_node("Image").texture = troop.get_node("Sprite2D").texture
		var pos_status = Vector2(
			troop.global_position.x - 110,
			troop.global_position.y - 20
		)
		window.add_child(troop_preview)
		troop_preview.global_position = pos_status
		
