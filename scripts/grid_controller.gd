extends Node

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
			if not is_walkable_tile(tile_position):
				astar_grid.set_point_solid(tile_position)
				
func set_walkable_position(position : Vector2, walkable : bool):
	if not in_bounds(position):
		return false
		
	var tile_position = tile_grid.local_to_map(position)
	astar_grid.set_point_solid(tile_position, not walkable)
	
func is_walkable_position(position: Vector2):
	if not in_bounds(position):
		print("out bounds")
		return false
		
	var tile_position = tile_grid.local_to_map(position)
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
	
	return path.size()
	
func get_distance_to_attack_in_diagonal(point_a: Vector2, point_b : Vector2):
	var aux_mode = astar_grid.diagonal_mode
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
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
		
	var current_point_path = astar_grid.get_point_path(
		tile_grid.local_to_map(start),
		tile_grid.local_to_map(end)
	)
	
	for i in current_point_path.size():
		current_point_path[i] = current_point_path[i] + Vector2(16, 16)
		
	return current_point_path
	
func is_walkable_tile_position(position : Vector2) -> bool:
	return is_walkable_tile(tile_grid.local_to_map(position))
	
func is_walkable_tile(tile_position : Vector2i) -> bool:
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
		

		
func faction_area(pos : Vector2) -> int:
	var tile_data = get_data_pos(pos)
	
	if not tile_data:
		return 0
	elif tile_data.get_custom_data("faction_area") == 1:
		return 1 #ALLY
	elif tile_data.get_custom_data("faction_area") == 2:
		return 2 #ENEMY
	else:
		return 0
	
func get_data_pos(pos : Vector2):
	var tile_pos = tile_grid.local_to_map(pos)
	var tile_data = tile_grid.get_cell_tile_data(tile_pos)	
	return tile_data
	
func get_tile_data(tile_position : Vector2i):
	var tile_data = tile_grid.get_cell_tile_data(tile_position)	
	return tile_data


func _on_move_btn_pressed() -> void:
	pass # Replace with function body.
	
func is_achievable_path(start : Vector2, end : Vector2, walk_points : int):
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
	
