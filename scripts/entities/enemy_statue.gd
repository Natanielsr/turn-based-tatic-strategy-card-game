extends Statue

class_name EnemyStatue

signal enemy_die()

func _ready() -> void:
	_statue_ready()
	
func die():
	print("You Destroy the Enemy")
	emit_signal("enemy_die")
	
func get_distance(pos : Vector2):
	var faction_area = grid_controller.get_faction_area(pos)
	if faction_area == EntityFaction.ENEMY: #ENEMY AREA
		return 1
	else:
		return 9999
	
	
