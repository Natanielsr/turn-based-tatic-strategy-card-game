extends DeckBase

class_name DeckEnemy
@onready var enemy_ai: EnemyAI = $".."
@onready var enemy_hand: EnemyHand = $"../EnemyHand"


func _ready() -> void:
	_base_ready()
	
func load_deck():
	deck = [
		"rat",
		"rat",
		"spider",
		"spider",
		"wolf",
		"wolf",
		"goblin",
		"goblin",
		"hobgoblin",
		"hobgoblin",
		]

func draw_card_after(card_drawn_name):
	enemy_hand.add_card_to_hand(card_drawn_name)
	print("Enemy Draw a card: ",card_drawn_name)
	
func is_my_turn():
	if turn_controller.turn == Turn.ENEMY:
		return true
	else:
		return false
