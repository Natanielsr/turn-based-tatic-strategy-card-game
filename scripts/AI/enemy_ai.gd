extends Node2D

class_name EnemyAI

@onready var game_controller: GameController = $"../Controllers/GameController"
@onready var turn_controller: TurnController = $"../Controllers/TurnController"

@onready var card_manager: CardManager = $"../CardSystem/CardManager"
@onready var grid_controller: GridController = $"../Controllers/GridController"
@onready var troop_manager: TroopManager = $"../TroopManager"

var selected_card
var selected_monster : MobileTroop

enum AIType{
	AGRESSIVE, #Goes straight to the enemy hero
	DEFENSIVE, #Prioritize protecting the hero and controlling the center
	OPPORTUNIST, #Foca em matar unidades fracas e controlar área
	RANDOM #Play any card and move without logic
}
@export var type: AIType = AIType.AGRESSIVE

var strategy : AIStrategy


var move_count = 0

func _ready() -> void:
	turn_controller.connect("changed_turn", Callable(self, "_on_changed_turn"))
	
	match type:
		AIType.AGRESSIVE:
			strategy = preload("res://scripts/AI/Strategies/AgressiveStrategy.gd").new()
		AIType.DEFENSIVE:
			pass
		AIType.OPPORTUNIST:
			strategy = preload("res://scripts/AI/Strategies/OpportunistStrategy.gd").new()
		AIType.RANDOM:
			pass
			
	strategy.init(
				$AISpawner,
				$TroopMover,
				game_controller,
				$AIFinder,
				grid_controller,
				troop_manager
				)

func _on_changed_turn(turn: GameController.Turn):
	if turn == GameController.Turn.ENEMY:
		_on_enemy_turn()

func _on_enemy_turn():
	await strategy.play_turn()
		
func finish_turn():
	turn_controller.shift_turn()


func wait(seconds):
	await get_tree().create_timer(seconds).timeout 


func _on_timer_timeout() -> void:
	pass # Replace with function body.
