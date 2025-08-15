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
	
func play_temp_sound(sound: AudioStream, _position: Vector2):
	play_temp_sound_with_volume(sound, _position, 0)
	
func play_temp_sound_with_volume(sound: AudioStream, _position: Vector2, volume_db):
	var player = AudioStreamPlayer2D.new()
	player.stream = sound
	player.position = _position
	player.volume_db = volume_db
	player.autoplay = false
	add_child(player)
	
	player.play()
	
	# Quando terminar, remover automaticamente
	player.connect("finished", Callable(player, "queue_free"))
