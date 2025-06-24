extends Node2D

class_name CardManager

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2

var card_being_dragged : Node2D
var screen_size
var screen_min
var screen_max

var is_hovering_on_card

@onready var player_hand: PlayerHand = $"../PlayerHand"


func _ready() -> void:
	screen_size = get_viewport_rect().size
	screen_min = -(screen_size / 2)
	screen_max = screen_size / 2
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)

func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		
		card_being_dragged.position = Vector2(
				clamp(mouse_pos.x, screen_min.x, screen_max.x),
				clamp(mouse_pos.y, screen_min.y, screen_max.y)
			)

func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(1, 1)
	
func on_left_click_released():
	if card_being_dragged:
		finish_drag()
	
func finish_drag():
	if not card_being_dragged:
		return

	card_being_dragged.scale = Vector2(1, 1)
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		card_slot_found.card_in_slot = true
		player_hand.remove_card_from_hand(card_being_dragged)
		card_being_dragged.position = card_slot_found.position
	else:
		player_hand.add_card_to_hand(card_being_dragged)
		highlight_card(card_being_dragged, false)
		
	card_being_dragged = null

func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
	

	
func on_hovered_over_card(card):
	if not is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)
	
func on_hovered_off_card(card):
	if card_being_dragged:
		return
	
	#print(card.name)
	highlight_card(card, false)
	var new_card_hovered = raycast_check_for_card()
	if new_card_hovered:
		highlight_card(new_card_hovered, true)
	else:
		is_hovering_on_card = false
	
func highlight_card(card, hovered):
	if hovered:
		#card.position.y = card.start_position.y - 65
		card.scale = Vector2(1.5, 1.5)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1
		#if not card.get_node("Area2D/CollisionShape2D").disabled:
		#	card.position = card.start_position

func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	else:
		return null

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	else:
		return null
	
func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var hightest_z_index = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > hightest_z_index:
			highest_z_card = current_card
			hightest_z_index = current_card.z_index
			
	return highest_z_card
