extends PortalBase

class_name PortalEnemy

@onready var turn_controller: TurnController = $"../../Controllers/TurnController"
@onready var enemy_hand: EnemyHand = $"../EnemyHand"
@onready var deck_enemy: DeckEnemy = $"../DeckEnemy"


func _ready() -> void:
	turn_controller.enemy_start_turn.connect(on_enemy_turn_starts)
	
func on_enemy_turn_starts():
	cards_to_trade += 1
	
func execute_trade(_card):
	enemy_hand.remove_card_from_hand(_card)
	deck_enemy.cards_to_drawn = 1
	deck_enemy.draw_card()
