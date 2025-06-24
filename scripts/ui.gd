extends Control

class_name UI

@onready var game_controller: GameController = get_node("/root/Base/Controllers/GameController")
@onready var grid_controller: GridController = get_node("/root/Base/Controllers/GridController")
@onready var finish_turn_btn: Button = $FinishTurnBtn
@onready var enemy_finish_turn_btn: Button = $EnemyFinishTurnBtn
const cursor_attack_texture = preload("res://textures/crawl-tiles Oct-5-2010/item/weapon/long_sword1.png")
const TRAVEL_EXCLUSION_CENTRE = preload("res://textures/crawl-tiles Oct-5-2010/dc-misc/travel_exclusion_centre.png")
const BOOTS_1_BROWN = preload("res://textures/crawl-tiles Oct-5-2010/item/armour/boots1_brown.png")

func _ready() -> void:
	game_controller.connect("changed_turn", Callable(self, "_on_changed_turn"))
	set_turn(game_controller.turn)
	
func _process(delta: float) -> void:
	if not game_controller.selected_troop:
		cursor_normal()
		return
		
	if game_controller.current_troop_state() == MobileTroop.TroopState.WALK:
		cursor_walk_mode()	
	elif game_controller.current_troop_state() == MobileTroop.TroopState.ATTACK:
		cursor_attack_mode()
	else:
		cursor_normal()
		
func cursor_walk_mode():
	if game_controller.selected_troop.is_moving:
		cursor_cancel()
		return
		
	if game_controller.possible_path  == null or game_controller.possible_path .is_empty():
		cursor_cancel()
		return
	
	var is_walkable : bool = grid_controller.is_walkable_position(get_global_mouse_position())
	if not is_walkable:
		cursor_cancel()
		return
	
	if game_controller.selected_troop.get_current_walk_points() <= 0:
		cursor_cancel()
		return
	
	#not include de actual path
	if game_controller.possible_path.size() - 1 > game_controller.selected_troop.get_current_walk_points():
		cursor_cancel()
		return
		
	cursor_boots()
		
func cursor_attack_mode():
	if game_controller.selected_troop.get_attack_count() <= 0:
		cursor_cancel()
		return
	
	var enemy = enemy_on_mouse()
	if not enemy:
		cursor_cancel()
		return
	
	if enemy.get_distance(game_controller.selected_troop.global_position) > 1:
		cursor_cancel()
		return
		
	cursor_attack()
	
func enemy_on_mouse() -> Entity:
	var mouse_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state
	
	var params = PhysicsPointQueryParameters2D.new()
	params.position = mouse_pos
	params.collide_with_areas = true
	params.collide_with_bodies = true

	var result = space_state.intersect_point(params)

	for hit in result:
		var obj = hit.collider
		if obj is Entity:
			var enemy = obj as Entity
			
			if enemy.faction == Entity.EntityFaction.ENEMY:
				return enemy
				
	return null


func _on_changed_turn(turn: GameController.Turn):
	set_turn(turn)

func set_turn(turn):
	cursor_normal()
	
	if turn == GameController.Turn.PLAYER:
		finish_turn_btn.disabled = false
		enemy_finish_turn_btn.disabled = true
	else:
		finish_turn_btn.disabled = true
		enemy_finish_turn_btn.disabled = false

func _on_finish_turn_pressed() -> void:
	game_controller.shift_turn()

func _on_enemy_finish_turn_pressed() -> void:
	game_controller.shift_turn()
	
func _input(event):
	if event.is_action_pressed("right_click"):
		cursor_normal()
		
func cursor_normal():
	Input.set_custom_mouse_cursor(null)
	
func cursor_cancel():
	Input.set_custom_mouse_cursor(TRAVEL_EXCLUSION_CENTRE, Input.CURSOR_ARROW, Vector2(16, 16))
	
func cursor_attack():
	Input.set_custom_mouse_cursor(cursor_attack_texture, Input.CURSOR_ARROW, Vector2(16, 16))
	
func cursor_boots():
	Input.set_custom_mouse_cursor(BOOTS_1_BROWN, Input.CURSOR_ARROW, Vector2(16, 16))
