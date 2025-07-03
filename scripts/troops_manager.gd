extends Node2D

class_name TroopManager

@onready var grid_controller: GridController = $"../Controllers/GridController"

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
