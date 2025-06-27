extends Entity

class_name Statue

@onready var turn_sprite: Sprite2D = $"./TurnSprite"

func _statue_ready() -> void:
	base_ready()
	turn_set(game_controller.turn)
	
	
func turn_set(_turn):
	if is_my_turn():
		show_turn_sprite(true)
	else:
		show_turn_sprite(false)
	
func _on_changed_turn(turn):
	turn_set(turn)

func show_turn_sprite(show_sprite):
	turn_sprite.visible = show_sprite
