extends ChooseStartCards

class_name ChooseStartCardsPlayer

@onready var deck_player: DeckPlayer = $"../DeckPlayer"
@onready var player_hand: PlayerHand = $"../PlayerHand"
@onready var game_controller: GameController = $"../../Controllers/GameController"
@onready var choose_btn: Button = $ChooseBtn

func _ready() -> void:
	super._ready()
	set_deck_and_hand(deck_player, player_hand)
	await Waiter.wait(1.3)
	$ChooseBtn.visible = true

func _on_choose_btn_pressed() -> void:
	$ChooseBtn.visible = false
	confirm_choose()
	game_controller.change_game_state(GameController.GameState.RUNNING)
	hand.update_hand_position()
	
