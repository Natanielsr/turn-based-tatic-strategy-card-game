extends Node2D

class_name GameController



var selected_troop : MobileTroop
var target: Entity

@onready var grid_controller: GridController = $"../GridController"
@onready var player_statue: PlayerStatue = $"../../Statues/PlayerStatue"
@onready var turn_controller: TurnController = $"../TurnController"
const Turn = TurnController.Turn

const card_database = preload("res://scripts/card_system/card_database.gd")

var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array

var possible_path


 
func _ready() -> void:
	
	pass
	
func click_on_entity(entity : Entity):
	if turn_controller.turn == Turn.ENEMY:
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
		selected_troop.toggle_outline(false)
		selected_troop = null
		
	
func current_troop_state():
	if selected_troop != null:
		return selected_troop.get_current_state()
		
func has_troop_moving():
	if selected_troop == null:
		return false
		
	return selected_troop.is_moving
	
func deselect_target():
	if not target:
		return
		
	target.toggle_outline(false)
	target = null
	
