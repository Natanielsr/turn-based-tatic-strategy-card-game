extends Deck

class_name DeckPlayer

@onready var player_hand: PlayerHand = $"../PlayerHand"

func _ready() -> void:
	super._ready()
	$RichTextLabel.text = str(deck.size())
	set_hand(player_hand)
	
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
	
func draw_card_after(new_card : Card):
	
	if deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
	
	$RichTextLabel.text = str(deck.size())
	
	card_manager.add_child(new_card)
	
	new_card.get_node("AnimationPlayer").play("card_flip")
	
	return new_card

func is_my_turn():
	if turn_controller.turn == Turn.PLAYER:
		return true
	else:
		return false
		
func count_cards_hand():
	return player_hand.hand.size()
