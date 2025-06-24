extends Node2D

class_name Deck

var player_deck = ["hobgoblin", "goblin", "healing_spell"]
const CARD_SCENE_PATH = "res://prefabs/card.tscn"
const card_database = preload("res://scripts/card_database.gd")

func _ready() -> void:
	player_deck.shuffle()
	$RichTextLabel.text = str(player_deck.size())
	

func draw_card():
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
	
	$RichTextLabel.text = str(player_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_data = card_database.CARDS[card_drawn_name]
	var card_image_path = str("res://textures/cards/"+card_drawn_name+".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.get_node("Name").text = str(card_data.name)
	new_card.get_node("Energy").text = str(card_data.energy_cost)
	if card_data.type == "monster":
		new_card.get_node("Attack").text = str(card_data.attack)
		new_card.get_node("Health").text = str(card_data.health)
	else:
		new_card.get_node("Attack").visible = false 
		new_card.get_node("Health").visible = false
		new_card.get_node("CardTemplate/Atk").visible = false 
		new_card.get_node("CardTemplate/Life").visible = false
		
	new_card.position = position
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card)
	new_card.get_node("AnimationPlayer").play("card_flip")
