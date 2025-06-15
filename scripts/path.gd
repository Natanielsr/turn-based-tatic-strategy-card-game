extends Node2D

@onready var troop: Troop = $"../Troop"
@onready var grid_controller: GridController = $"../GridController"
@onready var tile_grid: TileMapLayer = $"../TileGrid"

func _process(delta: float) -> void:
	queue_redraw()

func _draw():
	draw_possible_path()
	draw_mouse_position_rect()
	draw_path()
	
func draw_possible_path():
	if troop.is_moving:
		return
	var current_mouse_path = grid_controller.calculate_point_path(troop.global_position, get_global_mouse_position())
	if current_mouse_path == null or current_mouse_path.is_empty():
		return	
	var color = Color(0, 0, 0, 0.5)  # Azul semi-transparente
	draw_polyline(current_mouse_path, color, 4)
	
func draw_path():
	if not troop.is_moving:
		return
	if troop.current_point_path.is_empty():
		return	
	var color = Color(1, 1, 1, 0.5)
	draw_polyline(troop.current_point_path, color, 4)
	
func draw_mouse_position_rect():
	var mouse_position = get_tile_grid_mouse_position()
	if mouse_position == null:
		return	
	# Converte a posição do tile de volta para coordenadas globais
	var tile_pixel_position = tile_grid.map_to_local(mouse_position)	
	var retangulo = Rect2(tile_pixel_position - Vector2(16, 16), Vector2(32, 32))
	var cor_preenchimento = Color(1, 1, 1, 0.5)  # Azul semi-transparente
	var cor_borda = Color(0, 0, 0, 0.5)  # Amarelo
	var largura_borda = 3.0
	# Preenchimento
	draw_rect(retangulo, cor_preenchimento, true)
	# Borda
	draw_rect(retangulo, cor_borda, false, largura_borda)
	
func get_tile_grid_mouse_position():
	var tile_mouse_position = tile_grid.local_to_map(get_global_mouse_position())
	var tile_data = tile_grid.get_cell_tile_data(tile_mouse_position)
	if not tile_data == null and tile_data.get_custom_data("walkable"):
		return tile_mouse_position
	else:
		return null
		
	
	
