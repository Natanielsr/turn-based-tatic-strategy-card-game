extends DeckBase

class_name DeckEnemy
@onready var enemy_ai: EnemyAI = $".."

func _ready() -> void:
	_base_ready()
	
func load_deck():
	deck = ["hobgoblin", "hobgoblin", "goblin", "healing_spell", "goblin"]

func draw_card_after(card_drawn_name):
	enemy_ai.add_card_to_hand(card_drawn_name)
	print("Enemy Draw a card: ",card_drawn_name)
	
	
func is_my_turn():
	if game_controller.turn == GameController.Turn.ENEMY:
		return true
	else:
		return false
