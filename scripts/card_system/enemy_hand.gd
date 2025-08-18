extends Node2D

class_name EnemyHand

const HAND_Y_POSITION = 0
const CARD_WIDTH = 10

const CARD_SCENE_PATH = "res://prefabs/card.tscn"

@onready var game_controller: GameController = $"../../Controllers/GameController"

var hand : Array[Card] = []

var center_cards_x = global_position.x

func init():
	hand = []
	
func _ready() -> void:
	center_cards_x = global_position.x

func add_card_to_hand(card_id):
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
	
func remove_card_from_hand(card: Card):
	if card in hand:
		hand.erase(card)
		card.queue_free()
		update_hand_position()

func remove_card_id_from_hand(card_id):
	for card in hand:
		if card.card_id == card_id:
			remove_card_from_hand(card)

func update_hand_position():
	for i in range(hand.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = hand[i]
		card.start_position = new_position
		animate_card_to_position(card, new_position)
	
		
func calculate_card_position(index):
	var total_width = (hand.size() -1) * CARD_WIDTH
	var x_offset = -(total_width/2)  + (index * CARD_WIDTH)
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

func is_card_in_hand(card : Card):
	if hand.has(card):
		return true
	else:
		return false
