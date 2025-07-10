# test/test_score_calculator.gd
extends "res://addons/gut/test.gd"

var ScoreCalculator = preload("res://scripts/AI/score_calculator.gd")
var LookAhead = preload("res://scripts/AI/lookahead.gd")

class MockTroop:
	var pos
	var current_life_points
	var faction
	func _init(_pos):
		pos = _pos
	func get_tile_pos():
		return pos

# Testa score_alive_troops: só conta tropas vivas
func test_score_alive_troops():
	var score_calculator = ScoreCalculator.new()
	var game_state = {
		"enemy_troops": [
			{"hp": 5}, {"hp": 0}
		],
		"player_troops": [
			{"hp": 3}, {"hp": 0}
		]
	}
	var score = score_calculator.score_alive_troops(game_state)
	assert_eq(score, 0, "Deve contar apenas tropas vivas (1-1)*10 = 0")

# Testa score_total_life: soma vida das tropas
func test_score_total_life():
	var score_calculator = ScoreCalculator.new()
	var game_state = {
		"enemy_troops": [
			{"hp": 5}, {"hp": 2}
		],
		"player_troops": [
			{"hp": 3}, {"hp": 1}
		]
	}
	var score = score_calculator.score_total_life(game_state)
	assert_eq(score, 3, "Deve somar vida total (5+2)-(3+1)=3")


			
# Testa score_attack_result: bônus se matar e sobreviver, punição se morrer e não matar
func test_score_attack_result():
	var score_calculator = ScoreCalculator.new()

	var move = {
		"type": "attack",
		"troop": MockTroop.new(Vector2i(1,1)),
		"target": MockTroop.new(Vector2i(2,2))
	}
	var game_state = {
		"enemy_troops": [{"pos": Vector2i(1,1), "hp": 2}],
		"player_troops": [{"pos": Vector2i(2,2), "hp": 0}]
	}
	var score = score_calculator.score_attack_result(game_state, move)
	assert_true(score > 0, "Deve dar bônus se matar e sobreviver")

	game_state = {
		"enemy_troops": [{"pos": Vector2i(1,1), "hp": 0}],
		"player_troops": [{"pos": Vector2i(2,2), "hp": 2}]
	}
	score = score_calculator.score_attack_result(game_state, move)
	assert_true(score < 0, "Deve punir se morrer e não matar")
	
	game_state = {
		"enemy_troops": [{"pos": Vector2i(1,1), "hp": 0}],
		"player_troops": [{"pos": Vector2i(2,2), "hp": 0}]
	}
	score = score_calculator.score_attack_result(game_state, move)
	assert_true(score == 0, "Neutro")

# Testa score_area_control: tropas próximas da estátua do player aumentam score
func test_score_area_control():
	var score_calculator = ScoreCalculator.new()
	var game_state = {
		"enemy_troops": [{"pos": Vector2i(1,1)}],
		"player_statue": {"attack_positions": [Vector2i(2,2)]}
	}
	var score = score_calculator.score_area_control(game_state)
	assert_true(score > 0, "Deve valorizar tropas próximas da estátua do player")

# Testa score_statue_damage: dano na estátua do player aumenta score, dano na própria diminui
func test_score_statue_damage():
	var score_calculator = ScoreCalculator.new()
	#var look_ahead = LookAhead.new()
	
	#look_ahead.player_statue = PlayerStatue.new()
	#look_ahead.player_statue.current_life_points = 10
	#look_ahead.enemy_statue = EnemyStatue.new()
	#look_ahead.enemy_statue.current_life_points = 10
	
	var game_state = {
		"player_statue": {"hp": 8, "initial_hp" : 10},
		"enemy_statue": {"hp": 10, "initial_hp" : 10}
	}
	var score = score_calculator.score_statue_damage(game_state)
	assert_true(score > 0, "Deve valorizar dano na estátua do player")

	game_state = {
		"player_statue": {"hp": 10, "initial_hp" : 10},
		"enemy_statue": {"hp": 8, "initial_hp" : 10}
	}
	score = score_calculator.score_statue_damage(game_state)
	assert_true(score < 0, "Deve punir dano na própria estátua")

# Testa score_victory_defeat: vitória e derrota
func test_score_victory_defeat():
	var score_calculator = ScoreCalculator.new()
	var game_state = {
		"player_statue": {"hp": 0},
		"enemy_statue": {"hp": 10}
	}
	var score = score_calculator.score_victory_defeat(game_state)
	assert_true(score > 0, "Deve dar score alto para vitória")

	game_state = {
		"player_statue": {"hp": 10},
		"enemy_statue": {"hp": 0}
	}
	score = score_calculator.score_victory_defeat(game_state)
	assert_true(score < 0, "Deve punir derrota")

# Testa score_hunt_weaker_targets: aproximação de tropas fortes a fracas
func test_score_hunt_weaker_targets():
	var score_calculator = ScoreCalculator.new()
	var game_state = {
		"enemy_troops": [{"pos": Vector2i(1,1), "hp": 5, "attack_points": 6}],
		"player_troops": [{"pos": Vector2i(2,2), "hp": 4}]
	}
	var score = score_calculator.score_hunt_weaker_targets(game_state)
	assert_true(score > 0, "Deve valorizar aproximação de tropas fortes a fracas")

