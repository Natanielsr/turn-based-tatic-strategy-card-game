extends Node2D

class_name GridController

@onready var tile_grid: TileMapLayer = $"../../Tiles/TileGrid"

var astar_grid: AStarGrid2D

func _ready() -> void:
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_grid.get_used_rect()
	astar_grid.cell_size = Vector2(32, 32)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	set_walkble_tiles()
	
func set_walkble_tiles():
	for x in tile_grid.get_used_rect().size.x:
		for y in tile_grid.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tile_grid.get_used_rect().position.x,
				y + tile_grid.get_used_rect().position.y
			)	 
			if not is_walkable_tile_data(tile_position):
				astar_grid.set_point_solid(tile_position)
				
func set_walkable_position(pos : Vector2, walkable : bool):
	if not in_bounds(pos):
		return false
		
	var tile_position = tile_grid.local_to_map(pos)
	astar_grid.set_point_solid(tile_position, not walkable)
	
func is_walkable_position(pos: Vector2):
	if not in_bounds(pos):
		print("out bounds")
		return false
		
	var tile_position = tile_grid.local_to_map(pos)
	var is_solid = astar_grid.is_point_solid(tile_position)
	return not is_solid
	
func in_bounds (pos: Vector2):
	var map_pos = tile_grid.local_to_map(pos)
	if astar_grid.is_in_bounds(map_pos.x, map_pos.y):
		return true
	else:
		return false
				
func calculate_path(start : Vector2, end : Vector2) -> Array[Vector2i]:

	if not is_walkable_tile_position(end):
		return []
		
	if not is_walkable_position(end):
		print("not walkable position ", end)
		return []
		
	var id_path = astar_grid.get_id_path(
		tile_grid.local_to_map(start),
		tile_grid.local_to_map(end)
	).slice(1)
	
	return id_path
	
func calculate_path_to_target(point_a : Vector2, point_b : Vector2):
	
	var walkable_aux = is_walkable_position(point_b)
	
	set_walkable_position(point_b, true)
	var path = astar_grid.get_id_path(
		tile_grid.local_to_map(point_a),
		tile_grid.local_to_map(point_b)
	).slice(1)
	set_walkable_position(point_b, walkable_aux)
	
	return path
	
	
func get_distance(point_a: Vector2, point_b : Vector2):
	
	if not in_bounds( point_a):
		push_error("Cant get distance of point a out of bounds")

	if not in_bounds(point_b):
		push_error("Cant get distance of point b out of bounds")

	var walkable_aux = is_walkable_position(point_b)
	set_walkable_position(point_b, true)
	var path = astar_grid.get_id_path(
		tile_grid.local_to_map(point_a),
		tile_grid.local_to_map(point_b)
	).slice(1)
	set_walkable_position(point_b, walkable_aux)
	
	if path.size() > 0:
		return path.size()
	else:
		return INF
	
func get_distance_to_attack_in_diagonal(point_a: Vector2, point_b : Vector2):
	var aux_mode = astar_grid.diagonal_mode
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	astar_grid.update()
	var distance = get_distance(point_a, point_b)
	astar_grid.diagonal_mode = aux_mode
	astar_grid.update()
	
	return distance
	
func calculate_point_path(start : Vector2, end : Vector2) -> PackedVector2Array:
	
	if not is_walkable_tile_position(end):
		return []
		
	if not is_walkable_position(end):
		return []
	
	if not in_bounds(start):
		print("start position out bounds: ",start)
		return []
		
	if not in_bounds(end):
		print("end position out bounds: ",end)
		return []
		
	var current_point_path = astar_grid.get_point_path(
		tile_grid.local_to_map(start),
		tile_grid.local_to_map(end)
	)
	
	for i in current_point_path.size():
		current_point_path[i] = current_point_path[i] + Vector2(16, 16)
		
	return current_point_path
	
func is_walkable_tile_position(pos : Vector2) -> bool:
	return is_walkable_tile_data(tile_grid.local_to_map(pos))
	
func is_walkable_tile_data(tile_position : Vector2i) -> bool:
	var tile_data = tile_grid.get_cell_tile_data(tile_position)	
	
	if tile_data == null:
		return false
	elif tile_data.get_custom_data("walkable") == false:
		return tile_data.get_custom_data("walkable")
	else:
		return true
		
func is_base_area(pos : Vector2) -> bool:
	var tile_data = get_data_pos(pos)	
	if not tile_data:
		return false
	elif tile_data.get_custom_data("base_area") == true:
		return true
	else:
		return false
		
func get_tile_world_position(pos: Vector2):
	if not in_bounds(pos):
		return null
	var tile_pos = tile_grid.local_to_map(pos)
	var world_tile_pos = tile_grid.map_to_local(tile_pos)
	
	return world_tile_pos
		
func get_faction_area(pos : Vector2) -> Entity.EntityFaction:
	var tile_data = get_data_pos(pos)
	
	if not tile_data:
		return Entity.EntityFaction.NONE
	elif tile_data.get_custom_data("faction_area") == 1:
		return Entity.EntityFaction.ALLY #ALLY
	elif tile_data.get_custom_data("faction_area") == 2:
		return Entity.EntityFaction.ENEMY #ENEMY
	else:
		return Entity.EntityFaction.NONE
	
func get_data_pos(pos : Vector2):
	var tile_pos = tile_grid.local_to_map(pos)
	var tile_data = tile_grid.get_cell_tile_data(tile_pos)	
	return tile_data
	
func get_tile_data(tile_position : Vector2i):
	var tile_data = tile_grid.get_cell_tile_data(tile_position)	
	return tile_data

	
