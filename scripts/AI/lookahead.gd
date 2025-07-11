extends Node2D
class_name LookAhead

const scoreCalculator = preload("res://scripts/AI/score_calculator.gd")

@onready var game_controller: GameController = $"../../Controllers/GameController"
@onready var troop_manager: TroopManager = $"../../TroopManager"
@onready var enemy_hand: EnemyHand = $"../EnemyHand"
@onready var ai_spawner: AISpawner = $"../AISpawner"
@onready var ai_finder: AIFinder = $"../AIFinder"
@onready var grid_controller: GridController = $"../../Controllers/GridController"
@onready var card_manager: CardManager = $"../../CardSystem/CardManager"
@onready var enemy_statue: EnemyStatue = $"../../Statues/EnemyStatue"
@onready var player_statue: PlayerStatue = $"../../Statues/PlayerStatue"

var score_calculator = scoreCalculator.new()

func _ready() -> void:
	score_calculator.init(grid_controller)

func init():
	game_controller = GameController.new()
	troop_manager = TroopManager.new()
	enemy_hand = EnemyHand.new()
	enemy_hand.init()
	ai_spawner = AISpawner.new()
	ai_spawner.init()
	ai_finder = AIFinder.new()
	ai_finder.init()
	grid_controller = GridController.new()
	grid_controller.init()
	card_manager = CardManager.new()
	enemy_statue = EnemyStatue.new()
	player_statue = PlayerStatue.new()
	score_calculator.init(grid_controller)

#func simulate_moves():
#	return simulate_moves_game_state(clone_game_state())
	
func simulate_moves():
	var best_score = -INF
	var best_move = null
	var possible_moves = get_all_possible_moves()
	
	for move in possible_moves:
		var state = clone_game_state()
		apply_move(state, move)
		var score = evaluate_move(state, move)
		if score > best_score:
			best_score = score
			best_move = move
	
	print("BEST SCORE: ", best_score)
	return best_move

func simulate_moves_lookahead2():
	var best_score = -INF
	var best_moves = []
	var possible_moves = get_all_possible_moves()
	
	for move1 in possible_moves:
		var state1 = clone_game_state()
		apply_move(state1, move1)
		
		var moves2 = get_all_possible_moves_for_state(state1)
		if moves2.is_empty():
			var score = evaluate_move(state1, move1)
			if score > best_score:
				best_score = score
				best_moves = [move1]
		else:
			for move2 in moves2:
				var state2 = state1.duplicate()
				apply_move(state2, move2)
				var score = evaluate_move(state2, move2)
				if score > best_score:
					best_score = score
					best_moves = [move1, move2]
	
	print("BEST SCORE (lookahead 2): ", best_score)
	return best_moves

func get_all_possible_moves() -> Array:
	var moves = []
	
	# Play cards from hand
	for card in enemy_hand.hand:
		if can_play_the_card(card):
			for tile in get_valid_spawn_tiles():
				moves.append({
					"type": "play_card",
					"card": card,
					"tile": tile,
					"monster_id": troop_manager.generate_id(card, Entity.EntityFaction.ENEMY)
				})
	
	# Move troops
	for troop in troop_manager.enemy_troops:
		if troop.can_move():
			for tile in get_valid_move_tiles(troop):
				moves.append({
					"type": "move_troop",
					"troop": troop,
					"tile": tile,
					"monster_id": troop.name,
					"troop_pos": troop.get_tile_pos()
				})
	
	# Attack with troops
	for troop in troop_manager.enemy_troops:
		if troop.can_attack():
			for target in get_attackable_targets(troop):
				moves.append({
					"type": "attack",
					"troop": troop,
					"target": target,
				})
	
	return moves

func get_all_possible_moves_for_state(state: Dictionary) -> Array:
	var moves = []
	
	# Play cards from hand
	for card in state["enemy_hand"]:
		if can_play_the_card(card["name"]):
			for tile in state["enemy_statue"]["attack_positions"]:
				moves.append({
					"type": "play_card",
					"card": card["name"],
					"tile": tile,
					"monster_id": card_manager.generate_id(card["name"], Entity.EntityFaction.ENEMY)
				})
	
	# Move troops
	for troop in state["enemy_troops"]:
		for tile in get_valid_move_tiles_for_state(troop, state):
			moves.append({
				"type": "move_troop",
				"troop": troop,
				"tile": tile,
				"troop_pos": troop["pos"]
			})
	
	# Attack with troops
	for troop in state["enemy_troops"]:
		for target in get_attackable_targets_for_state(troop, state):
			moves.append({
				"type": "attack",
				"troop": troop,
				"troop_pos": troop["pos"],
				"target": target,
				"target_pos": target["pos"]
			})
	
	return moves