class MockTileGrid extends Node:
	func get_used_rect():
		return Rect2(0, 0, 10, 10)

# Testa score_approach_invader: aproximação de inimigos a invasores
func test_score_approach_invader():
	var score_calculator = ScoreCalculator.new()
	#score_calculator.grid_controller = GridController.new()
	#score_calculator.grid_controller.tile_grid = MockTileGrid.new()
	var game_state = {
		"enemy_troops": [{"pos": Vector2i(8,5), "hp": 5}],
		"player_troops": [{"pos": Vector2i(7,5), "hp": 5}]
	}
	var score = score_calculator.score_approach_invader(game_state)
	assert_true(score > 0, "Deve retornar um score positivo")
	
# Testa score_approach_invader: aproximação de inimigos a invasores
func test_score_distanced_invader():
	var score_calculator = ScoreCalculator.new()
	#score_calculator.grid_controller = GridController.new()
	#score_calculator.grid_controller.tile_grid = MockTileGrid.new()
	var game_state = {
		"enemy_troops": [{"pos": Vector2i(16,5), "hp": 5}],
		"player_troops": [{"pos": Vector2i(7,5), "hp": 5}]
	}
	var score = score_calculator.score_approach_invader(game_state)
	assert_true(score < 0, "Deve retornar um score negativo")

# Testa score_attack_invader: atacar invasor
func test_score_attack_invader():
	var score_calculator = ScoreCalculator.new()
	#score_calculator.grid_controller = GridController.new()
	#score_calculator.grid_controller.tile_grid = MockTileGrid.new()
	var move = {
		"type": "attack",
		"troop": MockTroop.new(Vector2i(1, 1)),
		"target": MockTroop.new(Vector2i(7, 5))
	}
	var game_state = {
		"player_troops": [{"pos": Vector2i(7,5), "hp": 5}],
	}
	var score = score_calculator.score_attack_invader(move)
	assert_true(typeof(score) == TYPE_INT, "Deve retornar um score inteiro")
	
# test/unit/test_score_calculator.gd

# test/unit/test_score_calculator.gd

func test_score_escape_weak_from_strong():
	# Mock do score_calculator
	var score_calculator = ScoreCalculator.new()

	# Mock de movimento: tropa fraca do player se move de (1,1) para (5,5)
	var mock_troop = MockTroop.new(Vector2i(1,1))
	mock_troop.current_life_points = 2
	
	var move = {
		"type": "move_troop",
		"troop": mock_troop,
		"tile": Vector2i(5, 5)
	}
	
	# Estado do jogo: tropa inimiga forte em (2,2)
	var game_state = {
		"enemy_troops": [
			{"pos": Vector2i(2, 2), "hp": 10, "attack_points": 5}
		]
	}

	var score = score_calculator.score_escape_weak_from_strong(game_state, move)
	assert_true(score > 0, "Score deve ser positivo quando tropa fraca se afasta de inimigo forte")

	# Agora teste punição: mover para mais perto
	move["tile"] = Vector2i(1, 2)
	score = score_calculator.score_escape_weak_from_strong(game_state, move)
	assert_true(score < 0, "Score deve ser negativo quando tropa fraca se aproxima de inimigo forte")

# test/unit/test_score_calculator.gd

# Testa score_approach_enemy_defense_statue: valoriza aproximação de inimigos a player na área da estátua
func test_score_approach_enemy_defense_statue():
	var score_calculator = ScoreCalculator.new()
	var game_state = {
		"enemy_statue": {
			"attack_positions": [Vector2i(3, 3), Vector2i(4, 4)]
		},
		"player_troops": [
			{"pos": Vector2i(3, 3), "hp": 5}, # está na área de ataque
			{"pos": Vector2i(1, 1), "hp": 5}  # fora da área
		],
		"enemy_troops": [
			{"pos": Vector2i(2, 3), "hp": 5},
			{"pos": Vector2i(10, 10), "hp": 5}
		]
	}
	var score = score_calculator.score_approach_enemy_defense_statue(game_state)
	assert_true(score > 0, "Score deve ser positivo quando inimigos se aproximam de player na área da estátua")

# Testa score_kill_enemy_defense_statue: valoriza matar inimigo na área da estátua
func test_score_kill_enemy_defense_statue():
	var score_calculator = ScoreCalculator.new()
	# Mock para get_tile_pos
	var mock_target= MockTroop.new(Vector2i(3,3))
	mock_target.current_life_points = 0 # morto

	var move = {
		"type": "attack",
		"target": mock_target
	}
	var game_state = {
		"enemy_statue": {
			"attack_positions": [Vector2i(3, 3), Vector2i(4, 4)]
		},
		"player_troops": [
			{"pos": Vector2i(3, 3), "hp": 0}
		]
	}
	var score = score_calculator.score_kill_enemy_defense_statue(game_state, move)
	assert_true(score > 0, "Score deve ser positivo ao matar inimigo na área da estátua")

	mock_target.pos = Vector2i(1, 1) # Mock para fora da área

	# Testa que não valoriza se não estiver na área
	move["target"] = mock_target

	game_state["player_troops"][0] = move["target"]
	score = score_calculator.score_kill_enemy_defense_statue(game_state, move)
	assert_eq(score, 0, "Score deve ser zero se matar inimigo fora da área da estátua")
