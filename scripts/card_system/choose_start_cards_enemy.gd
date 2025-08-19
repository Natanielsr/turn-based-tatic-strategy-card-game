extends Node2D

class_name ChooseStartCardsEnemy

const CARD_SCENE_PATH = "res://prefabs/card.tscn"

@onready var deck_enemy: DeckEnemy = $"../DeckEnemy"
@onready var enemy_hand: EnemyHand = $"../EnemyHand"

@onready var sound_fx: SoundFX = get_node("/root/Base/Sound/SoundFX")
const DRAW = preload("res://sounds/Cardsounds/cockatrice/draw.wav")

var cards = []
var select_cards = []

func _ready() -> void:
	choose()

func choose():
	
	for i in range(3):
		await Waiter.wait(0.3)
		var card : Card = deck_enemy.draw_card()
		cards.append(card)
	
	await Waiter.wait(0.3)
		
func mark_a_card(card : Card):
	if card not in select_cards:
		card.get_node("RemoveSprite").visible = true
		select_cards.append(card)
	else:
		card.get_node("RemoveSprite").visible = false
		select_cards.erase(card)


	
