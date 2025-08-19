extends Node2D

class_name ChooseCards

const CARD_SCENE_PATH = "res://prefabs/card.tscn"
@onready var deck_player: DeckPlayer = $"../DeckPlayer"
@onready var player_hand: PlayerHand = $"../PlayerHand"
@onready var game_controller: GameController = $"../../Controllers/GameController"
@onready var choose_btn: Button = $ChooseBtn

@onready var sound_fx: SoundFX = get_node("/root/Base/Sound/SoundFX")
const CUCKOO = preload("res://sounds/Cardsounds/cockatrice/cuckoo.wav")

var cards = []
var select_cards = []

func _ready() -> void:
	choose()

func choose():
	
	for i in range(3):
		await Waiter.wait(0.3)
		var card : Card = deck_player.draw_card()
		cards.append(card)
	
	await Waiter.wait(0.3)
	$ChooseBtn.visible = true
		
func mark_a_card(card : Card):
	if card not in select_cards:
		card.get_node("RemoveSprite").visible = true
		select_cards.append(card)
	else:
		card.get_node("RemoveSprite").visible = false
		select_cards.erase(card)

func _on_choose_btn_pressed() -> void:
	$ChooseBtn.visible = false
	
	for card : Card in select_cards:
		player_hand.remove_card_from_hand(card)
		card.remove_card()
		
	deck_player.draw_cards(select_cards.size())
		
	sound_fx.play_temp_sound(CUCKOO, self.position)
	game_controller.change_game_state(GameController.GameState.RUNNING)
	player_hand.update_hand_position()
	
