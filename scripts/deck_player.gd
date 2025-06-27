extends DeckBase

class_name DeckPlayer

const CARD_SCENE_PATH = "res://prefabs/card.tscn"
@onready var card_scene = preload(CARD_SCENE_PATH)

func _ready() -> void:
	_base_ready()
	$RichTextLabel.text = str(deck.size())
	
func load_deck():
	deck = ["hobgoblin", "hobgoblin", "goblin", "healing_spell", "goblin"]
	
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

func create_card(card_name):
	
	var new_card : Card = card_scene.instantiate()
	
	var card_data = game_controller.card_database.CARDS[card_name]
	
	new_card.card_id = card_name
	var card_image_path = str("res://textures/cards/"+card_name+".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.get_node("Name").text = str(card_data.name)
	new_card.get_node("Energy").text = str(card_data.energy_cost)
	new_card.type = card_data.type
	if card_data.type == "monster":
		new_card.get_node("Attack").text = str(card_data.attack)
		new_card.attack_points = int(card_data.attack)
		new_card.get_node("Health").text = str(card_data.health)
		new_card.life_points = int(card_data.health)
	else:
		new_card.get_node("Attack").visible = false 
		new_card.get_node("Health").visible = false
		new_card.get_node("CardTemplate/Atk").visible = false 
		new_card.get_node("CardTemplate/Life").visible = false
		
	new_card.position = position
	new_card.z_index = card_manager.Z_INDEX_CARD
	new_card.name = str(card_data.name)
	
	return new_card

func is_my_turn():
	if game_controller.turn == GameController.Turn.PLAYER:
		return true
	else:
		return false
