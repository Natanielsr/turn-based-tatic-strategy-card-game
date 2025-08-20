extends Node2D

class_name ChooseStartCards

var deck: Deck
var hand: Hand 

@onready var sound_fx: SoundFX = get_node("/root/Base/Sound/SoundFX")
const CUCKOO = preload("res://sounds/Cardsounds/cockatrice/cuckoo.wav")
const TAP = preload("res://sounds/Cardsounds/cockatrice/tap.wav")
var cards = []
var selected_cards = []

func set_deck_and_hand(_deck: Deck, _hand: Hand) -> void:
	self.deck = _deck
	self.hand = _hand

func _ready() -> void:
	choose()

func choose():
	for i in range(3):
		await Waiter.wait(0.2)
		var card : Card = deck.draw_card()
		cards.append(card)
		
func mark_a_card(card : Card):
	if card not in selected_cards:
		card.get_node("RemoveSprite").visible = true
		selected_cards.append(card)
	else:
		card.get_node("RemoveSprite").visible = false
		selected_cards.erase(card)
		
	sound_fx.play_temp_sound(TAP, self.position)

func confirm_choose() -> void:
	
	for card : Card in selected_cards:
		hand.remove_card_from_hand(card)
		card.queue_free()
		
	deck.draw_cards(selected_cards.size())
		
	sound_fx.play_temp_sound(CUCKOO, self.position)
	hand.update_hand_position()
