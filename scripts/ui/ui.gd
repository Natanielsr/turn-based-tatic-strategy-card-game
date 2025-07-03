extends Control

class_name UI

@onready var game_controller: GameController = get_node("/root/Base/Controllers/GameController")
@onready var turn_controller: TurnController = $"../Controllers/TurnController"
const Turn = TurnController.Turn

@onready var grid_controller: GridController = get_node("/root/Base/Controllers/GridController")
@onready var finish_turn_btn: Button = $FinishTurnBtn
@onready var enemy_finish_turn_btn: Button = $EnemyFinishTurnBtn
const cursor_attack_texture = preload("res://textures/crawl-tiles Oct-5-2010/item/weapon/long_sword1.png")
const TRAVEL_EXCLUSION_CENTRE = preload("res://textures/crawl-tiles Oct-5-2010/dc-misc/travel_exclusion_centre.png")
const BOOTS_1_BROWN = preload("res://textures/crawl-tiles Oct-5-2010/item/armour/boots1_brown.png")

func _ready() -> void:
	turn_controller.connect("changed_turn", Callable(self, "_on_changed_turn"))
	set_turn(turn_controller.turn)
	
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
	
func _process(_delta: float) -> void:
	if game_controller.current_game_state != GameController.GameState.RUNNING:
		cursor_normal()
		return
	
	if not game_controller.selected_troop:
		cursor_normal()
		return
		
	if enemy_on_mouse():
		if game_controller.selected_troop.get_attack_count() > 0:
			cursor_attack()
		else:
			cursor_cancel()
	else:
		if not game_controller.selected_troop.is_exausted:
			cursor_boots()
		else:
			cursor_cancel()
	
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




func _on_finish_turn_pressed() -> void:
	turn_controller.shift_turn()

func _on_enemy_finish_turn_pressed() -> void:
	game_controller.shift_turn()
		
func cursor_normal():
	Input.set_custom_mouse_cursor(null)
	
func cursor_cancel():
	Input.set_custom_mouse_cursor(TRAVEL_EXCLUSION_CENTRE, Input.CURSOR_ARROW, Vector2(16, 16))
	
func cursor_attack():
	Input.set_custom_mouse_cursor(cursor_attack_texture, Input.CURSOR_ARROW, Vector2(16, 16))
	
func cursor_boots():
	Input.set_custom_mouse_cursor(BOOTS_1_BROWN, Input.CURSOR_ARROW, Vector2(16, 16))
