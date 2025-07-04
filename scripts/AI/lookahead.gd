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
						"attack_points" : card_selected.attack
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
			
			if move["target"] is Statue:
				var current_player_statue = cloned_state["player_statue"]
				current_player_statue["hp"] -= attacker["attack_points"]
			else:
				for target in cloned_state["player_troops"]:
					if target["pos"] == move["target"].get_tile_pos():
						target["hp"] -= attacker["attack_points"]
						attacker["hp"] -= target["attack_points"]
						#if target["hp"] <= 0:
							#cloned_state["player_troops"].erase(target)  # Remove dead troop
							
						#if attacker["hp"] <= 0:
							#cloned_state["enemy_troops"].erase(attacker)
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
		state["enemy_troops"].append(create_mobile_obj(troop))
		
	for troop : MobileTroop in troop_manager.player_troops:
		state["player_troops"].append(create_mobile_obj(troop))
		
	# Repita para player_troops, cartas, etc.
	return state
	
func create_mobile_obj(troop : MobileTroop):
	return {
			"card_id" : troop.card_id,
			"pos": troop.get_tile_pos(),
			"hp": troop.current_life_points,
			"attack_points" : troop.attack_points
			
			# ... outros atributos
		}
	
func evaluate_move(game_state, move) -> int:
	var score = 0
	score += score_alive_troops(game_state)
	score += score_total_life(game_state)
	score += score_attack_result(game_state, move)
	score += score_area_control(game_state)
	score += score_statue_damage(game_state)
	score += score_victory_defeat(game_state)
	score += score_hunt_weaker_targets(game_state)
	score += score_approach_invader(game_state)
	score += score_attack_invader(game_state, move) 


	return score

func score_alive_troops(game_state) -> int:
	var score = 0
	score += game_state["enemy_troops"].filter(func(t): return t["hp"] > 0).size() * 10
	score -= game_state["player_troops"].filter(func(t): return t["hp"] > 0).size() * 10
	return score

func score_total_life(game_state) -> int:
	var score = 0
	for troop in game_state["enemy_troops"]:
		score += troop["hp"]
	for troop in game_state["player_troops"]:
		score -= troop["hp"]
	return score

func score_attack_result(game_state, move) -> int:
	var score = 0
	if move["type"] == "attack":
		if move["target"] is Statue:
			return 0
			
		for target in game_state["player_troops"]:
			if target["pos"] == move["target"].get_tile_pos(): #se for statue nao faz esse calculo
				var attacker = null
				for t in game_state["enemy_troops"]:
					if t["pos"] == move["troop"].get_tile_pos():
						attacker = t
						break
				if target["hp"] <= 0 and attacker and attacker["hp"] > 0:
					score += 40
				elif attacker and attacker["hp"] and target["hp"] > 0:
					score -= 40
	return score

func score_area_control(game_state) -> int:
	var score = 0
	for troop in game_state["enemy_troops"]:
		var min_dist = INF
		for attack_pos in game_state["player_statue"]["attack_positions"]:
			var dist = troop["pos"].distance_to(attack_pos)
			if dist < min_dist:
				min_dist = dist
		score += int(10 - min_dist)
	return score

func score_statue_damage(game_state) -> int:
	var score = 0
	var player_statue_hp = game_state["player_statue"]["hp"]
	var initial_player_statue_hp = player_statue.current_life_points
	var damage_to_player_statue = initial_player_statue_hp - player_statue_hp
	score += damage_to_player_statue * 50
	if damage_to_player_statue > 0:
		print(score)

	var enemy_statue_hp = game_state["enemy_statue"]["hp"]
	var initial_enemy_statue_hp = enemy_statue.current_life_points
	var damage_to_enemy_statue = initial_enemy_statue_hp - enemy_statue_hp
	score -= damage_to_enemy_statue * 50
	return score

func score_victory_defeat(game_state) -> int:
	var score = 0
	var player_statue_hp = game_state["player_statue"]["hp"]
	var enemy_statue_hp = game_state["enemy_statue"]["hp"]
	if player_statue_hp <= 0:
		score += 10000
	elif enemy_statue_hp <= 0:
		score -= 10000
	return score

func score_hunt_weaker_targets(game_state) -> int:
	var score = 0
	for enemy_troops in game_state["enemy_troops"]:
		if enemy_troops["hp"] <= 0:
			continue
		for player_troops in game_state["player_troops"]:
			if player_troops["hp"] <= 0:
				continue
			# Se o inimigo é mais forte que o player (ataque maior que a vida do player)
			if enemy_troops["attack_points"] >= player_troops["hp"]:
				var dist = enemy_troops["pos"].distance_to(player_troops["pos"])
				# Quanto mais perto, maior o score (ajuste o peso conforme desejar)
				score += int(10 - dist)
	return score

func score_approach_invader(game_state) -> int:
	var score = 0
	# Supondo que o campo do inimigo é a metade superior do grid (ajuste conforme necessário)
	var grid_mid_x = 0#float(grid_controller.tile_grid.get_used_rect().size.x) / 2.0
	for player in game_state["player_troops"]:
		if player["hp"] <= 0:
			continue
		if player["pos"].x >= grid_mid_x:
			# Esta tropa está invadindo o campo do inimigo
			for enemy in game_state["enemy_troops"]:
				if enemy["hp"] <= 0:
					continue
				var dist = enemy["pos"].distance_to(player["pos"])
				score += int(8 - dist) # Quanto mais perto, maior o score
	return score

func score_attack_invader(game_state, move) -> int:
	var score = 0
	if move["type"] == "attack":
		if move["target"] is Statue:
			return 0
			
		var grid_mid_x = 0 #float(grid_controller.tile_grid.get_used_rect().size.x) / 2
		for target in game_state["player_troops"]:
			if target["pos"] == move["target"].get_tile_pos() and target["pos"].x >= grid_mid_x:
				score += 30  # Incentivo para atacar tropas invasoras
				break
	return score


func get_valid_spawn_tiles():
	return ai_spawner.get_valid_spawn_tiles()

func get_valid_move_tiles(troop: MobileTroop):
	return grid_controller.get_valid_move_tiles(troop)

func get_attackable_targets(troop: MobileTroop) -> Array[Entity]:
	var targets = ai_finder.get_attackable_targets(troop)
	var attack_player_positions = ai_finder.get_attack_player_tiles()
	for pos in attack_player_positions:
		if troop.get_tile_pos() == pos:
			targets.append(player_statue)
			
	
	
	return targets
	
func can_play_the_card(card):
	return card_manager.can_play_the_card(card, Entity.EntityFaction.ENEMY)
