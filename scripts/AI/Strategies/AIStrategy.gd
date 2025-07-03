# AIStrategy.gd
class_name AIStrategy
extends Node

var enemy_ai : EnemyAI
var spawner: AISpawner
var game_controller: GameController
var ai_finder: AIFinder
var grid_controller: GridController
var troop_manager: TroopManager
var player_statue : PlayerStatue

var troops_list = []
var current_index = 0
var current_troop : MobileTroop

func init(config: AIStrategyConfig):
	enemy_ai = config.enemy_ai
	spawner = config.spawner
	game_controller = config.game_controller
	ai_finder = config.ai_finder
	grid_controller = config.grid_controller
	troop_manager = config.troop_manager
	player_statue = config.player_statue

func play_turn():
	var subclass_name = get_subclass_name()
	push_error("Subclass '%s' must implement 'play_turn()'" % subclass_name)
	
func _turn_start():
	current_index = 0
	_update_troops_list()
	
func _update_troops_list():
	troops_list = troop_manager.enemy_troops.duplicate()
	
func _process_next_troop():
	if game_controller.current_game_state != GameController.GameState.RUNNING:
		return
	
	if current_index >= troops_list.size():
		end_turn()
		return

	current_troop = troops_list[current_index]
	current_troop.toggle_outline(true)
	await enemy_ai.wait(0.3)
	if not current_troop.is_connected("walk_finish", Callable(self, "_on_troop_move_finished")):
		current_troop.walk_finish.connect(_on_troop_move_finished)
	var pos = move_trop_pos(current_troop)
	if pos: #verify if have pos to go
		current_troop.move_troop(pos) # método da tropa que começa o movimento
	else: # if dont have finish the movement
		_on_troop_move_finished() #
	
func _finish_process():
	current_index += 1
	current_troop.toggle_outline(false)
	current_troop = null
	
	_process_next_troop()
	
	
func _on_troop_move_finished():
	
	current_troop.disconnect("walk_finish", Callable(self, "_on_troop_move_finished"))

	if not current_troop.is_connected("attack_finished", Callable(self, "_on_troop_attack_finished")):
		current_troop.connect("attack_finished", Callable(self, "_on_troop_attack_finished"))
		
	if ai_finder.in_attack_area_pos(current_troop):
		await enemy_ai.wait(0.3)
		current_troop.attack(player_statue)
		return

	var target = ai_finder.get_weakest_target_in_range(current_troop)
		
	if target:
		await enemy_ai.wait(0.3)
		current_troop.attack(target)
	else:
		_finish_process() # pula ataque se não houver alvo
		
func _on_troop_attack_finished():
	
	current_troop.disconnect("attack_finished", Callable(self, "_on_troop_attack_finished"))

	_finish_process()

func move_trop_pos(_troop):
	var subclass_name = get_subclass_name()
	push_error("Subclass '%s' must implement 'move_trop_pos()'" % subclass_name)
	
func end_turn():
	print("Turno da IA finalizado")
	enemy_ai.finish_turn()
	
func get_subclass_name() -> String:
	var script = get_script()
	if script:
		# Remove o caminho e extensão do arquivo
		return script.resource_path.get_file().get_basename()
	return ""
