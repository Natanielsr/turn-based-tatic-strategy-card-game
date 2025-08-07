extends Node2D

class_name Entity

signal died(entity_died : Entity, killed_by : Entity)
signal attack_finished(attacker: Entity, target: Entity)
signal damaged(entity: Entity)

const ALLY_OUTLINE = preload("res://materials/ally_outline.tres")
const ENEMY_OUTLINE = preload("res://materials/enemy_outline.tres")

@onready var game_controller: GameController = get_node("/root/Base/Controllers/GameController")
@onready var turn_controller: TurnController = get_node("/root/Base/Controllers/TurnController")
const Turn = TurnController.Turn

@onready var grid_controller: GridController = $"../../Controllers/GridController"
@onready var life_points_label: Label = $"./Status/LifePoints"
@onready var life_background_sprite: Sprite2D = $"./Status/LifeSprite"
@export var original_life_points : int
var current_life_points : int
var is_attacking = false

enum EntityFaction{
	NONE,
	ALLY,
	ENEMY
}
@export var faction: EntityFaction = EntityFaction.ALLY

var effects_manager : EffectsManager
var skill_manager : SkillManager

func _init() -> void:
	skill_manager = SkillManager.new(self)
	add_child(skill_manager)
	effects_manager = EffectsManager.new(self)
	add_child(effects_manager)

func base_ready() -> void:
	_set_current_life(original_life_points)
	define_faction_color()
	turn_controller.connect("changed_turn", Callable(self, "_on_base_changed_turn"))
	effects_manager.set_turn_controller(turn_controller)
	
func _on_base_changed_turn(_turn):	
	_on_changed_turn(_turn)
	
func _on_changed_turn(_turn):
	pass
	
func is_entity_turn():
	var current_turn = turn_controller.turn
	if faction == EntityFaction.ALLY and current_turn == Turn.PLAYER:
		return true
	elif faction == EntityFaction.ENEMY and current_turn == Turn.ENEMY:
		return true
	else:
		return false
		
func set_total_life(life : int):
	original_life_points = life
	
func take_damage(damage: int):
	take_damage_with_attacker(damage, null)

func take_damage_with_attacker(damage: int, attacker : Entity):
	
	_set_current_life(current_life_points - damage)
	if current_life_points <= 0:
		die(attacker)
	else:
		damage_effect()
		
	emit_signal("damaged", self)
		
func is_alive():
	if current_life_points > 0:
		return true
	else:
		return false
		
func damage_effect():
	var tween = create_tween()
	$Sprite2D.modulate = Color.RED
	tween.tween_property($Sprite2D, "modulate", Color.WHITE, 1)
	
func die(killed_by : Entity):
	emit_signal("died", self, killed_by)
	push_error("Method 'die' must be overridden in a subclass to ",name)
	
func _set_current_life(life_points : int):
	if life_points > original_life_points:
		current_life_points = original_life_points
	else:
		current_life_points = life_points
		
	update_life_label()
	
func update_life_label():
	if life_points_label == null:
		push_error("Create a life label in the object to ",name)
	else:
		life_points_label.text = str(current_life_points)
		if current_life_points > original_life_points:
			life_points_label.modulate = Color.GREEN
		elif current_life_points < original_life_points:
			life_points_label.modulate = Color.RED
		else:
			life_points_label.modulate = Color.WHITE
		
func toggle_outline(_show_outline: bool):
	if has_node("SelectSprite"):
		$SelectSprite.texture = $Sprite2D.texture
		$SelectSprite.visible = _show_outline	
	
func define_faction_color():
	if faction == EntityFaction.ENEMY:
		#$Sprite2D.material = ENEMY_OUTLINE
		life_background_sprite.modulate = Color(1, 0, 0)
	elif faction == EntityFaction.ALLY:
		#$Sprite2D.material = ALLY_OUTLINE
		pass
		
func get_distance(pos : Vector2) -> int:
	var distance = grid_controller.get_distance(
		global_position,
		pos
	)
	
	return distance
		
func set_faction(fct):
	faction = fct
	
func attack(entity : Entity):
	is_attacking = true
	emit_signal("attack_finished", self, entity)
