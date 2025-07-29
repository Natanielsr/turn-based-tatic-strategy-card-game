extends Statue
class_name PlayerStatue

signal player_lost_the_game()

func _ready() -> void:
	_statue_ready()

func die(_killed_by):
	print("You Lost")
	emit_signal("player_lost_the_game")
	
func get_distance(pos : Vector2):
	var faction_area = grid_controller.get_faction_area(pos)
	if faction_area == EntityFaction.ALLY: #PLAYER AREA
		return 1
	else:
		return 9999
