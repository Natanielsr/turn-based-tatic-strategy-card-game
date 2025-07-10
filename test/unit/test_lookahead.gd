extends GutTest

var lookahead_scene = preload("res://scripts/AI/lookahead.gd")
var lookahead: LookAhead

# Chamado antes de cada teste
func before_each():
	lookahead = lookahead_scene.new()
	add_child_autofree(lookahead)
	
# Chamado depois de cada teste
func after_each():
	pass

# Testes para clone_game_state
func test_clone_game_state():
	var original_state = create_mock_game_state()
	var cloned_state = lookahead.clone_game_state()
	
	assert_not_null(cloned_state, "Estado clonado não deve ser nulo")
	assert_has(cloned_state, "enemy_hand", "Estado clonado deve ter enemy_hand")
	assert_has(cloned_state, "enemy_troops", "Estado clonado deve ter enemy_troops")
	assert_has(cloned_state, "player_troops", "Estado clonado deve ter player_troops")
	assert_has(cloned_state, "enemy_statue", "Estado clonado deve ter enemy_statue")
	assert_has(cloned_state, "player_statue", "Estado clonado deve ter player_statue")

# Testes para get_all_possible_moves
func test_get_all_possible_moves_empty_state():
	var moves = lookahead.get_all_possible_moves()
	assert_not_null(moves, "Lista de movimentos não deve ser nula")
	assert_true(moves is Array, "Movimentos devem ser um Array")

# Testes para apply_move
func test_apply_move_play_card():
	var state = create_mock_game_state()
	var mock_card = create_mock_card()
	var move = {
		"type": "play_card",
		"card": mock_card,
		"tile": Vector2i(1, 1),
		"monster_id": "test_monster"
	}
	
	var initial_hand_size = state["enemy_hand"].size()
	var initial_troops_size = state["enemy_troops"].size()
	
	lookahead.apply_move(state, move)
	
	assert_eq(state["enemy_hand"].size(), initial_hand_size - 1, 
		"Carta deve ser removida da mão")
	assert_eq(state["enemy_troops"].size(), initial_troops_size + 1, 
		"Tropa deve ser adicionada ao tabuleiro")

# Testes para evaluate_move
func test_evaluate_move():
	var state = create_mock_game_state()
	var move = create_mock_move()
	
	var score = lookahead.evaluate_move(state, move)
	assert_true(score is float or score is int, 
		"Score deve ser um número")

# Funções auxiliares para criar estados mockados
func create_mock_game_state() -> Dictionary:
	return {
		"enemy_hand": [],
		"enemy_troops": [],
		"player_troops": [],
		"enemy_statue": {
			"hp": 10,
			"initial_hp": 10,
			"attack_positions": [Vector2i(0, 0)],
			"pos": Vector2i(0, 0)
		},
		"player_statue": {
			"hp": 10,
			"initial_hp": 10,
			"attack_positions": [Vector2i(5, 5)],
			"pos": Vector2i(5, 5)
		}
	}

func create_mock_card() -> Dictionary:
	return {
		"name": "Test Card",
		"life": 5,
		"attack": 3
	}

func create_mock_move() -> Dictionary:
	return {
		"type": "move_troop",
		"troop": {
			"name": "test_troop",
			"pos": Vector2i(0, 0),
			"hp": 5,
			"attack_points": 3
		},
		"tile": Vector2i(1, 1),
		"monster_id": "test_troop"
	}

# Testes para simulate_moves
func test_simulate_moves_returns_best_move():
	var best_move = lookahead.simulate_moves()
	# Pode retornar null se não houver movimentos possíveis
	if best_move != null:
		assert_has(best_move, "type", "Melhor movimento deve ter um tipo")
		match best_move["type"]:
			"play_card":
				assert_has(best_move, "card", "Movimento de jogar carta deve ter uma carta")
				assert_has(best_move, "tile", "Movimento de jogar carta deve ter um tile")
			"move_troop":
				assert_has(best_move, "troop", "Movimento de tropa deve ter uma tropa")
				assert_has(best_move, "tile", "Movimento de tropa deve ter um tile")
			"attack":
				assert_has(best_move, "troop", "Ataque deve ter uma tropa atacante")
				assert_has(best_move, "target", "Ataque deve ter um alvo")

# Testes para simulate_moves_lookahead2
func test_simulate_moves_lookahead2_returns_moves_array():
	var moves = lookahead.simulate_moves_lookahead2()
	assert_true(moves is Array, "Lookahead2 deve retornar um array de movimentos")
	# Se houver movimentos, verifica o primeiro
	if not moves.is_empty():
		assert_has(moves[0], "type", "Primeiro movimento deve ter um tipo") 