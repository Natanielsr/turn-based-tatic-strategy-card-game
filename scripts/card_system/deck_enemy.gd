extends Deck

class_name DeckEnemy

@onready var enemy_hand: EnemyHand = $"../EnemyHand"

func _ready() -> void:
	super._ready()
	set_hand(enemy_hand)
	
func load_deck():
	deck = [
		"rat",
		"spider",
		"wolf",
		"goblin",
		"hobgoblin",
		"troll",
		"orc",
		"ogre",
		"elf_mage",
		"dragon",
		"giant_snail"
		]

func draw_card_after(card : Card):
	card.get_node("Area2D").get_node("CollisionShape2D").disabled = true
	card.get_node("CardBackImage").visible = false
	card.get_node("Name").visible = false
	card.get_node("Energy").visible = false
	card.get_node("Attack").visible = false
	card.get_node("Health").visible = false
	card.get_node("CardBackImageEnemy").visible = true
	card.scale = Vector2(0.3, 0.3)
	#card.global_position = Vector2(global_position.x + 50, global_position.y)
	
	hand.add_child(card)
	
	return card
	
func is_my_turn():
	if turn_controller.turn == Turn.ENEMY:
		return true
	else:
		return false

func count_cards_hand():
	return enemy_hand.hand.size()
