# AIStrategy.gd
class_name AIStrategy
extends Node

var spawner: AISpawner
var mover: TroopMover
var game_controller: GameController
var ai_finder: AIFinder
var grid_controller: GridController
var troop_manager: TroopManager

func init(config: AIStrategyConfig):
	spawner = config.spawner
	mover = config.mover
	game_controller = config.game_controller
	ai_finder = config.ai_finder
	grid_controller = config.grid_controller
	troop_manager = config.troop_manager

func play_turn():
	var subclass_name = get_subclass_name()
	push_error("Subclass '%s' must implement 'play_turn()'" % subclass_name)

func move_trop_pos(troop):
	var subclass_name = get_subclass_name()
	push_error("Subclass '%s' must implement 'move_trop_pos()'" % subclass_name)
	
func get_subclass_name() -> String:
	var script = get_script()
	if script:
		# Remove o caminho e extensão do arquivo
		return script.resource_path.get_file().get_basename()
	return ""
