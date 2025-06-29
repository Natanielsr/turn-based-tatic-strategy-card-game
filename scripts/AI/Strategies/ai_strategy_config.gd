class_name AIStrategyConfig

var spawner: AISpawner
var mover: TroopMover
var game_controller: GameController
var ai_finder: AIFinder
var grid_controller: GridController
var troop_manager: TroopManager

func _init(
	_spawner: AISpawner,
	_mover: TroopMover,
	_game_controller: GameController,
	_ai_finder: AIFinder,
	_grid_controller: GridController,
	_troop_manager: TroopManager
):
	spawner = _spawner
	mover = _mover
	game_controller = _game_controller
	ai_finder = _ai_finder
	grid_controller = _grid_controller
	troop_manager = _troop_manager 