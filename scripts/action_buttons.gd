extends Control

class_name ActionButtons

@onready var game_controller: GameController = get_node("/root/Base/Controllers/GameController")

func _on_move_btn_pressed() -> void:
	visible = false
	
	if not game_controller.selected_troop:
		return
	
	print(game_controller.selected_troop.name," Changed to WALK State")

func _on_atk_btn_pressed() -> void:
	visible = false
	
	if not game_controller.selected_troop:
		return
	
	
	print(game_controller.selected_troop.name, "Changed to ATTACK State")

		
