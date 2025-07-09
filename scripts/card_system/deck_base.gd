extends Node2D

class_name DeckBase

var deck = []

@onready var card_manager: CardManager = get_node("/root/Base/CardSystem/CardManager")
@onready var game_controller: GameController = get_node("/root/Base/Controllers/GameController")
@onready var turn_controller: TurnController = get_node("/root/Base/Controllers/TurnController")
const Turn = TurnController.Turn

var cards_to_drawn = 3

func _base_ready() -> void:
	turn_controller.connect("changed_turn", Callable(self, "_on_changed_turn"))
	load_deck()
	deck.shuffle()
	
	
	for i in cards_to_drawn:
		draw_card()

func _on_changed_turn(_turn: GameController.Turn):
	if is_my_turn():
		cards_to_drawn = 1
		draw_card()
		
func is_my_turn():
	return false

func load_deck():
	pass
	
func draw_card():
	
	if cards_to_drawn == 0:
		return
	
	if deck.size() == 0:
		return
	
	var card_drawn_name = deck[0]
	#deck.erase(card_drawn_name)
	deck.shuffle()
	
	cards_to_drawn -= 1
	
	#card_manager.add_card_to_hand(card_drawn_name)
	draw_card_after(card_drawn_name)
	

func draw_card_after(_card_drawn_name):
	pass
