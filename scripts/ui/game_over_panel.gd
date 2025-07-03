extends CanvasLayer

func _ready() -> void:
	$"../../Statues/PlayerStatue".player_lost_the_game.connect(_show_panel)

func _show_panel():
	visible = true
	var overlay = get_node("Overlay")
	var label = get_node("Label")
	
	# Anima o alpha do ColorRect de 0 para 0.7 em 1 segundo
	var tween = create_tween()
	tween.tween_property(overlay, "color", Color(0,0,0,0.7), 2.0)
	
	# Quando terminar, mostra o texto e pausa o jogo
	tween.connect("finished", Callable(self, "_on_game_over_fade_finished").bind(label))

func _on_game_over_fade_finished(label):
	label.visible = true
	$Restart.visible = true
	#get_tree().paused = true


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
