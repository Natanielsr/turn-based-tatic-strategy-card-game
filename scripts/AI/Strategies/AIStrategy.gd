# AIStrategy.gd
class_name AIStrategy
extends Node

var spawner
var mover
var game_controller
var ai_finder : AIFinder
var grid_controller : GridController
var troop_manager: TroopManager

func init(_spawner, _mover, _game_controller, _ai_finder, _grid_controller, _troop_manager):
	spawner = _spawner
	mover = _mover
	game_controller = _game_controller
	ai_finder = _ai_finder
	grid_controller = _grid_controller
	troop_manager = _troop_manager

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
