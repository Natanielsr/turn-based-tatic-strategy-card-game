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
	
	return best_move

func get_all_possible_moves() -> Array:
	var moves = []
	
	# Play cards from hand
	for card : Card in enemy_hand.hand:
		if can_play_the_card(card):
			for tile in get_valid_spawn_tiles():
				moves.append({
					"type": "play_card",
					"card": card,
					"tile": tile,
					"monster_id": troop_manager.generate_id(card.card_id, Entity.EntityFaction.ENEMY)
				})
	
	# Move troops
	for troop in troop_manager.enemy_troops:
		if troop.get_current_walk_points() == 5 and troop.is_alive():
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
		if troop.can_attack() and troop.is_alive():
			for target in get_attackable_targets(troop):
				if target.is_alive():
					moves.append({
						"type": "attack",
						"troop": troop,
						"target": target,
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
				if card["name"] == move["card"].card_id:
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
			"attack_positions": get_valid_spawn_tiles(),
			"defense_positions" : get_defense_tiles()
		},
		"player_statue": {
			"hp": player_statue.current_life_points,
			"initial_hp": player_statue.current_life_points,
			"attack_positions": ai_finder.get_attack_player_tiles(),
			"pos" : Vector2i(0,0)
		}
	}
	
	# Clone hand
	for card : Card in enemy_hand.hand:
		state["enemy_hand"].append({
			"name": card.card_id,
			"attack": card.attack_points,
			"life": card.life_points,
			"energy_cost" : card.energy_cost
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
	
func get_defense_tiles() -> Array:
	return ai_spawner.get_defense_tiles()

func get_valid_move_tiles(troop: MobileTroop) -> Array:
	return grid_controller.get_valid_move_tiles(troop)

func get_attackable_targets(troop: MobileTroop) -> Array[Entity]:
	var targets = ai_finder.get_attackable_targets(troop)
	
	if troop.get_provoker(): #provoked
		return targets
	
	var attack_player_positions = ai_finder.get_attack_player_tiles()
	
	for pos in attack_player_positions:
		if troop.get_tile_pos() == pos:
			targets.append(player_statue)
	
	return targets

func can_play_the_card(card : Card) -> bool:
	if enemy_statue._current_energy >= card.energy_cost:
		return true
	else:
		return false
