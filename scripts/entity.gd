extends Node2D

class_name Entity

const ALLY_OUTLINE = preload("res://materials/ally_outline.tres")
const ENEMY_OUTLINE = preload("res://materials/enemy_outline.tres")

@onready var game_controller: GameController = $"../../Controllers/GameController"
@onready var grid_controller: GridController = $"../../Controllers/GridController"
@onready var life_points_label: Label = $"./Status/LifePoints"
@onready var life_background_sprite: Sprite2D = $"./Status/LifeSprite"
@export var total_life_points : int = 2
var current_life_points : int


enum EntityFaction{
	ALLY,
	ENEMY
}
@export var faction: EntityFaction = EntityFaction.ALLY

func base_ready() -> void:
	_set_current_life(total_life_points)
	set_faction()
	game_controller.connect("changed_turn", Callable(self, "_on_changed_turn"))
	
func is_my_turn():
	var current_turn = game_controller.turn
	if faction == EntityFaction.ALLY and current_turn == GameController.Turn.PLAYER:
		return true
	elif faction == EntityFaction.ENEMY and current_turn == GameController.Turn.ENEMY:
		return true
	else:
		return false

func take_damage(damage: int):
	_set_current_life(current_life_points - damage)
	if current_life_points <= 0:
		die()
	
func die():
	push_error("Method 'die' must be overridden in a subclass to ",name)
	
func _set_current_life(life_points : int):
	current_life_points = life_points
	update_life_label()
	
func update_life_label():
	if life_points_label == null:
		push_error("Create a life label in the object to ",name)
	else:
		life_points_label.text = str(current_life_points)

func _input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("left_click"):
		game_controller.click_on_entity(self)
		print('click')
		
func toggle_outline(show_outline: bool):
	$Sprite2D.use_parent_material = not show_outline	
	
func set_faction():
	if faction == EntityFaction.ENEMY:
		$Sprite2D.material = ENEMY_OUTLINE
		life_background_sprite.modulate = Color(1, 0, 0)
		
			
			
	elif faction == EntityFaction.ALLY:
		$Sprite2D.material = ALLY_OUTLINE
		
func get_distance(pos : Vector2):
	var distance = grid_controller.get_distance(
		global_position,
		pos
	)
	
	return distance
		
