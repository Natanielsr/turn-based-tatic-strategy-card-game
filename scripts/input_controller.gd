extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

@onready var game_controller: GameController = $"../GameController"
@onready var turn_controller: TurnController = $"../TurnController"
const Turn = TurnController.Turn

@onready var card_manager: CardManager = $"../../CardSystem/CardManager"
@onready var deck_player: DeckPlayer = $"../../CardSystem/DeckPlayer"

var clicked_target_position

const COLLISION_MASK_CARD = 2
const COLLISION_MASK_DECK = 4

func _input(event):
	if game_controller.current_game_state != GameController.GameState.RUNNING:
		return
	
	if turn_controller.turn != Turn.PLAYER:
		return
		
	if game_controller.selected_troop:
		if game_controller.selected_troop.is_moving:
			return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("left_mouse_button_clicked")
			if game_controller.selected_troop:
				clicked_target_position = get_global_mouse_position()
				game_controller.selected_troop.move_troop(clicked_target_position)
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_button_released")
			
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			game_controller.deselect_target()
			game_controller.deselect_troop()
		

func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var obj = result[0]["collider"]
		
		if obj is Entity:
			click_on_entity(obj)
		elif obj.get_parent() is Card:
			click_on_card(obj)
		elif obj.get_parent() is DeckPlayer:
			click_on_deck(obj)
		else:
			print("other")

func click_on_entity(entity : Entity):
	game_controller.click_on_entity(entity)

func click_on_card(obj):
	game_controller.deselect_troop()
	var card_found = obj.get_parent()
	if card_found:
		card_manager.start_drag(card_found)
		
func click_on_deck(_obj):
	deck_player.draw_card()
