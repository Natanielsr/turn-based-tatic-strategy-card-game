extends Hand

class_name PlayerHand

const HAND_Y_POSITION : float = 210
const CHOOSE_Y_POSITION : float = 100
const CARD_WIDTH = 80

@onready var game_controller: GameController = $"../../Controllers/GameController"

func _ready() -> void:
	center_cards_x = get_world_center().x

func get_y_pos():
	if game_controller.is_choose_card_state():
		return CHOOSE_Y_POSITION
	else:
		return HAND_Y_POSITION
		
func get_card_width():
	return CARD_WIDTH

func get_world_center():
	# Método mais confiável para pegar a câmera atual
	var camera : Camera2D = get_viewport().get_camera_2d()
	if camera:
		return camera.get_screen_center_position()
	else:
		push_error('No camera')
