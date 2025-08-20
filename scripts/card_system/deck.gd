extends Node2D

class_name Deck

var deck = []

@onready var card_manager: CardManager = get_node("/root/Base/CardSystem/CardManager")
@onready var game_controller: GameController = get_node("/root/Base/Controllers/GameController")
@onready var turn_controller: TurnController = get_node("/root/Base/Controllers/TurnController")
const Turn = TurnController.Turn

@onready var sound_fx: SoundFX = get_node("/root/Base/Sound/SoundFX")
const DRAW = preload("res://sounds/Cardsounds/cockatrice/draw.wav")

var cards_to_drawn = 3

func _base_ready() -> void:
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
	
func draw_card():
	
	if cards_to_drawn == 0:
		push_error("ERROR: cant draw, cards to draw is 0")
		return
	
	if deck.size() == 0:
		return
	
	var card_drawn_name = deck[0]
	#deck.erase(card_drawn_name)
	deck.shuffle()
	
	cards_to_drawn -= 1
	
	sound_fx.play_temp_sound(DRAW, self.position)
	
	#card_manager.add_card_to_hand(card_drawn_name)
	return draw_card_after(card_drawn_name)
	
func draw_cards(quantity : int):
	cards_to_drawn = quantity
	for i in range(cards_to_drawn):
		await Waiter.wait(0.3)
		draw_card()

func draw_card_after(_card_drawn_name):
	pass
