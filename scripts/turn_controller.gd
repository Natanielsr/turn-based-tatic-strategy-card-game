extends Node2D

class_name TurnController

signal changed_turn(turn : Turn)
signal player_start_turn() 
signal player_end_turn() 
signal enemy_start_turn() 
signal enemy_end_turn() 

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
		_player_end_turn()
		turn = Turn.ENEMY
		_enemy_start_turn()
	else:
		_enemy_end_turn()
		turn = Turn.PLAYER
		_player_start_turn()
		
	emit_signal("changed_turn", turn)
	
	
func _player_start_turn():
	emit_signal("player_start_turn")
	
func _player_end_turn():
	emit_signal("player_end_turn")

func _enemy_start_turn():
	emit_signal("enemy_start_turn")
	
func _enemy_end_turn():
	emit_signal("enemy_end_turn")
