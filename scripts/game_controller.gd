extends Node2D

class_name GameController

var selected_troop : MobileTroop

@onready var grid_controller: GridController = $"../GridController"
var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array

func _input(event):
	if event.is_action_pressed("left_click"):
		if selected_troop == null:
			select_troop()
		else:
			move_troop()
			
	if event.is_action_pressed("right_click"):
		
		if selected_troop != null and not selected_troop.is_moving:
			selected_troop = null
			
func move_troop():
	if selected_troop.is_moving:
		return
		
	#calculate the path
	var id_path = grid_controller.calculate_path(
		selected_troop.global_position,
		get_global_mouse_position())
	
	if id_path == null or id_path.is_empty():
		return
	
	#calculate points to draw	
	current_id_path = id_path
	
	current_point_path = grid_controller.calculate_point_path(
		selected_troop.global_position,
		get_global_mouse_position())
	
	selected_troop.move_troop(current_id_path)		

func select_troop():
	
	var mouse_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = mouse_pos
	params.collide_with_areas = true  # Se quiser detectar Area2D
	#params.collide_with_bodies = true  # Se quiser detectar PhysicsBody2D
	var result = space_state.intersect_point(params)
	if result.size() > 0:
		var clicked_node = result[0].collider
		
		if clicked_node is MobileTroop:
			selected_troop = clicked_node
			print("Tropa selecionada: ", selected_troop.name)
		else:
			print("O objeto clicado nao e uma tropa")
			
func has_troop_moving():
	if selected_troop == null:
		return false
		
	return selected_troop.is_moving
