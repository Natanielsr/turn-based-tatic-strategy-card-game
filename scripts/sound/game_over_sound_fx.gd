extends Node2D

@onready var game_controller: GameController = $"../Controllers/GameController"

const WINNERIS = preload("res://sounds/winneris.ogg")
const THIS_GAME_IS_OVER = preload("res://sounds/ThisGameIsOver.wav")

# Duração do fade out em segundos
var fade_duration := 2.0

func _ready() -> void:
	game_controller.game_over.connect(fade_out_music)
	
func fade_out_music(victory):
	var player = $Music
	var initial_volume = player.volume_db
	var time_passed := 0.0

	while time_passed < fade_duration:
		var t = time_passed / fade_duration
		player.volume_db = lerp(initial_volume, -80.0, t) # -80 dB = silencioso
		time_passed += get_process_delta_time()
		await get_tree().process_frame  # substitui o yield
	
	player.stop()
	player.volume_db = initial_volume # resetar volume para a próxima vez
	
	if victory:
		$AudioStreamPlayerVictory.play()
	else:
		$AudioStreamPlayerDefeat.play()
