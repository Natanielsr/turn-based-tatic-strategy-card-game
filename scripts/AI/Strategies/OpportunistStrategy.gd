extends AIStrategy

var selected_troop
var opponents

func play_turn():
	await spawner.select_and_spawn_best_monster()
	await mover.move_all()
	
func move_trop_pos(troop):
	if ai_finder.in_area_pos(troop):
		return null
		
	selected_troop = troop
	
	opponents = troop_manager.sorted_opponents_by_distance(selected_troop)
	
	if opponents.size() == 0:
		return closest_area_pos()
	
	if opponent_close_troop():
		return null
		
	for opp in opponents:
		var is_achievable_troop = grid_controller.is_achievable_troop(
			selected_troop.global_position,
			opp.global_position,
		)
		
		if is_achievable_troop:
			return opp.global_position
			
	return closest_area_pos()
	
func closest_area_pos():
	var closest_area = ai_finder.closest_area_to_attack(selected_troop)
	if closest_area:
		return closest_area.global_position
	else:
		var rng = RandomNumberGenerator.new()
		var random_int = rng.randi_range(0, ai_finder.attack_area.size()-1) 
		return ai_finder.attack_area[random_int].global_position
			
func opponent_close_troop():
	var distance = grid_controller.get_distance(
		selected_troop.global_position,
		opponents[0].global_position #first opponent is the close
		)
	
	if distance == 1:
		return opponents[0]
	else:
		return null
