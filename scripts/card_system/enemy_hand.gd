extends Hand

class_name EnemyHand

const HAND_Y_POSITION = 0
const CARD_WIDTH = 10

const CARD_SCENE_PATH = "res://prefabs/card.tscn"

@onready var game_controller: GameController = $"../../Controllers/GameController"

func init():
	hand = []
	
func _ready() -> void:
	center_cards_x = global_position.x
	
func get_y_pos():
	return HAND_Y_POSITION
		
func get_card_width():
	return CARD_WIDTH
		
func calculate_card_position(index):
	var total_width = (hand.size() -1) * CARD_WIDTH
	var x_offset = -(total_width/2)  + (index * CARD_WIDTH)
	return x_offset