func get_valid_move_tiles_for_state(troop: Dictionary, state: Dictionary) -> Array:
	var tiles = []
	var directions = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	
	for dir in directions:
		var new_pos = troop["pos"] + dir
		var occupied = false
		
		for other in state["enemy_troops"] + state["player_troops"]:
			if other["hp"] > 0 and other["pos"] == new_pos:
				occupied = true
				break
		
		if not occupied:
			tiles.append(new_pos)
	
	return tiles

func get_attackable_targets_for_state(troop: Dictionary, state: Dictionary) -> Array:
	var targets = []
	
	# Check troops
	for player in state["player_troops"]:
		if player["hp"] > 0 and troop["pos"].distance_to(player["pos"]) == 1:
			targets.append(player)
	
	# Check statue
	for pos in state["player_statue"]["attack_positions"]:
		if troop["pos"] == pos:
			targets.append(state["player_statue"])
	
	return targets

func apply_move(state: Dictionary, move: Dictionary) -> void:
	match move["type"]:
		"play_card":
			# Remove card from hand
			for i in state["enemy_hand"].size():
				var card = state["enemy_hand"][i]
				if card["name"] == move["card"]:
					# Add troop to board
					state["enemy_troops"].append({
						"name": move["monster_id"],
						"pos": move["tile"],
						"hp": card.life,
						"attack_points": card.attack
					})
					state["enemy_hand"].remove_at(i)
					break
		
		"move_troop":
			# Move troop
			for troop in state["enemy_troops"]:
				if troop["pos"] == move["troop_pos"]:
					troop["pos"] = move["tile"]
					break
		
		"attack":
			# Process attack
			
			var troop_pos = move["troop"].get_tile_pos()
			
			var result_troop = state["enemy_troops"].filter(
				func(t): return t["pos"] == troop_pos)
				
			var attacker = null
			if result_troop.size() > 0:
				attacker = result_troop[0]
			else:
				push_error("TROOP NOT FOUND")
			
			if move["target"] is Statue:
				state["player_statue"]["hp"] -= attacker["attack_points"]
			else:
				var result = state["player_troops"].filter(func(t): return t["pos"] == move["target"].get_tile_pos())
				if result.size() > 0:
					var target = result[0]
					target["hp"] -= attacker["attack_points"]
					attacker["hp"] -= target["attack_points"]
				else:
					push_error("TARGET NOT FOUND")

func clone_game_state() -> Dictionary:
	var state = {
		"enemy_hand": [],
		"enemy_troops": [],
		"player_troops": [],
		"enemy_statue": {
			"hp": enemy_statue.current_life_points,
			"initial_hp": enemy_statue.current_life_points,
			"attack_positions": get_valid_spawn_tiles()
		},
		"player_statue": {
			"hp": player_statue.current_life_points,
			"initial_hp": player_statue.current_life_points,
			"attack_positions": ai_finder.get_attack_player_tiles(),
			"pos" : Vector2i(0,0)
		}
	}
	
	# Clone hand
	for card in enemy_hand.hand:
		var card_data = game_controller.card_database.CARDS[card]
		state["enemy_hand"].append({
			"name": card_data.card_id,
			"attack": card_data.attack,
			"life": card_data.health
		})
	
	# Clone troops
	for troop in troop_manager.enemy_troops:
		state["enemy_troops"].append(create_mobile_obj(troop))
	
	for troop in troop_manager.player_troops:
		state["player_troops"].append(create_mobile_obj(troop))
	
	return state

func create_mobile_obj(troop: MobileTroop) -> Dictionary:
	var pos = troop.get_tile_pos()
	return {
		"name": troop.name,
		"card_id": troop.card_id,
		"pos": pos,
		"hp": troop.current_life_points,
		"attack_points": troop.attack_points,
		"monster_id": troop_manager.generate_id(troop.card_id, Entity.EntityFaction.ENEMY)
	}

func evaluate_move(game_state: Dictionary, move: Dictionary) -> int:
	return score_calculator.calculate_total_score(game_state, move)

func get_valid_spawn_tiles() -> Array:
	return ai_spawner.get_valid_spawn_tiles()

func get_valid_move_tiles(troop: MobileTroop) -> Array:
	return grid_controller.get_valid_move_tiles(troop)

func get_attackable_targets(troop: MobileTroop) -> Array[Entity]:
	var targets = ai_finder.get_attackable_targets(troop)
	var attack_player_positions = ai_finder.get_attack_player_tiles()
	
	for pos in attack_player_positions:
		if troop.get_tile_pos() == pos:
			targets.append(player_statue)
	
	return targets

func can_play_the_card(card) -> bool:
	return card_manager.can_play_the_card(card, Entity.EntityFaction.ENEMY)
