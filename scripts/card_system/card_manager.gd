extends Node2D

class_name CardManager
signal hovered_card_on(card)
signal hovered_card_off(card)
signal start_drag_card(card)
signal finished_drag_card(card)

const COLLISION_MASK_CARD = 2
const COLLISION_MASK_CARD_SLOT = 4

const Z_INDEX_CARD = 3
const Z_INDEX_CARD_HOVERED = 4

const CARD_SCALE = 0.75
const CARD_HIGHLIGHT = 1

const OFF_SET_MOUSE_X = 40
const OFF_SET_MOUSE_Y = 50

var card_being_dragged : Card

var screen_size
var screen_min
var screen_max

var is_hovering_on_card

@onready var player_hand: PlayerHand = $"../PlayerHand"
@onready var grid_controller: GridController = $"../../Controllers/GridController"
@onready var input_controller: Node2D = $"../../Controllers/InputController"
@onready var game_controller: GameController = $"../../Controllers/GameController"
@onready var troop_manager: TroopManager = $"../../TroopManager"

@onready var player_statue: PlayerStatue = $"../../Statues/PlayerStatue"
@onready var enemy_statue: EnemyStatue = $"../../Statues/EnemyStatue"
@onready var enemy_hand: EnemyHand = $"../../EnemyAI/EnemyHand"

const PLAYCARD = preload("res://sounds/Cardsounds/cockatrice/playcard.wav")
const ERROR = preload("res://sounds/Cardsounds/cockatrice/error.wav")

func _ready() -> void:
	screen_size = get_viewport_rect().size
	screen_min = -(screen_size / 2)
	screen_max = screen_size / 2
	input_controller.connect("left_mouse_button_released", on_left_click_released)

func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		
		card_being_dragged.position = Vector2(
				clamp(mouse_pos.x + OFF_SET_MOUSE_X, screen_min.x, screen_max.x),
				clamp(mouse_pos.y + OFF_SET_MOUSE_Y, screen_min.y, screen_max.y)
			)

func start_drag(card: Card):
	if game_controller.is_choose_card_state():
		return
		
	card_being_dragged = card
	card_being_dragged.is_dragging = true
	#card_being_dragged.modulate.a = 0.25
	card.scale = Vector2(CARD_SCALE, CARD_SCALE)
	emit_signal("start_drag_card", card)
	
	$AudioStreamPlayer2D.stream = PLAYCARD
	$AudioStreamPlayer2D.play()
	
func on_left_click_released():
	if card_being_dragged:
		finish_drag()
	
func finish_drag():
	emit_signal("finished_drag_card", card_being_dragged)
	
	if not card_being_dragged:
		return
		
	card_being_dragged.scale = Vector2(CARD_SCALE, CARD_SCALE)
	if card_being_dragged.type == "monster":
		_handle_monster_card_drop()
	else:
		_handle_non_monster_card_drop()
	
	card_being_dragged.is_dragging = false
	card_being_dragged = null

func _handle_monster_card_drop():
	var card_slot_pos = check_for_card_slot()
	if can_spawn_card(card_slot_pos):
		_spawn_monster_from_card(card_slot_pos)
	elif player_hand.is_card_in_hand(card_being_dragged):
		_return_card_to_hand_with_error()

func _spawn_monster_from_card(card_slot_pos):
	card_being_dragged.global_position = card_slot_pos
	
	remove_card(card_being_dragged)

	var monster_id = troop_manager.generate_id(
		card_being_dragged.card_id, MobileTroop.EntityFaction.ALLY)

	var card_data = game_controller.card_database.CARDS[card_being_dragged.card_id]

	troop_manager.spawn_monster(
		card_data,
		card_slot_pos,
		MobileTroop.EntityFaction.ALLY,
		monster_id
	)

	player_statue.consume_energy(card_data.energy_cost)
	
func remove_card(card):
	player_hand.remove_card_from_hand(card)

func _return_card_to_hand_with_error():
	player_hand.add_card_to_hand(card_being_dragged)
	$AudioStreamPlayer2D.stream = ERROR
	$AudioStreamPlayer2D.play()

func _handle_non_monster_card_drop():
	player_hand.add_card_to_hand(card_being_dragged)
	highlight_card(card_being_dragged, false)
	
func can_spawn_card(card_slot_pos):
	if not card_slot_pos:
		return false
	
	if not grid_controller.is_walkable_position(card_slot_pos):
		return false
	
	if player_statue._current_energy < card_being_dragged.energy_cost:
		return false
		
	return true
		
func check_for_card_slot():
	var mouse_position = get_global_mouse_position()
	var faction = grid_controller.get_faction_area(mouse_position)
	
	if faction == Entity.EntityFaction.ALLY:
		return grid_controller.get_tile_world_position(mouse_position)
	else:
		return null
	
func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_over_card(card):
	if not is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)
	
	emit_signal("hovered_card_on", card)
	
func on_hovered_off_card(card):
	if card_being_dragged:
		return
	
	highlight_card(card, false)
	var new_card_hovered = raycast_check_for_card()
	if new_card_hovered:
		highlight_card(new_card_hovered, true)
	else:
		is_hovering_on_card = false
	
	emit_signal("hovered_card_off", card)
	
func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(CARD_HIGHLIGHT, CARD_HIGHLIGHT)
		card.z_index = Z_INDEX_CARD_HOVERED
	else:
		card.scale = Vector2(CARD_SCALE, CARD_SCALE)
		card.z_index = Z_INDEX_CARD

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
	
func can_play_the_card(card, faction):
	var card_data = game_controller.card_database.CARDS[card]
	
	if faction == Entity.EntityFaction.ENEMY:
		if enemy_statue._current_energy >= card_data.energy_cost:
			return true
	elif faction == Entity.EntityFaction.ALLY:
		if player_statue._current_energy >= card_data.energy_cost:
			return true
	
	return false
