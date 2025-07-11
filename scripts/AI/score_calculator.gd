class_name ScoreCalculator

var grid_controller: GridController

func init(grid: GridController):
	grid_controller = grid

var weights = {
	"alive_troops": 10,
	"total_life": 1,
	"attack_result": 40,
	"area_control": 40,
	"statue_damage": 50,
	"victory": 10000,
	"hunt_weak": 10,
	"approach_invader": 40,
	"attack_invader": 30,
	"defense_approach": 30,
	"defense_kill": 50
}

func calculate_total_score(game_state, move):
	var total_score = 0
	
	# Pontuações básicas
	total_score += score_alive_troops(game_state) * weights.alive_troops
	total_score += score_total_life(game_state) * weights.total_life
	total_score += score_attack_result(game_state, move) * weights.attack_result
	total_score += score_area_control(game_state) * weights.area_control
	total_score += score_statue_damage(game_state) * weights.statue_damage
	total_score += score_victory_defeat(game_state) * weights.victory
	
	# Pontuações táticas
	total_score += score_hunt_weaker_targets(game_state) * weights.hunt_weak
	total_score += score_approach_invader(game_state, move) * weights.approach_invader
	total_score += score_attack_invader(move) * weights.attack_invader
	total_score += score_approach_enemy_defense_statue(game_state) * weights.defense_approach
	total_score += score_kill_enemy_defense_statue(game_state, move) * weights.defense_kill
	
	return total_score

func score_alive_troops(game_state):
	return game_state["enemy_troops"].filter(func(t): return t["hp"] > 0).size() - \
		   game_state["player_troops"].filter(func(t): return t["hp"] > 0).size()

func score_total_life(game_state):
	var enemy_life = game_state["enemy_troops"].reduce(func(acc, t): return acc + t["hp"], 0)
	var player_life = game_state["player_troops"].reduce(func(acc, t): return acc + t["hp"], 0)
	return enemy_life - player_life

func score_attack_result(game_state, move):
	if not move or move["type"] != "attack" or move["target"] is Statue:
		return 0
		
	var result = game_state["player_troops"].filter(func(t): 
		return t["pos"] == move["target"].get_tile_pos()
	)
	var target = null
	if result.size() > 0:
		target = result[0]
	else:
		push_error("TARGET NOT FOUND")
		return 0
	
	
	var attacker = game_state["enemy_troops"].filter(func(t): 
		return t["pos"] == move["troop"].get_tile_pos()
	)[0]
	
	if target["hp"] <= 0 and attacker["hp"] > 0:
		return 1
	elif attacker["hp"] <= 0 and target["hp"] > 0:
		return -1
	return 0

func score_area_control(game_state):

	var score = 0
	var attack_positions = game_state["player_statue"]["attack_positions"]
	
	for enemy_troop in game_state["enemy_troops"]:
		if enemy_troop["hp"] <= 0:
			continue

		for att_pos in attack_positions:
			if occupied_area(game_state, att_pos):
				continue
			var distance = grid_controller.get_distance(enemy_troop["pos"], att_pos)
			score += -distance

	return score
	
func occupied_area(game_state, area):
	for enemy_troop in game_state["enemy_troops"]:
		if enemy_troop["pos"] == area:
			return true
			
	return false

func score_statue_damage(game_state):
	var player_damage = game_state["player_statue"]["initial_hp"] - game_state["player_statue"]["hp"]
	var enemy_damage = game_state["enemy_statue"]["initial_hp"] - game_state["enemy_statue"]["hp"]
	return player_damage - enemy_damage

func score_victory_defeat(game_state):
	if game_state["player_statue"]["hp"] <= 0:
		return 1
	elif game_state["enemy_statue"]["hp"] <= 0:
		return -1
	return 0

func score_hunt_weaker_targets(game_state):
	var score = 0
	for enemy in game_state["enemy_troops"]:
		if enemy["hp"] <= 0:
			continue
		for player in game_state["player_troops"]:
			if player["hp"] <= 0 or enemy["attack_points"] < player["hp"]:
				continue
			score += 10 - grid_controller.get_distance(enemy["pos"], player["pos"])
	return score

func score_approach_invader(game_state, move):
	if not move or move["type"] != "move_troop":
		return 0
	
	var score = 0
	var old_pos = move["troop"].get_tile_pos()
	var new_pos = move["tile"]

	for player_troop in game_state["player_troops"]:
		if player_troop["hp"] <= 0:
			continue
			
		var distance = grid_controller.distance_to_tile(player_troop["pos"], old_pos)
		if distance > 5:
			continue
		
		var new_distance = grid_controller.distance_to_tile(player_troop["pos"], new_pos)

		var distance_change = new_distance - distance

		var x_factor = (player_troop["pos"].x + 1) * 2

		if distance_change < 0:
			score += (-distance_change * x_factor)
		else:
			score -= (distance_change * x_factor)
	
	return score

func score_attack_invader(move):
	if not move or move["type"] != "attack" or move["target"] is Statue:
		return 0
		
	var target_pos = move["target"].get_tile_pos()
	return 1 if target_pos.x >= 0 else 0

func score_approach_enemy_defense_statue(game_state):
	var score = 0
	var defense_positions = game_state["enemy_statue"]["attack_positions"]
	
	for player in game_state["player_troops"]:
		if player["hp"] <= 0 or not (player["pos"] in defense_positions):
			continue
		for enemy in game_state["enemy_troops"]:
			if enemy["hp"] <= 0:
				continue
			
			var distance = grid_controller.get_distance(enemy["pos"], player["pos"])
			if distance > 5:
				continue
				
			score += 20 - 4 * distance
	return score

func score_kill_enemy_defense_statue(game_state, move):
	if not move or move["type"] != "attack" or move["target"] is Statue:
		return 0
		
	var target_pos = move["target"].get_tile_pos()
	var defense_positions = game_state["enemy_statue"]["attack_positions"]
	
	if target_pos in defense_positions:
		var target = game_state["player_troops"].filter(func(t): 
			return t["pos"] == target_pos
		)[0]
		return 1 if target["hp"] <= 0 else 0
	return 0 
	
func score_escape_weak_from_strong(game_state, move) -> int:
	var score = 0

	if move["type"] == "move_troop":
		var old_pos = move["troop"].get_tile_pos()
		var new_pos = move["tile"]
		var troop_hp = move["troop"].current_life_points
		# Considere "fraca" se hp <= 5 (ajuste conforme seu jogo)
		if troop_hp <= 2:
			var min_dist_before = INF
			var min_dist_after = INF
			for enemy in game_state["enemy_troops"]:
				if enemy["hp"] <= 0:
					continue
				if enemy["attack_points"] >= 3:
					var dist_before = old_pos.distance_to(enemy["pos"])
					var dist_after = new_pos.distance_to(enemy["pos"])
					if dist_before < min_dist_before:
						min_dist_before = dist_before
					if dist_after < min_dist_after:
						min_dist_after = dist_after
			# Se aumentou a distância, valorize
			if min_dist_after > min_dist_before:
				score += int((min_dist_after - min_dist_before) * 10)
			# Se diminuiu, puna
			elif min_dist_after < min_dist_before:
				score -= int((min_dist_before - min_dist_after) * 10)
	return score
