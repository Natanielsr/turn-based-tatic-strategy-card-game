extends Node2D

class_name TurnController

signal changed_turn(turn : Turn)

@onready var game_controller: GameController = $"../GameController"

enum Turn{
	PLAYER,
	ENEMY
}
var turn : Turn = Turn.PLAYER
	
func shift_turn():
	var selected_troop = game_controller.selected_troop
	if selected_troop and selected_troop.is_moving:
		return
	
	game_controller.deselect_troop()
	game_controller.deselect_target()
	
	if turn == Turn.PLAYER:
		turn = Turn.ENEMY
		print("Enemy Turn")
	else:
		turn = Turn.PLAYER
		print("Player Turn")
		
	emit_signal("changed_turn", turn)
