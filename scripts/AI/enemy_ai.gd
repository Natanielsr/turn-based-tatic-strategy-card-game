extends Node2D

class_name EnemyAI

@onready var game_controller: GameController = $"../Controllers/GameController"
@onready var turn_controller: TurnController = $"../Controllers/TurnController"

@onready var card_manager: CardManager = $"../CardSystem/CardManager"
@onready var grid_controller: GridController = $"../Controllers/GridController"
@onready var troop_manager: TroopManager = $"../TroopManager"
@onready var look_ahead: LookAhead = $LookAhead
@onready var enemy_hand: EnemyHand = $EnemyHand


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

var mover_troop : MobileTroop
var attacker_troop : MobileTroop
var best_move

func _ready() -> void:
	turn_controller.connect("changed_turn", Callable(self, "_on_changed_turn"))

func _on_changed_turn(turn: GameController.Turn):
	if turn == GameController.Turn.ENEMY:
		_on_enemy_turn()

func _on_enemy_turn():
	
	find_move()
	

func find_move():
	await wait(1)
	best_move = look_ahead.simulate_moves()
	if best_move:
		apply_move(best_move)
	else:
		print("No valid moves found")
		finish_turn() # No valid moves, end turn
		
func finish_turn():
	turn_controller.shift_turn()
	
func apply_move(move):
	match move["type"]:
		"play_card":
			selected_card = move["card"]
			var pos_to_spawn = grid_controller.get_tile_to_world_pos(move["tile"]) 
			if not troop_manager.is_connected("monster_spawned", Callable(self, "_on_monster_spawned")):
				troop_manager.monster_spawned.connect(_on_monster_spawned)
			troop_manager.spawn_monster(
				selected_card,
				pos_to_spawn,
				Entity.EntityFaction.ENEMY,
				move["monster_id"]
				)
				
		"move_troop":
			mover_troop = move["troop"]
			var pos_to_go = grid_controller.get_tile_to_world_pos(move["tile"]) 
			if not mover_troop.is_connected("walk_finish", Callable(self, "_on_troop_move_finished")):
				mover_troop.walk_finish.connect(_on_troop_move_finished)
			
			mover_troop.toggle_outline(true)
			mover_troop.move_troop(pos_to_go)
		"attack":
			attacker_troop = move["troop"]
			var target : Entity = move["target"]
			
			if not attacker_troop.is_connected("attack_finished", Callable(self, "_on_attack_finish")):
				attacker_troop.attack_finished.connect(_on_attack_finish)
			
			attacker_troop.toggle_outline(true)
			await wait(1)
			if target != null:
				attacker_troop.attack(target)
			else:
				find_move()

			
func _on_monster_spawned(monster : MobileTroop):
	if (monster.faction != Entity.EntityFaction.ENEMY):
		return
		
	if troop_manager.is_connected("monster_spawned", Callable(self, "_on_monster_spawned")):
		troop_manager.disconnect("monster_spawned", Callable(self, "_on_monster_spawned"))
	
	find_move()
		
func _on_troop_move_finished():
	if mover_troop.is_connected("walk_finish", Callable(self, "_on_troop_move_finished")):
		mover_troop.disconnect("walk_finish", Callable(self, "_on_troop_move_finished"))
	mover_troop.toggle_outline(false)
	mover_troop = null
	
	find_move()
		

func _on_attack_finish():
	if attacker_troop.is_connected("attack_finished", Callable(self, "_on_attack_finish")):
		attacker_troop.disconnect("attack_finished", Callable(self, "_on_attack_finish"))
		
	attacker_troop.toggle_outline(false)
	attacker_troop = null
	
	find_move()
	

func wait(seconds):
	await get_tree().create_timer(seconds).timeout 

func _on_timer_timeout() -> void:
	pass # Replace with function body.
