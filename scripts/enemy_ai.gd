extends Node2D

class_name EnemyAI

@onready var game_controller: GameController = $"../Controllers/GameController"
@onready var card_manager: CardManager = $"../CardSystem/CardManager"
@onready var grid_controller: GridController = $"../Controllers/GridController"
@onready var troop_manager: TroopManager = $"../TroopManager"
@onready var timer: Timer = $Timer

var hand = []
var selected_card
var selected_monster : MobileTroop

enum AIType{
	AGRESSIVE, #Goes straight to the enemy hero
	DEFENSIVE, #Prioritize protecting the hero and controlling the center
	OPORTUNIST, #Foca em matar unidades fracas e controlar área
	RANDOM #Play any card and move without logic
}
@export var type: AIType = AIType.AGRESSIVE

@onready var spawn_points = [
	$spawn_points/pos_1,
	$spawn_points/pos_2,
	$spawn_points/pos_3,
	$spawn_points/pos_4
]

@onready var attack_area = [
	$attack_area/pos_1,
	$attack_area/pos_2,
	$attack_area/pos_3,
	$attack_area/pos_4
]
var move_count = 0

func _ready() -> void:
	game_controller.connect("changed_turn", Callable(self, "_on_changed_turn"))

func _on_changed_turn(turn: GameController.Turn):
	if turn == GameController.Turn.ENEMY:
		await wait(1)
		select_card()
		spawn_monster()
		await wait(1)
		move_count = 0
		move_next_troop()
		
func finish_turn():
	game_controller.shift_turn()

func move_next_troop():
	if move_count < troop_manager.enemy_troops.size():
		selected_monster = troop_manager.enemy_troops[move_count]
		var moved = move_troop()
		move_count = move_count + 1
		if not moved:
			move_next_troop()		
	else:
		finish_turn()
		
func move_troop():
	
	if not selected_monster:
		print("no monster selected")
		return
		
	var pos_to_go = find_pos()
	
	if pos_to_go and grid_controller.is_walkable_position(pos_to_go):
		selected_monster.move_troop(pos_to_go)
		return true
	else:
		return false
		
func troop_arrived(troop):
	move_next_troop()

func add_card_to_hand(card):
	hand.append(card)

func select_card():
	print(hand)
	var strongest_card = null
	
	for card in hand:
		var card_data = game_controller.card_database.CARDS[card]
		if card_data.type == "monster":
			if strongest_card == null:
				strongest_card = card_data
			if card_data.attack > strongest_card.attack:
				strongest_card = card_data
	
	if strongest_card:
		selected_card = strongest_card

func spawn_monster():
	var pos_to_spawn = find_pos_to_spawn()
	if pos_to_spawn:
		var troop = card_manager.spawn_monster(
			selected_card, pos_to_spawn,
			Entity.EntityFaction.ENEMY)
			
		troop.arrived_signal.connect(troop_arrived.bind(troop))
		
		hand.erase(selected_card.card_id)
	else:
		print("enemy dont have slot to spawn")
		


func find_pos_to_spawn():
	for marker in spawn_points:
		if grid_controller.is_walkable_position(marker.global_position):
			return marker.global_position
				


func get_strongest_monster():
	var strongest_monster : MobileTroop
	
	for monster : MobileTroop in troop_manager.enemy_troops:
		if not strongest_monster:
			strongest_monster = monster
			
		if monster.attack_points > strongest_monster.attack_points:
			strongest_monster = monster
	
	return strongest_monster
	
func find_pos():
	var pos_to_go
	match type:
		AIType.AGRESSIVE:
			pos_to_go = agressive_pos()
		AIType.DEFENSIVE:
			pass
		AIType.OPORTUNIST:
			pos_to_go = oportunist_pos()
		AIType.RANDOM:
			pass
				
	return find_nearest_reachable_position(pos_to_go)
	
func agressive_pos():
	var pos_to_go
	
	if in_area_pos():
		return selected_monster.global_position
		
	var close_area = closest_area_to_attack()
	if close_area:
		var is_achievable_path = grid_controller.is_achievable_path(
			selected_monster.global_position,
			close_area.global_position,
		)
		if is_achievable_path:
			pos_to_go = close_area.global_position
		else:
			pos_to_go = closest_opponent().global_position
	else:
		var close_opponent = closest_opponent().global_position
		if close_opponent:
			pos_to_go = close_opponent.global_position
		
	return pos_to_go
	
func oportunist_pos():
	var pos_to_go
	var weak_opponent = weakest_opponent()
	if weak_opponent:
		pos_to_go = weak_opponent.global_position
	else:
		pos_to_go = closest_area_to_attack().global_position
		
func in_area_pos():
	for marker in attack_area:
		var mon_pos = grid_controller.tile_grid.local_to_map(selected_monster.global_position) 
		var mark_pos = grid_controller.tile_grid.local_to_map(marker.global_position)
		if mon_pos == mark_pos:
			return true
	
	return false
	
func weakest_opponent():
	var weakest_troop : MobileTroop = null
	for monster : MobileTroop in troop_manager.player_troops:
		if not weakest_troop:
			weakest_troop = monster
			
		if monster.attack_points < weakest_troop.attack_points:
			weakest_troop = monster
			
	return weakest_troop
	
func closest_opponent():
	var closest_troop : MobileTroop = null
	var current_distance = 9999
	for monster : MobileTroop in troop_manager.player_troops:
		if not closest_troop:
			closest_troop = monster
			
		var distance = grid_controller.get_distance(
			selected_monster.global_position,
			monster.global_position
		)
		
		if distance < current_distance:
			current_distance = distance
			closest_troop = monster
	
	return closest_troop

func find_nearest_reachable_position(target_pos):
	
	var walk_points = selected_monster.get_current_walk_points()
	
	return grid_controller.find_best_reachable_target(
		selected_monster.global_position,
		target_pos,
		walk_points
	)

func calculate_path_pos(target_pos):
	var pos_to_go
	var path = grid_controller.calculate_path_to_target(
			selected_monster.global_position,
			target_pos,
		)
	var walk_points = selected_monster.get_current_walk_points()
	if path.size() > walk_points:
		path.resize(walk_points)

	if path.size() > 0:
		var last_pos = grid_controller.tile_grid.map_to_local(path.back())
		if not grid_controller.is_walkable_position(last_pos):
			path.pop_back()
		
		if path.size() > 0:
			pos_to_go = grid_controller.tile_grid.map_to_local(path.back())
	else:
		pos_to_go = null
		print(selected_monster.name, " no found path")
		
	return pos_to_go

func closest_area_to_attack():
	var min_distance = null
	var closest_marker = null
	
	for marker in attack_area:
		if grid_controller.is_walkable_position(marker.global_position):
			var distance = grid_controller.get_distance(
				selected_monster.global_position,
				marker.global_position)
				
			if not min_distance:
				min_distance = distance
				closest_marker = marker
				
			if distance <= min_distance:
				min_distance = distance
				closest_marker = marker
				
	return closest_marker

func wait(seconds):
	await get_tree().create_timer(seconds).timeout 


func _on_timer_timeout() -> void:
	pass # Replace with function body.
