extends PortalBase

class_name PortalPlayer

@onready var card_manager: CardManager = $"../CardManager"
@onready var deck_player: DeckPlayer = $"../DeckPlayer"
@onready var turn_controller: TurnController = $"../../Controllers/TurnController"

func _ready() -> void:
	card_manager.finished_drag_card.connect(on_finish_drag)
	turn_controller.player_start_turn.connect(on_player_turn_starts)
	
func on_player_turn_starts():
	cards_to_trade = 1
	$AnimationPlayer.play("enable")

func on_finish_drag(_card : Card):
	var area: Area2D = $Area2D
	var mouse_position: Vector2 = get_global_mouse_position()
	var local_mouse_pos: Vector2 = area.to_local(mouse_position)
	var shape : RectangleShape2D = area.get_node("CollisionShape2D").shape
	
	if shape is RectangleShape2D and shape.get_rect().has_point(local_mouse_pos):
		trade_card(_card)
		
func execute_trade(_card):
	_card.global_position = global_position
	card_manager.remove_card(_card)
	_card.get_node("AnimationPlayer").animation_finished.connect(_on_animation_finished)
	

func _on_animation_finished(anim_name):
	if anim_name == "disappear":
		deck_player.cards_to_drawn = 1
		deck_player.draw_card()
		$AnimationPlayer.play("disable")
		
