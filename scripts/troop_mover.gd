extends Node
class_name TroopMover

@onready var troop_manager = $"../../TroopManager"
@onready var grid_controller = $"../../Controllers/GridController"
@onready var enemy_ai: EnemyAI = $".."
@onready var ai_finder: AIFinder = $"../AIFinder"

var selected_monster : MobileTroop
var current_index = 0

func move_all():
	current_index = 0
	await wait(1)
	await move_next()
	
func wait(seconds):
	await get_tree().create_timer(seconds).timeout 

func move_next():
	var n_troops = troop_manager.enemy_troops.size()
	if current_index >= n_troops:
		$"../../Controllers/TurnController".shift_turn()
		return

	selected_monster = troop_manager.enemy_troops[current_index]
	var pos = find_pos_for(selected_monster)

	if pos and grid_controller.is_walkable_position(pos):
		if not selected_monster.arrived_signal.is_connected(_on_arrived.bind(selected_monster)):
			selected_monster.arrived_signal.connect(_on_arrived.bind(selected_monster))
		selected_monster.move_troop(pos)
	else:
		current_index += 1
		await move_next()

func _on_arrived(_troop):
	current_index += 1
	await move_next()

func find_pos_for(_troop):
	var objective_pos = enemy_ai.strategy.move_trop_pos(selected_monster)
	
	if objective_pos:
		return ai_finder.find_nearest_reachable_position(selected_monster, objective_pos)
	else:
		return null
