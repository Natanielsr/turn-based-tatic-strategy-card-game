extends Node
class_name AISpawner

@onready var game_controller: GameController = $"../../Controllers/GameController"
@onready var card_manager = $"../../CardSystem/CardManager"
@onready var grid_controller = $"../../Controllers/GridController"
@onready var spawn_points = get_spawn_points()
@onready var enemy_hand: EnemyHand = $"../EnemyHand"
@onready var troop_manager: TroopManager = $"../../TroopManager"
@onready var enemy_statue: EnemyStatue = $"../../Statues/EnemyStatue"

var selected_card

func select_and_spawn_best_monster():
	await wait(0.3)
	print("enemy hand: ",enemy_hand.hand)
	for card in enemy_hand.hand:
		await wait(0.3)
		selected_card = get_strongest_card()
		if selected_card:
			var pos = find_spawn_position()
			if pos:
				var _troop : MobileTroop = card_manager.spawn_monster(
					selected_card, pos, Entity.EntityFaction.ENEMY)


func get_strongest_card():
	
	var strongest_card = null
	
	for card in enemy_hand.hand:
		var card_data = game_controller.card_database.CARDS[card]
		if card_data.energy_cost > enemy_statue._current_energy:
			continue
		if card_data.type == "monster":
			if strongest_card == null:
				strongest_card = card_data
			if card_data.attack > strongest_card.attack:
				strongest_card = card_data
	
	return strongest_card


func find_spawn_position():
	for marker in spawn_points:
		if grid_controller.is_walkable_position(marker.global_position):
			return marker.global_position

func get_spawn_points():
	return get_children()
	
	
func wait(seconds):
	await get_tree().create_timer(seconds).timeout 

func get_valid_spawn_tiles():
	var valid_tiles = []
	for marker in spawn_points:
		if grid_controller.is_walkable_position(marker.global_position):
			var tile_pos = grid_controller.get_world_to_tile_pos(marker.global_position)
			valid_tiles.append(tile_pos)
	return valid_tiles
	
