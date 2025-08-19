extends Node2D

class_name GameController

signal on_select_tropp(troop: MobileTroop)
signal on_deselect_troop(troop : MobileTroop)

signal game_over(victory: bool)

var selected_troop : MobileTroop
var target: Entity

@onready var grid_controller: GridController = $"../GridController"
@onready var player_statue: PlayerStatue = $"../../Statues/PlayerStatue"
@onready var enemy_statue: EnemyStatue = $"../../Statues/EnemyStatue"
@onready var turn_controller: TurnController = $"../TurnController"
const Turn = TurnController.Turn

const card_database = preload("res://scripts/card_system/card_database.gd")

var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array

var possible_path

enum GameState{
	CHOOSE_START_CARDS,
	RUNNING,
	GAME_OVER,
	PLAYER_WIN,
	LOOKING_FOR_TARGET
	
}
var current_game_state = GameState.RUNNING

var target_skill : TargetSkill
 
func _ready() -> void:
	player_statue.player_lost_the_game.connect(_game_over)
	enemy_statue.enemy_die.connect(_win_game)
	current_game_state = GameState.CHOOSE_START_CARDS
	
func change_game_state(game_state : GameState):
	current_game_state = game_state
	
func change_to_target_waiting(_target_skill: TargetSkill):
	current_game_state = GameState.LOOKING_FOR_TARGET
	target_skill = _target_skill
	
func is_looking_for_target_state():
	if current_game_state == GameState.LOOKING_FOR_TARGET:
		return true
	else:
		return false
		
func is_choose_card_state():
	if current_game_state == GameState.CHOOSE_START_CARDS:
		return true
	else:
		return false
	
func is_running_state() -> bool:
	if current_game_state == GameState.RUNNING:
		return true
	else:
		return false

func _game_over():
	current_game_state = GameState.GAME_OVER
	emit_signal("game_over", false)
	
func _win_game():
	current_game_state = GameState.PLAYER_WIN
	emit_signal("game_over", true)
	
func click_on_entity(entity : Entity):
	if turn_controller.turn == Turn.ENEMY:
		return

	match entity.faction:
		Entity.EntityFaction.ALLY:
			select_a_troop(entity)
		Entity.EntityFaction.ENEMY:
			mark_target(entity)
		
func mark_target(enemy : Entity):
	
	if current_game_state == GameState.LOOKING_FOR_TARGET:
		if target_skill.skill_owner.is_player_faction():
			target_skill.target_entity(enemy)
		
	elif is_running_state():
		try_to_attack(enemy)
		
func try_to_attack(enemy):
	if target:
		deselect_target()

	target = enemy
	target.toggle_outline(true)
	
	if selected_troop:
		selected_troop.attack(target)

func select_a_troop(troop : Entity):
	
	if not is_running_state():
		return
		
	if not troop is MobileTroop:
		return
		
	if selected_troop and selected_troop.is_moving:
		return
		
	deselect_troop()
	selected_troop = troop
	
	emit_signal("on_select_tropp", selected_troop)
	
	#show_action_buttons(true)
	selected_troop.toggle_outline(true)
			
func deselect_troop():
	if selected_troop != null:
		selected_troop.toggle_outline(false)
		
		emit_signal("on_deselect_troop", selected_troop)
		
		selected_troop = null
	
func current_troop_state():
	if selected_troop != null:
		return selected_troop.get_current_state()
		
func has_troop_moving():
	if selected_troop == null:
		return false
		
	return selected_troop.is_moving
	
func deselect_target():
	if not target:
		return
		
	target.toggle_outline(false)
	target = null
	
func wait(seconds):
	await get_tree().create_timer(seconds).timeout 
	
	
