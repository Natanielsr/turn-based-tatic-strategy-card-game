extends AudioStreamPlayer2D

class_name SoundFX

@onready var turn_controller: TurnController = $"../../Controllers/TurnController"
const CUCKOO = preload("res://sounds/Cardsounds/cockatrice/cuckoo.wav")
const DRAW = preload("res://sounds/Cardsounds/cockatrice/draw.wav")

func _ready() -> void:
	turn_controller.player_end_turn.connect(_on_end_turn)
	
func _on_end_turn():
	stream = CUCKOO
	play()

func draw_card():
	stream = DRAW
	play()
