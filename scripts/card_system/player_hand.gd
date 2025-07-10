extends Node2D

class_name PlayerHand

const CARD_WIDTH = 80
const HAND_Y_POSITION = 200

var player_hand = []
var center_screen_x

func _ready() -> void:
	center_screen_x = get_world_center().x
		
func add_card_to_hand(new_card):
	if new_card not in player_hand:
		player_hand.append(new_card)
		update_hand_position()
	else:
		animate_card_to_position(new_card, new_card.start_position)
	
func update_hand_position():
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.start_position = new_position
		animate_card_to_position(card, new_position)
	
		
func calculate_card_position(index):
	var total_width = (player_hand.size() -1) * CARD_WIDTH
	var x_offset = center_screen_x - total_width / 2.0 + index * CARD_WIDTH
	return x_offset

func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.2)

func get_world_center():
	# Método mais confiável para pegar a câmera atual
	var camera : Camera2D = get_viewport().get_camera_2d()
	if camera:
		return camera.get_screen_center_position()
	else:
		push_error('No camera')
	
func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_position()
