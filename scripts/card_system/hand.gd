extends Node2D

class_name Hand

var hand : Array[Card] = []

var center_cards_x

func add_card_to_hand(new_card : Card):
	if new_card not in hand:
		hand.append(new_card)
		update_hand_position()
	else:
		animate_card_to_position(new_card, new_card.start_position)

func update_hand_position():
	for i in range(hand.size()):
		var card : Card = hand[i]
		
		var x_position = calculate_card_position(i)
		var y_position = get_y_pos()
		
		var new_position = Vector2(x_position, y_position)
			
		
		card.start_position = new_position
		
		animate_card_to_position(card, new_position)
		
func get_y_pos():
	push_error("implements get y pos in hand scritp")
	pass
	
func calculate_card_position(index) -> float:
	var total_width = (hand.size() -1) * get_card_width()
	var x_offset = center_cards_x - total_width / 2.0 + index * get_card_width()
	return x_offset
	
func get_card_width():
	push_error("implements get card width in hand scritp")
	pass
	
func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.2)
	
func animate_card_to_position_with_time(card, new_position, time):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, time)
	
func remove_card_from_hand(card: Card):
	if card in hand:
		hand.erase(card)
		card.remove_card()
		update_hand_position()
	else:
		push_error("CARD NOT IN PLAYER HAND")
		
func is_card_in_hand(card : Card):
	if hand.has(card):
		return true
	else:
		return false
