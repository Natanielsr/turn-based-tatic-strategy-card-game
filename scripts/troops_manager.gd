extends Node2D

class_name TroopManager

signal monster_spawned(monster : MobileTroop)

@onready var grid_controller: GridController = $"../Controllers/GridController"
@onready var game_controller: GameController = $"../Controllers/GameController"
@onready var player_statue: PlayerStatue = $"../Statues/PlayerStatue"
@onready var enemy_statue: EnemyStatue = $"../Statues/EnemyStatue"
@onready var player_hand: PlayerHand = $"../CardSystem/PlayerHand"
@onready var enemy_hand: EnemyHand = $"../EnemyAI/EnemyHand"
@onready var turn_controller: TurnController = $"../Controllers/TurnController"


const MONSTER = preload("res://prefabs/monster.tscn")

var player_troops : Array[MobileTroop] = []
var enemy_troops : Array[MobileTroop] = []

func _ready() -> void:
	turn_controller.player_start_turn.connect(_on_player_start_turn)
	turn_controller.player_end_turn.connect(_on_player_end_turn)
	turn_controller.enemy_start_turn.connect(_on_enemy_start_turn)
	turn_controller.enemy_end_turn.connect(_on_enemy_end_turn)

func _on_player_start_turn():
	for troop in player_troops:
		troop.effects_manager.process_effects_start_turn()

func _on_player_end_turn():
	for troop in player_troops:
		troop.effects_manager.process_effects_end_turn()
	
func _on_enemy_start_turn():
	for troop in enemy_troops:
		troop.effects_manager.process_effects_start_turn()
	
func _on_enemy_end_turn():
	for troop in enemy_troops:
		troop.effects_manager.process_effects_end_turn()

func add_troop(troop : MobileTroop):
	add_child(troop)	
	if troop.faction == Entity.EntityFaction.ALLY:
		player_troops.append(troop)
	elif troop.faction == Entity.EntityFaction.ENEMY:
		enemy_troops.append(troop)
	else:
		push_error("No troop faction")
		
func remove_troop(troop):
	if troop.faction == Entity.EntityFaction.ALLY:
		player_troops.erase(troop)
	elif troop.faction == Entity.EntityFaction.ENEMY:
		enemy_troops.erase(troop)
		
func sorted_opponents_by_distance(troop: MobileTroop) -> Array:
	var distances = []
	
	for monster: MobileTroop in player_troops:
		var distance = grid_controller.get_distance(
			troop.global_position,
			monster.global_position
		)
		distances.append({ "troop": monster, "distance": distance })
	
	distances.sort_custom(func(a, b): return a["distance"] < b["distance"])
	
	var sorted_troops = []
	for entry in distances:
		sorted_troops.append(entry["troop"])
	
	return sorted_troops
	
func sorted_opponents_by_attack() -> Array:
	var sorted_troops = player_troops.duplicate()
	sorted_troops.sort_custom(func(a, b): return a.attack_points < b.attack_points)
	return sorted_troops
	
func spawn_monster(card_data, card_slot_pos, faction, monster_id):
	var monster = null
	if not can_spawn(faction, card_data):
		return
	
	monster = await add_monster(card_data, card_slot_pos, faction, monster_id)
	
	return monster
	
func add_monster(card_data, pos, faction, monster_id):
	var monster : MobileTroop = create_monster(card_data, faction, monster_id)
	monster.position = pos
	add_troop(monster)
	
	await game_controller.wait(1)
	emit_signal("monster_spawned", monster)

func can_spawn(faction, card_to_spawn):
	if faction == Entity.EntityFaction.ALLY:
		if card_to_spawn.energy_cost > player_statue._current_energy:
			print("player without enough energy")
			return false
	elif faction == Entity.EntityFaction.ENEMY:
		if card_to_spawn.energy_cost > enemy_statue._current_energy:
			print("enemy without enough energy")
			return false
			
	return true
	


func create_monster(card_data, faction, monster_id) -> MobileTroop:
	var monster : MobileTroop = MONSTER.instantiate()
	monster.name = monster_id
	monster.card_id = card_data.card_id
	var img_path = str("res://textures/cards/"+card_data.card_id+".png")
	monster.get_node("Sprite2D").texture = load(img_path)
	monster.set_attack_points(card_data.attack)
	monster.set_total_life(card_data.health)
	monster.set_faction(faction)
	
	return monster
	
func generate_id(card_id, faction):
	return str(card_id + "_"+Entity.EntityFaction.keys()[faction] +"_"+str(randi()))
	
func find_troop_by_name(troop_name):
	for troop in enemy_troops:
		if troop.name == troop_name:
			return troop
