extends Node2D

class_name GameController

signal changed_turn(turn : Turn)

var selected_troop : MobileTroop
var target: Entity

@onready var grid_controller: GridController = $"../GridController"
@onready var action_buttons: Control = $"../../UI/ActionButtons"
@onready var player_statue: PlayerStatue = $"../../Statues/PlayerStatue"

var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array

var possible_path

enum Turn{
	PLAYER,
	ENEMY
}
var turn : Turn = Turn.PLAYER
	
func shift_turn():
	
	if selected_troop and selected_troop.is_moving:
		return
	
	deselect_troop()
	deselect_target()
	
	if turn == Turn.PLAYER:
		turn = Turn.ENEMY
		print("Enemy Turn")
	else:
		turn = Turn.PLAYER
		print("Player Turn")
		
	emit_signal("changed_turn", turn)
	

func _ready() -> void:
	show_action_buttons(false)
	
func click_on_entity(entity : Entity):
	if turn == Turn.ENEMY:
		return

	match entity.faction:
		Entity.EntityFaction.ALLY:
			select_a_troop(entity)
		Entity.EntityFaction.ENEMY:
			mark_target(entity)
		
func mark_target(enemy : Entity):
	if target:
		deselect_target()

	target = enemy
	print("target marked: ",target.name)
	target.toggle_outline(true)
	
	if selected_troop:
		selected_troop.attack(target)

func select_a_troop(troop : Entity):
	if not troop is MobileTroop:
		return
		
	if selected_troop and selected_troop.is_moving:
		return
		
	deselect_troop()
	selected_troop = troop
	#show_action_buttons(true)
	selected_troop.toggle_outline(true)
	print("troop selected: ",selected_troop.name)
			
func deselect_troop():
	if selected_troop != null:
		change_troop_state(MobileTroop.TroopState.NONE)
		show_action_buttons(false)
		selected_troop.toggle_outline(false)
		selected_troop = null
		
func change_troop_state(state : MobileTroop.TroopState):
	if selected_troop != null:
		selected_troop.change_state(state)
		
	
func current_troop_state():
	if selected_troop != null:
		return selected_troop.get_current_state()
	
func show_action_buttons(show_btns : bool):
	action_buttons.visible = show_btns
	if show_btns == true:
		var btn_pos = selected_troop.global_position - Vector2(20, 40)
		action_buttons.global_position = btn_pos
		
func has_troop_moving():
	if selected_troop == null:
		return false
		
	return selected_troop.is_moving
	
func deselect_target():
	if not target:
		return
		
	target.toggle_outline(false)
	target = null
	
