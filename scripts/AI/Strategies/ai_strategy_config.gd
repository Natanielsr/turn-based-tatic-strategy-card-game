class_name AIStrategyConfig

var enemy_ai : EnemyAI
var spawner: AISpawner
var game_controller: GameController
var ai_finder: AIFinder
var grid_controller: GridController
var troop_manager: TroopManager
var player_statue : PlayerStatue

func _init(
	_enemy_ai : EnemyAI,
	_spawner: AISpawner,
	_game_controller: GameController,
	_ai_finder: AIFinder,
	_grid_controller: GridController,
	_troop_manager: TroopManager,
	_player_statue : PlayerStatue
):
	enemy_ai = _enemy_ai
	spawner = _spawner
	game_controller = _game_controller
	ai_finder = _ai_finder
	grid_controller = _grid_controller
	troop_manager = _troop_manager 
	player_statue = _player_statue
