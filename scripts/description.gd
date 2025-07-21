extends Control

@onready var card_manager: CardManager = $"../../CardSystem/CardManager"
var current_card

func _ready() -> void:
	card_manager.hovered_card_on.connect(_hovered_card_on)
	card_manager.hovered_card_off.connect(_hovered_card_off)
	card_manager.start_drag_card.connect(_on_drag_card)
	
func _hovered_card_on(card : Card):
	if current_card != null and current_card.is_dragging:
		visible = false
		return
	
	current_card = card
	visible = true
	var pos = Vector2(
		card.global_position.x - 90,
		card.global_position.y - 140
	)
	global_position = pos
	$Label.text = card.description
	
func _hovered_card_off(card):
	if current_card != null and current_card.is_dragging:
		visible = false
		return
		
	if card == current_card:
		visible = false
		
func _on_drag_card(card):
	visible = false
		
