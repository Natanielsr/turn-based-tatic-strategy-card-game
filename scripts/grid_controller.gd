extends Node

class_name GridController

@onready var tile_grid: TileMapLayer = $"../TileGrid"

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
				
func calculate_path(start : Vector2, end : Vector2) -> Array[Vector2i]:

	if not is_walkable_tile(tile_grid.local_to_map(end)):
		return []
		
	var destination = tile_grid.local_to_map(end)
	print(destination)
	var id_path = astar_grid.get_id_path(
		tile_grid.local_to_map(start),
		tile_grid.local_to_map(end)
	).slice(1)
	
	return id_path
	
func calculate_point_path(start : Vector2, end : Vector2) -> PackedVector2Array:
	
	if not is_walkable_tile(tile_grid.local_to_map(end)):
		return []
		
	var current_point_path = astar_grid.get_point_path(
		tile_grid.local_to_map(start),
		tile_grid.local_to_map(end)
	)
	
	for i in current_point_path.size():
		current_point_path[i] = current_point_path[i] + Vector2(16, 16)
		
	return current_point_path
	
func is_walkable_tile(tile_position):
	var tile_data = tile_grid.get_cell_tile_data(tile_position)			
	if tile_data == null:
		return false
	elif tile_data.get_custom_data("walkable") == false:
		return false
	else:
		return true
	
func get_tile_data(tile_position):
	var tile_data = tile_grid.get_cell_tile_data(tile_position)	
	return tile_data
