# AgressiveStrategy.gd
extends AIStrategy

class_name AgressiveStrategy

func play_turn():
	await spawner.select_and_spawn_best_monster()
	await mover.move_all()
	
func move_trop_pos(troop):
	var pos_to_go
	
	if ai_finder.in_area_pos(troop):
		return null
		
	var close_area = ai_finder.closest_area_to_attack(troop)
	if close_area:
		var is_achievable_path = grid_controller.is_achievable_path(
			troop.global_position,
			close_area.global_position,
		)
		
		if is_achievable_path:
			pos_to_go = close_area.global_position
		else:
			pos_to_go = ai_finder.close_opponent_position(troop)
	else:
		pos_to_go = ai_finder.close_opponent_position(troop)
		
	return pos_to_go
