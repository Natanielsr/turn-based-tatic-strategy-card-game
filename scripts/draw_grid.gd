extends Control

@onready var grid_controller: GridController = get_node("/root/Base/Controllers/GridController")
@onready var tile_grid: TileMapLayer = get_node("/root/Base/Tiles/TileGrid")
@onready var game_controller: GameController = get_node("/root/Base/Controllers/GameController")

var target_position

func _process(_delta: float) -> void:
	queue_redraw()

func _draw():
	draw_possible_path()
	draw_mouse_position_rect()
	draw_path()
	
func draw_possible_path():
	if game_controller.selected_troop == null:
		return
		
	if game_controller.current_troop_state() != MobileTroop.TroopState.WALK:
		return
		
	if game_controller.has_troop_moving():
		return
		
	var current_mouse_path = grid_controller.calculate_point_path(
		game_controller.selected_troop.global_position,
		get_global_mouse_position()
	)
	game_controller.possible_path = current_mouse_path
	
	if current_mouse_path == null or current_mouse_path.is_empty():
		return
	
	#not include de actual path
	if current_mouse_path.size() - 1 > game_controller.selected_troop.get_current_walk_points():
		return

	var color = Color(0, 0, 0, 0.5)  # trace color
	draw_polyline(current_mouse_path, color, 4)
	
func draw_path():
	if not game_controller.has_troop_moving():
		return
	
	#calculate points to draw	
	var point_path = grid_controller.calculate_point_path(
		game_controller.selected_troop.started_walk_position,
		game_controller.selected_troop.clicked_target_position)
	
	var color = Color(1, 1, 1, 0.5)
	draw_polyline(point_path, color, 4)
	
func draw_mouse_position_rect():
	
	if game_controller.action_buttons.visible:
		return
	
	target_position = get_tile_grid_mouse_position()
		
	if not target_position: #no target
		return	
	# Converte a posição do tile de volta para coordenadas globais
	var tile_pixel_position = tile_grid.map_to_local(target_position)		
			
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
		
	
	
