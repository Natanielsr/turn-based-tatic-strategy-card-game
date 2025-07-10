extends Node2D

class_name TroopManager

signal monster_spawned(monster : MobileTroop)

@onready var grid_controller: GridController = $"../Controllers/GridController"
@onready var game_controller: GameController = $"../Controllers/GameController"
@onready var player_statue: PlayerStatue = $"../Statues/PlayerStatue"
@onready var enemy_statue: EnemyStatue = $"../Statues/EnemyStatue"
@onready var player_hand: PlayerHand = $"../CardSystem/PlayerHand"
@onready var enemy_hand: EnemyHand = $"../EnemyAI/EnemyHand"

const MONSTER = preload("res://prefabs/monster.tscn")


var player_troops : Array[MobileTroop] = []
var enemy_troops : Array[MobileTroop] = []



func add_troop(troop : MobileTroop):
	add_child(troop)	
	if troop.faction == Entity.EntityFaction.ALLY:
		player_troops.append(troop)
	elif troop.faction == Entity.EntityFaction.ENEMY:
		enemy_troops.append(troop)
		
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
	
func spawn_monster(card_name, card_slot_pos, faction, monster_id):
	
	var card_to_spawn = game_controller.card_database.CARDS[card_name]
	
	if faction == Entity.EntityFaction.ALLY:
		if card_to_spawn.energy_cost > player_statue._current_energy:
			print("player without enough energy")
			return
		player_statue.consume_energy(card_to_spawn.energy_cost)
	elif faction == Entity.EntityFaction.ENEMY:
		if card_to_spawn.energy_cost > enemy_statue._current_energy:
			print("enemy without enough energy")
			return
		enemy_statue.consume_energy(card_to_spawn.energy_cost)
		enemy_hand.remove_card_from_hand(card_to_spawn.card_id)
	
	var monster : MobileTroop = create_monster(card_to_spawn, faction, monster_id)
	monster.position = card_slot_pos
	add_troop(monster)
	
	await game_controller.wait(1)
	emit_signal("monster_spawned", monster)
	
	return monster

func create_monster(card_to_spawn, faction, monster_id) -> MobileTroop:
	var monster : MobileTroop = MONSTER.instantiate()
	monster.name = monster_id
	monster.card_id = card_to_spawn.card_id
	var img_path = str("res://textures/cards/"+card_to_spawn.card_id+".png")
	monster.get_node("Sprite2D").texture = load(img_path)
	monster.set_attack_points(card_to_spawn.attack)
	monster.set_total_life(card_to_spawn.health)
	monster.set_faction(faction)
	
	return monster
	
func generate_id(card_id, faction):
	return str(card_id + "_"+Entity.EntityFaction.keys()[faction] +"_"+str(randi()))
	
func find_troop_by_name(troop_name):
	for troop in enemy_troops:
		if troop.name == troop_name:
			return troop
