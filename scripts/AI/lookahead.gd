extends Node2D

class_name  LookAhead

@onready var game_controller: GameController = $"../../Controllers/GameController"
@onready var troop_manager: TroopManager = $"../../TroopManager"
@onready var enemy_hand: EnemyHand = $"../EnemyHand"
@onready var ai_spawner: AISpawner = $"../AISpawner"
@onready var ai_finder: AIFinder = $"../AIFinder"
@onready var grid_controller: GridController = $"../../Controllers/GridController"
@onready var card_manager: CardManager = $"../../CardSystem/CardManager"
@onready var enemy_statue: EnemyStatue = $"../../Statues/EnemyStatue"
@onready var player_statue: PlayerStatue = $"../../Statues/PlayerStatue"


func simulate_moves():
	var best_score = -INF
	var best_move = null
	var possible_moves = get_all_possible_moves()
	for move in possible_moves:
		var cloned_state = clone_game_state()
		apply_move(cloned_state, move)
		var score = evaluate_move(cloned_state, move)
		if score > best_score:
			best_score = score
			best_move = move
	print("BEST SCORE: ",best_score)
	return best_move

func get_all_possible_moves():

	var moves = []

	#1. Play cards from hand (example: troop cards)
	for card in enemy_hand.hand:
		if can_play_the_card(card):
			for tile in get_valid_spawn_tiles():
				moves.append({
					"type": "play_card",
					"card": card,
					"tile": tile
				})

	# 2. Move enemy troops
	for troop in troop_manager.enemy_troops:
		if troop.can_move():
			var move_tiles = get_valid_move_tiles(troop)
			for tile in move_tiles:
				moves.append({
					"type": "move_troop",
					"troop": troop,
					"tile": tile
				})

	#3. Attack with enemy troops
	for troop in troop_manager.enemy_troops:
		if troop.can_attack():
			for target in get_attackable_targets(troop):
				moves.append({
					"type": "attack",
					"troop": troop,
					"target": target
				})
	


	return moves

func apply_move(cloned_state, move):
	match move["type"]:
		"play_card":
			#remove card from the virual hand
			for i in cloned_state["enemy_hand"].size():
				var card_selected = cloned_state["enemy_hand"][i]
				if card_selected["name"] == move["card"]:
					
					#add a virtual troop in the specified tile
					cloned_state["enemy_troops"].append({
						"name":  move["card"],
						"pos": move["tile"],
						"hp": card_selected.life,
						# ... other attributes
					})
					
					cloned_state["enemy_hand"].remove_at(i)
					break
			
			
		"move_troop":
			#move the virtual troop to the specified tile
			for troop in cloned_state["enemy_troops"]:
				if troop["pos"] == move["troop"].get_tile_pos():
					troop["pos"] = move["tile"]
					break
		
		"attack":
			#Reduce the life points of the target troops
			var attacker = null
			for troop in cloned_state["enemy_troops"]:
				if troop["pos"] == move["troop"].get_tile_pos():
					attacker = troop
					break
			
			for target in cloned_state["player_troops"]:
				if target["pos"] == move["target"].get_tile_pos():
					target["hp"] -= attacker["attack_points"]
					if target["hp"] <= 0:
						cloned_state["player_troops"].erase(target)  # Remove dead troop
					break

	
func clone_game_state():
	var state = {
		"enemy_hand": [],
		"enemy_troops": [],
		"player_troops": [],
		"enemy_statue": {
			"hp": enemy_statue.current_life_points,
			"attack_positions": get_valid_spawn_tiles(),
			# ... outros atributos
		},
		"player_statue": {
			"hp": player_statue.current_life_points,
			"attack_positions": ai_finder.get_attack_player_tiles(),
			# ... outros atributos
		},
		# ... outros dados relevantes
	}

	for card in enemy_hand.hand:
		var card_data = game_controller.card_database.CARDS[card]
		state["enemy_hand"].append({
			"name": card_data.card_id,
			"attack" : card_data.attack,
			"life" : card_data.health
			# ... outros atributos
		})
	
	for troop : MobileTroop in troop_manager.enemy_troops:
		state["enemy_troops"].append({
			"pos": troop.get_tile_pos(),
			"hp": troop.current_life_points,
			# ... outros atributos
		})
		
	for troop : MobileTroop in troop_manager.player_troops:
		state["player_troops"].append({
			"pos": troop.get_tile_pos(),
			"hp": troop.current_life_points,
			# ... outros atributos
		})
	# Repita para player_troops, cartas, etc.
	return state
	
func evaluate_move(game_state, move) -> int:
	
	var score = 0

	#1. value of the alive troops
	score += game_state["enemy_troops"].size() * 10
	score -= game_state["player_troops"].size() * 10

	#2. total life points of the troops
	for troop in game_state["enemy_troops"]:
		score += troop["hp"]
	for troop in game_state["player_troops"]:
		score -= troop["hp"]

	#3. bonus for eliminating enemy troops
	if move["type"] == "attack":
		for target in game_state["player_troops"]:
			if target["hp"] <= 0:
				score += 20  # Bonus for eliminating an enemy troop

	#4. area control (example: next of statue of player)

	for troop in game_state["enemy_troops"]:
		var min_dist = INF
		for attack_pos in game_state["player_statue"]["attack_positions"]:
			var dist = troop["pos"].distance_to(attack_pos)
			if dist < min_dist:
				min_dist = dist
		score += int(10 - min_dist)  # more close better

		

	#5. damage to opponent's statue (player)
	var player_statue_hp = game_state["player_statue"]["hp"]
	var initial_player_statue_hp = player_statue.total_life_points
	var damage_to_player_statue = initial_player_statue_hp - player_statue_hp
	score += damage_to_player_statue * 50

	#6. damage to own statue (enemy)
	var enemy_statue_hp = game_state["enemy_statue"]["hp"]
	var initial_enemy_statue_hp = enemy_statue.total_life_points
	var damage_to_enemy_statue = initial_enemy_statue_hp - enemy_statue_hp
	score -= damage_to_enemy_statue * 50

	#7. victory/defeat
	if player_statue_hp <= 0:
		score += 10000 #Victory for the enemy
	elif enemy_statue_hp <= 0:
		score -= 10000 #Defeat for the enemy

	return score

func get_valid_spawn_tiles():
	return ai_spawner.get_valid_spawn_tiles()

func get_valid_move_tiles(troop: MobileTroop):
	return grid_controller.get_valid_move_tiles(troop)

func get_attackable_targets(troop: MobileTroop) -> Array[MobileTroop]:
	return ai_finder.get_attackable_targets(troop)
	
func can_play_the_card(card):
	return card_manager.can_play_the_card(card, Entity.EntityFaction.ENEMY)
