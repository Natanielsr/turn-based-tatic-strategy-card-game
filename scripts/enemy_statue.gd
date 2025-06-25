extends Statue

class_name EnemyStatue

func _ready() -> void:
	_statue_ready()
	
func die():
	print("You Destroy the Enemy")
	get_tree().paused = true
	
func get_distance(pos : Vector2):
	var faction_area = grid_controller.get_faction_area(pos)
	if faction_area == EntityFaction.ENEMY: #ENEMY AREA
		return 1
	else:
		return 9999
	
	
