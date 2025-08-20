extends Node2D

class_name Debugger

@onready var troop_manager: TroopManager = $"../../TroopManager"
@onready var game_controller: GameController = $"../GameController"
@onready var grid_controller: GridController = $"../GridController"


func spawn_ally():
	var name_troop = "giant_snail"
	var faction = Entity.EntityFaction.ALLY
	spawn_test_troop(name_troop, faction)
	
func spawn_enemy():
	var name_troop = "giant_snail"
	var faction = Entity.EntityFaction.ENEMY
	spawn_test_troop(name_troop, faction)

func spawn_test_troop(name_troop, faction):
	var card = game_controller.card_database.CARDS[name_troop]
	var monster_id = Uid.generate_id(name_troop, faction)
	var tile_pos = grid_controller.get_world_to_tile_pos(get_global_mouse_position())
	var world_pos = grid_controller.get_tile_to_world_pos(tile_pos)
	troop_manager.add_monster(
		card, world_pos, faction, monster_id)
