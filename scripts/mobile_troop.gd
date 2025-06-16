extends Node2D

class_name MobileTroop

@onready var tile_grid: TileMapLayer = $"../TileGrid"
@onready var game_controller: GameController = $"../GameController"
@onready var grid_controller: GridController = $"../GridController"


var target_position: Vector2
var is_moving: bool
var current_id_path: Array[Vector2i]
var moviment_speed : float = 1

func _ready() -> void:
	
	#define the actual poistion not walkable
	grid_controller.set_walkable_position(
		global_position,
		false
	)
			

func move_troop(id_path: Array[Vector2i]):
	if is_moving:
		return
	
	current_id_path = id_path
	
	if current_id_path.is_empty(): #verify have path
		return
	
	target_position = tile_grid.map_to_local(current_id_path.front())
	is_moving = true
	grid_controller.set_walkable_position(global_position, true)
	
func _physics_process(delta: float) -> void:
	if not is_moving:
		return
	
	#move the troop	
	global_position = global_position.move_toward(target_position, moviment_speed)
	
	#arrived in position
	if global_position == target_position:
		current_id_path.pop_front() #remove the position
		
		if not current_id_path.is_empty(): #verify if have next position
			target_position = tile_grid.map_to_local(current_id_path.front()) #pass to next position
		else:
			is_moving = false
			game_controller.selected_troop = null
			grid_controller.set_walkable_position(global_position, false)
		
