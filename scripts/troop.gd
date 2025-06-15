extends Node2D

class_name Troop

@onready var tile_grid: TileMapLayer = $"../TileGrid"
@onready var grid_controller: GridController = $"../GridController"

var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array
var target_position: Vector2
var is_moving: bool

func _ready() -> void:
	pass
			
	
func _input(event):
	if event.is_action_pressed("left_click") == false:
		return
		
	if is_moving:
		return
		
	#calculate the path
	var id_path = grid_controller.calculate_path(global_position, get_global_mouse_position())
	
	if id_path == null or id_path.is_empty():
		return
		
	current_id_path = id_path
	current_point_path = grid_controller.calculate_point_path(global_position, get_global_mouse_position())
	
func _physics_process(delta: float) -> void:
	if current_id_path.is_empty(): #verify have path
		return
		
	if is_moving == false:
		target_position = tile_grid.map_to_local(current_id_path.front())
		is_moving = true
	
	#move the troop	
	global_position = global_position.move_toward(target_position, 1)
	
	#arrived in position
	if global_position == target_position:
			current_id_path.pop_front() #remove the position
			
			if not current_id_path.is_empty(): #verify if have next position
				target_position = tile_grid.map_to_local(current_id_path.front()) #pass to next position
			else:
				is_moving = false
		
