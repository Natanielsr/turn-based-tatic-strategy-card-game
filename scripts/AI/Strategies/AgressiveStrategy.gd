# AgressiveStrategy.gd
extends AIStrategy

class_name AgressiveStrategy

func play_turn():
	_turn_start()
	
	current_index = 0
	await spawner.select_and_spawn_best_monster()
	_update_troops_list()
	
	await enemy_ai.wait(0.3)
	await _process_next_troop()
	
func move_trop_pos(troop):
	var objective_pos = null
	
	var opponent_in_base_pos = get_opponent_in_base_pos()
	if opponent_in_base_pos:
		return opponent_in_base_pos
	
	if ai_finder.in_attack_area_pos(troop):
		return null
		
	var close_area = ai_finder.closest_area_to_attack(troop)
	if close_area:
		objective_pos = close_area.global_position
		if grid_controller.is_achievable_path(current_troop.global_position, objective_pos):
			return grid_controller.get_last_pos_path_with_walk_points(
				current_troop.global_position,
				objective_pos,
				current_troop.get_current_walk_points())
		else:
			return attack_troop_pos()

	else:
		return attack_troop_pos()
		

func attack_troop_pos():
	var troops = troop_manager.sorted_opponents_by_attack()
	var opponent = null
	for troop in troops:
		var is_achievable = grid_controller.is_achievable_troop(
			current_troop.global_position,
			troop.global_position
		)
		
		if not is_achievable:
			continue
		else:
			opponent = troop
			break;
			
	if opponent == null:
		return find_nearest_reachable_troop()
	
	var pos = grid_controller.get_pos_to_troop(
		current_troop.global_position,
		opponent.global_position,
		current_troop.get_current_walk_points()
		)
		
	if pos:
		return pos
	else:
		return find_nearest_reachable_troop()
		
func find_nearest_reachable_troop():
	var troops = troop_manager.sorted_opponents_by_attack()
	for troop in troops:
		var pos = ai_finder.find_nearest_reachable_position(current_troop, troop.global_position)
		if pos:
			return pos
	
func get_opponent_in_base_pos():
	for base in spawner.spawn_points:
		var tile_pos = grid_controller.tile_grid.local_to_map(base.global_position) 
		var entity : Entity = grid_controller.get_entity_in_pos(tile_pos)
		if entity and entity.faction == Entity.EntityFaction.ALLY:
				
			var pos = grid_controller.get_pos_to_troop(
				current_troop.global_position,
				entity.global_position,
				current_troop.get_current_walk_points()
				)
			
			return pos
				
	return null
