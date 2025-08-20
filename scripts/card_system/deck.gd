extends Node2D

class_name Deck

var deck = []

const CARD_SCENE_PATH = "res://prefabs/card.tscn"

@onready var card_manager: CardManager = get_node("/root/Base/CardSystem/CardManager")
@onready var game_controller: GameController = get_node("/root/Base/Controllers/GameController")
@onready var turn_controller: TurnController = get_node("/root/Base/Controllers/TurnController")
const Turn = TurnController.Turn

@onready var sound_fx: SoundFX = get_node("/root/Base/Sound/SoundFX")
const DRAW = preload("res://sounds/Cardsounds/cockatrice/draw.wav")

var hand : Hand

var cards_to_drawn = 3

func _ready() -> void:
	turn_controller.connect("changed_turn", Callable(self, "_on_changed_turn"))
	load_deck()
	deck.shuffle()

func _on_changed_turn(_turn: GameController.Turn):
	if is_my_turn() and count_cards_hand() < 6:
		cards_to_drawn = 1
		draw_card()
		
func is_my_turn():
	pass #implements in children
	
func count_cards_hand():
	pass #implements in children

func load_deck():
	pass
	
func set_hand(_hand : Hand):
	self.hand = _hand
	
func draw_card():
	
	if cards_to_drawn == 0:
		push_error("ERROR: cant draw, cards to draw is 0")
		return
	
	if deck.size() == 0:
		return
	
	var card_drawn_name : String = deck[0]
	#deck.erase(card_drawn_name)
	deck.shuffle()
	
	cards_to_drawn -= 1
	
	sound_fx.play_temp_sound(DRAW, self.position)
	
	var new_card : Card = create_card(card_drawn_name)
	
	hand.add_card_to_hand(new_card)
	
	#card_manager.add_card_to_hand(card_drawn_name)
	return draw_card_after(new_card)
	
func create_card(card_name):
	var new_card : Card = preload(CARD_SCENE_PATH).instantiate()
	
	var card_data = game_controller.card_database.CARDS[card_name]
	new_card.set_card_data(card_data, Entity.EntityFaction.ALLY)
	
	new_card.position = position
	
	new_card.z_index = card_manager.Z_INDEX_CARD
	
	return new_card
	
func draw_cards(quantity : int):
	cards_to_drawn = quantity
	for i in range(cards_to_drawn):
		await Waiter.wait(0.3)
		draw_card()

func draw_card_after(_card : Card):
	pass
