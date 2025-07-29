extends Node

class_name AIFinder

@onready var attack_area = get_attack_points()
@onready var grid_controller: GridController = $"../../Controllers/GridController"
@onready var troop_manager: TroopManager = $"../../TroopManager"

func init():
	var attack_area_pos = [
		Vector2(0,0),
		Vector2(0,0),
		Vector2(0,0),
		Vector2(0,0),
	]
	attack_area = []
	
	for pos in attack_area_pos:	
		var area = Node2D.new()
		area.global_position = pos
		attack_area.append(area)
		
	grid_controller = GridController.new()
	grid_controller.init()

func get_attack_points():
	return $"../AttackArea".get_children()

func closest_area_to_attack(troop):
	var min_distance = null
	var closest_marker = null
	
	for marker in attack_area:
		if grid_controller.is_walkable_position(marker.global_position):
			var distance = grid_controller.get_distance(
				troop.global_position,
				marker.global_position)
				
			if not min_distance:
				min_distance = distance
				closest_marker = marker
				
			if distance <= min_distance:
				min_distance = distance
				closest_marker = marker
				
	return closest_marker
	
func closest_opponent(troop):
	var closest_troop : MobileTroop = null
	var current_distance = 9999
	for monster : MobileTroop in troop_manager.player_troops:
		if not closest_troop:
			closest_troop = monster
			
		var distance = grid_controller.get_distance(
			troop.global_position,
			monster.global_position
		)
		
		if distance < current_distance:
			current_distance = distance
			closest_troop = monster
	
	return closest_troop
	
func close_opponent_position(troop):
	var close_opponent = closest_opponent(troop)
	if close_opponent:
		return close_opponent.global_position
	else:
		return null
	
func weakest_opponent(troop):
	var weakest_troop : MobileTroop = null
	for monster : MobileTroop in troop_manager.sorted_opponents_by_distance(troop):
		if not weakest_troop:
			weakest_troop = monster
			
		if monster.attack_points < weakest_troop.attack_points:
			weakest_troop = monster
			
	return weakest_troop
	
func get_strongest_monster():
	var strongest_monster : MobileTroop = null
	
	for monster : MobileTroop in troop_manager.enemy_troops:
		if not strongest_monster:
			strongest_monster = monster
			
		if monster.attack_points > strongest_monster.attack_points:
			strongest_monster = monster
	
	return strongest_monster

func find_nearest_reachable_position(troop, target_pos):
	
	var walk_points = troop.get_current_walk_points()
	
	return grid_controller.find_best_reachable_target(
		troop.global_position,
		target_pos,
		walk_points
	)
	
func in_attack_area_pos(troop):
	for marker in attack_area:
		var tile_grid = grid_controller.tile_grid
		var mon_pos = tile_grid.local_to_map(troop.global_position) 
		var mark_pos = tile_grid.local_to_map(marker.global_position)
		if mon_pos == mark_pos:
			return true
			
				
func get_weakest_target_in_range(selected_troop : MobileTroop):
	
	var tile_pos: Vector2i = grid_controller.tile_grid.local_to_map(selected_troop.global_position)
	
	var max_radius := 1

	var best_target : MobileTroop = null
	
	for x_offset in range(-max_radius, max_radius + 1):
		for y_offset in range(-max_radius, max_radius + 1):
			var test_pos = tile_pos + Vector2i(x_offset, y_offset)

			# Ignora se não for ponto válido no grid
			if not grid_controller.in_bounds(test_pos):
				continue
			
			var test_target : MobileTroop = grid_controller.get_entity_in_pos(test_pos)
			
			if test_target:
				if test_target.faction == selected_troop.faction:
					continue
					
				if not best_target:
					best_target = test_target
				
				if test_target.attack_points < best_target.attack_points:
					best_target = test_target
	
	return best_target
	
func get_attackable_targets(troop: MobileTroop) -> Array[Entity]:
	var tile_pos: Vector2i = grid_controller.tile_grid.local_to_map(troop.global_position)
	
	var max_radius := 1
	var attackable_targets : Array[Entity] = []
	
	for x_offset in range(-max_radius, max_radius + 1):
		for y_offset in range(-max_radius, max_radius + 1):
			var test_pos = tile_pos + Vector2i(x_offset, y_offset)

			# Ignora se não for ponto válido no grid
			if not grid_controller.in_bounds(test_pos):
				continue
			
			var test_target : Entity = grid_controller.get_entity_in_pos(test_pos)
			
			if not test_target:
				continue
			
			if test_target.faction == troop.faction:
				continue
				
			var provoker = troop.get_provoker()
			if provoker == null:
				attackable_targets.append(test_target)
			else:
				if provoker == test_target:
					attackable_targets.append(test_target)
				
	
	return attackable_targets

func get_attack_player_tiles():
	var valid_tiles = []
	for marker in attack_area:
		var tile_pos = grid_controller.get_world_to_tile_pos(marker.global_position)
		valid_tiles.append(tile_pos)
		
	return valid_tiles
