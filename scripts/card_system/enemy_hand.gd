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

func add_card_to_hand(card_id) -> Card:
	var card : Card = preload(CARD_SCENE_PATH).instantiate()
	var card_data = game_controller.card_database.CARDS[card_id]
	card.get_node("Area2D").get_node("CollisionShape2D").disabled = true
	card.get_node("CardBackImage").visible = false
	card.get_node("Name").visible = false
	card.get_node("Energy").visible = false
	card.get_node("Attack").visible = false
	card.get_node("Health").visible = false
	card.get_node("CardBackImageEnemy").visible = true
	card.scale = Vector2(0.3, 0.3)
	card.set_card_data(card_data, Entity.EntityFaction.ENEMY)
	hand.append(card)
	add_child(card)
	card.global_position = Vector2(global_position.x + 50, global_position.y)
	
	update_hand_position()
	animate_card_to_position(card, card.start_position)
	
	return card

func remove_card_id_from_hand_and_animate(card_id, pos):
	
	for card in hand:
		if card.card_id == card_id:
			animate_card_to_position(card, pos)
			remove_card_from_hand(card)
			break
		
func calculate_card_position(index):
	var total_width = (hand.size() -1) * CARD_WIDTH
	var x_offset = -(total_width/2)  + (index * CARD_WIDTH)
	return x_offset