func is_achievable_path_with_walk_points(start : Vector2, end : Vector2, walk_points : int):
	var temp_path = calculate_point_path(
		start,
		end
	)
	
	if temp_path == null or temp_path.is_empty():
		return false
	
	#not include de actual path
	if temp_path.size() - 1 > walk_points:
		return false
		
	return true
	
func is_achievable_path(start : Vector2, end : Vector2):
	var temp_path = calculate_point_path(
		start,
		end
	)
	
	#not include de actual path
	if temp_path.size() > 0:
		return true
	else:	
		return false
		
func is_achievable_troop(start : Vector2, end : Vector2):
	
	if not in_bounds( start):
		push_error("Cant get start out of bounds")

	if not in_bounds(end):
		push_error("Cant get end out of bounds")

	var walkable_aux = is_walkable_position(end)
	
	set_walkable_position(end, true)
	var path = astar_grid.get_id_path(
		tile_grid.local_to_map(start),
		tile_grid.local_to_map(end)
	).slice(1)
	set_walkable_position(end, walkable_aux)
	
	#not include de actual path
	if path.size() > 0:
		return true
	else:	
		return false
	
func find_best_reachable_target(point_a: Vector2, point_b: Vector2, walk_points) -> Vector2:
	
	var start_pos: Vector2i = tile_grid.local_to_map(point_a)
	var target_pos: Vector2i = tile_grid.local_to_map(point_b)
	
	var max_radius := 1
	var path := astar_grid.get_id_path(start_pos, target_pos)
	if path.size() > 0:
		if path.size() > walk_points:
			path.resize(walk_points)
		return tile_grid.map_to_local(path.back())   # Caminho direto disponível

	var best_pos := start_pos
	var min_dist := INF
	var best_path = []
	for x_offset in range(-max_radius, max_radius + 1):
		for y_offset in range(-max_radius, max_radius + 1):
			var test_pos = target_pos + Vector2i(x_offset, y_offset)

			# Ignora se não for ponto válido no grid
			if not astar_grid.is_in_bounds(test_pos.x, test_pos.y):
				continue

			# Ignora se ponto estiver desabilitado
			if astar_grid.is_point_solid(test_pos):
				continue

			var test_path = astar_grid.get_id_path(start_pos, test_pos)
			if test_path.size() == 0:
				continue  # Sem caminho até aqui

			var dist_to_player = test_pos.distance_to(target_pos)
			if dist_to_player < min_dist:
				min_dist = dist_to_player
				best_pos = test_pos
				best_path = test_path
	
	if best_path.size() > walk_points:
		best_path.resize(walk_points)
	
	if best_path.size() > 0:
		best_pos = best_path.back()
				
	return tile_grid.map_to_local(best_pos) 

func get_valid_move_tiles(troop: MobileTroop) -> Array[Vector2i]:
	var radius: int = troop.get_current_walk_points()
	var center_tile_pos: Vector2i = troop.get_tile_pos()
	var valid_tiles: Array[Vector2i] = []

	for x_offset in range(-radius, radius + 1):
		for y_offset in range(-radius, radius + 1):
			var test_pos = center_tile_pos + Vector2i(x_offset, y_offset)
			if test_pos == center_tile_pos:
				continue
			if not astar_grid.is_in_bounds(test_pos.x, test_pos.y):
				continue
			if astar_grid.is_point_solid(test_pos):
				continue
			# Verifica se é alcançável com os pontos de movimento
			var path = astar_grid.get_id_path(center_tile_pos, test_pos)
			if path.size() == 0 or path.size() - 1 > radius:
				continue
			valid_tiles.append(test_pos)

	return valid_tiles
	
func get_last_pos_path_with_walk_points(point_a : Vector2, point_b : Vector2, walk_points : int):
	var start_pos: Vector2i = tile_grid.local_to_map(point_a)
	var target_pos: Vector2i = tile_grid.local_to_map(point_b)
	
	var path := astar_grid.get_id_path(start_pos, target_pos)
	if path.size() > 0:
		if path.size() > walk_points:
			path.resize(walk_points)
		return tile_grid.map_to_local(path.back())
	else:
		return null
		
func get_pos_to_troop(point_a : Vector2, point_b : Vector2, walk_points : int):
	var start_pos: Vector2i = tile_grid.local_to_map(point_a)
	var target_pos: Vector2i = tile_grid.local_to_map(point_b)
	
	var walkable_aux = is_walkable_position(point_b)
	
	set_walkable_position(point_b, true)
	var path = astar_grid.get_id_path(
		start_pos,
		target_pos
	).slice(1)
	set_walkable_position(point_b, walkable_aux)
	
	if path.size() > 0:
		path.pop_back()
		if path.size() > walk_points:
			path.resize(walk_points)
			
		if path.size() > 0:
			return tile_grid.map_to_local(path.back())
		else:
			return null
	else:
		return null

func get_entity_in_pos(tile_pos):
	var world_pos = tile_grid.map_to_local(tile_pos)  # se estiver usando TileMap
	var space_state = get_world_2d().direct_space_state

	var params = PhysicsPointQueryParameters2D.new()
	params.position = world_pos
	params.collide_with_areas = true
	params.collide_with_bodies = true

	var result = space_state.intersect_point(params, 1)
	if result.size() > 0:
		var collider = result[0].collider
		if collider is Entity:
			return collider
		
	return null
	
func get_world_to_tile_pos(pos : Vector2):
	return tile_grid.local_to_map(pos)
	
func get_tile_to_world_pos(pos : Vector2i):
	return tile_grid.map_to_local(pos)
