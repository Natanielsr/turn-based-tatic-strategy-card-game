extends DeckBase

class_name DeckPlayer

const CARD_SCENE_PATH = "res://prefabs/card.tscn"
@onready var card_scene = preload(CARD_SCENE_PATH)
@onready var player_hand: PlayerHand = $"../PlayerHand"


func _ready() -> void:
	_base_ready()
	$RichTextLabel.text = str(deck.size())
	
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
		"dragon"
		]
	
func draw_card_after(card_drawn_name):
	
	if deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
	
	$RichTextLabel.text = str(deck.size())
	
	var new_card = create_card(card_drawn_name)
	card_manager.add_child(new_card)
	
	$"../PlayerHand".add_card_to_hand(new_card)
	new_card.get_node("AnimationPlayer").play("card_flip")
	
	$AudioStreamPlayer2D.play()

func create_card(card_name):
	var new_card : Card = card_scene.instantiate()
	
	var card_data = game_controller.card_database.CARDS[card_name]
	new_card.set_card_data(card_data, Entity.EntityFaction.ALLY)
	
	new_card.position = position
	
	new_card.z_index = card_manager.Z_INDEX_CARD
	
	return new_card

func is_my_turn():
	if turn_controller.turn == Turn.PLAYER:
		return true
	else:
		return false
		
func count_cards_hand():
	return player_hand.hand.size()
