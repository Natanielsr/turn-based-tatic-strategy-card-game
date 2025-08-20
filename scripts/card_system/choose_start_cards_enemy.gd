extends ChooseStartCards

class_name ChooseStartCardsEnemy

const CARD_SCENE_PATH = "res://prefabs/card.tscn"

@onready var deck_enemy: DeckEnemy = $"../DeckEnemy"
@onready var enemy_hand: EnemyHand = $"../EnemyHand"

func _ready() -> void:
	super._ready()
	set_deck_and_hand(deck_enemy, enemy_hand)
	await Waiter.wait(0.8)
	select_cards()
	
func select_cards():
	for card : Card in cards:
		if card.energy_cost > 3:
			mark_a_card(card)
			await Waiter.wait(0.1)
			
	confirm_choose()
	
