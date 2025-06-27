extends Node2D

class_name TroopManager

var player_troops = []
var enemy_troops = []

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
