extends Entity

class_name Statue

@onready var turn_sprite: Sprite2D = $"./TurnSprite"
var max_energy = 0
var _current_energy = max_energy

func _statue_ready() -> void:
	base_ready()
	_current_energy = max_energy
	update_energy_label()
	turn_set(turn_controller.turn)
	
func turn_set(_turn):

	if is_troop_turn():
		show_turn_sprite(true)
		if max_energy < 10:
			max_energy += 1
			_current_energy = max_energy
		update_energy_label()
	else:
		show_turn_sprite(false)
		
func update_energy_label():
	$"./Energy".text = str(_current_energy) +" / "+ str(max_energy)
	
func consume_energy(energy):
	if energy > _current_energy:
		print("without enough energy")
		return
		
	_current_energy = _current_energy - energy
	update_energy_label()
	
func _on_changed_turn(turn):
	turn_set(turn)

func show_turn_sprite(show_sprite):
	turn_sprite.visible = show_sprite
