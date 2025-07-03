extends AIStrategy


var opponents

func play_turn():
	_turn_start()
	
	await spawner.select_and_spawn_best_monster()
	_update_troops_list()
	await enemy_ai.wait(0.3)
	await _process_next_troop()
	
func move_trop_pos(troop):
	
	var objective_pos = null
	if ai_finder.in_attack_area_pos(troop):
		return null
	
	opponents = troop_manager.sorted_opponents_by_distance(current_troop)
	
	if opponents.size() == 0:
		objective_pos = closest_area_pos()
		if grid_controller.is_achievable_path(current_troop.global_position, objective_pos):
			return grid_controller.get_last_pos_path_with_walk_points(
				current_troop.global_position,
				objective_pos,
				current_troop.get_current_walk_points())
		else:
			return ai_finder.find_nearest_reachable_position(current_troop, objective_pos)
	
	#if opponent_close_troop():
	#	return null
		
	for opp in opponents:
		var is_achievable_troop = grid_controller.is_achievable_troop(
			current_troop.global_position,
			opp.global_position,
		)
		
		if is_achievable_troop:
			objective_pos = opp.global_position
			
			var final_pos  = grid_controller.get_pos_to_troop(
				current_troop.global_position,
				objective_pos,
				current_troop.get_current_walk_points())
				
			print("is_achievable_troop pos: ",final_pos)
				
			return final_pos
		else:
			continue
			
	objective_pos = opponents[0].global_position
	return ai_finder.find_nearest_reachable_position(current_troop, objective_pos)
	
func closest_area_pos():
	var closest_area = ai_finder.closest_area_to_attack(current_troop)
	if closest_area:
		return closest_area.global_position
	else:
		var rng = RandomNumberGenerator.new()
		var random_int = rng.randi_range(0, ai_finder.attack_area.size()-1) 
		return ai_finder.attack_area[random_int].global_position
			
func opponent_close_troop():
	var distance = grid_controller.get_distance(
		current_troop.global_position,
		opponents[0].global_position #first opponent is the close
		)
	
	if distance == 1:
		return opponents[0]
	else:
		return null
