extends Node

class_name EnemyHand

var hand = []

func init():
	hand = []

func add_card_to_hand(card):
	hand.append(card)
	
func remove_card_from_hand(card):
	hand.erase(card)
