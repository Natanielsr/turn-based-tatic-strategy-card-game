extends Node2D

class_name CardManager

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

const MONSTER = preload("res://prefabs/monster.tscn")

func _ready() -> void:
	screen_size = get_viewport_rect().size
	screen_min = -(screen_size / 2)
	screen_max = screen_size / 2
	input_controller.connect("left_mouse_button_released", on_left_click_released)

func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		
		card_being_dragged.position = Vector2(
				clamp(mouse_pos.x + OFF_SET_MOUSE_X, screen_min.x, screen_max.x),
				clamp(mouse_pos.y + OFF_SET_MOUSE_Y, screen_min.y, screen_max.y)
			)

func start_drag(card):
	card_being_dragged = card
	#card_being_dragged.modulate.a = 0.25
	card.scale = Vector2(CARD_SCALE, CARD_SCALE)
	
func on_left_click_released():
	if card_being_dragged:
		finish_drag()
	
func finish_drag():
	if not card_being_dragged:
		return

	card_being_dragged.scale = Vector2(CARD_SCALE, CARD_SCALE)
	
	if card_being_dragged.type == "monster":
		spawn_monster()
	else:
		player_hand.add_card_to_hand(card_being_dragged)
		highlight_card(card_being_dragged, false)
		
	card_being_dragged = null

func spawn_monster():
	var card_slot_pos = check_for_card_slot()
	if card_slot_pos and grid_controller.is_walkable_position(card_slot_pos):
		player_hand.remove_card_from_hand(card_being_dragged)	
		var monster : MobileTroop = create_monster()
		monster.position = card_slot_pos
		$"../../Troops".add_child(monster)	
		card_being_dragged.queue_free()
		print(monster.name," spawned")
	else:
		player_hand.add_card_to_hand(card_being_dragged)

func create_monster() -> MobileTroop:
	var monster : MobileTroop = MONSTER.instantiate()
	monster.name = card_being_dragged.card_id
	var img_path = str("res://textures/cards/"+card_being_dragged.card_id+".png")
	monster.get_node("Sprite2D").texture = load(img_path)
	monster.set_attack_points(card_being_dragged.attack_points)
	monster.set_total_life(card_being_dragged.life_points)
	
	return monster
	
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
		card.scale = Vector2(CARD_HIGHLIGHT, CARD_HIGHLIGHT)
		card.z_index = Z_INDEX_CARD_HOVERED
	else:
		card.scale = Vector2(CARD_SCALE, CARD_SCALE)
		card.z_index = Z_INDEX_CARD
		#if not card.get_node("Area2D/CollisionShape2D").disabled:
		#	card.position = card.start_position

func check_for_card_slot():
	var mouse_position = get_global_mouse_position()
	var faction = grid_controller.get_faction_area(mouse_position)
	
	if faction == Entity.EntityFaction.ALLY:
		return grid_controller.get_tile_world_position(mouse_position)
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
