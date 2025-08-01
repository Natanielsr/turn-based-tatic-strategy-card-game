extends Statue

class_name EnemyStatue
signal mouse_on(entity)
signal mouse_left(entity)

signal enemy_die()

func _ready() -> void:
	_statue_ready()
	
func die(_killed_by):
	print("EnemyStatue > die: You Destroy the Enemy")
	emit_signal("enemy_die")
	
func get_distance(pos : Vector2):
	var faction_area = grid_controller.get_faction_area(pos)
	if faction_area == EntityFaction.ENEMY: #ENEMY AREA
		return 1
	else:
		return INF
	
func _on_mouse_entered() -> void:
	emit_signal("mouse_on", self)
	
func _on_mouse_exited() -> void:
	emit_signal("mouse_left", self)
