extends Control

class_name UI

@onready var game_controller: GameController = get_node("/root/Base/Controllers/GameController")
@onready var turn_controller: TurnController = $"../Controllers/TurnController"
@onready var troop_manager: TroopManager = $"../TroopManager"
@onready var mouse: Mouse = $Mouse

const Turn = TurnController.Turn

@onready var grid_controller: GridController = get_node("/root/Base/Controllers/GridController")
@onready var finish_turn_btn: Button = $FinishTurnBtn
@onready var enemy_finish_turn_btn: Button = $EnemyFinishTurnBtn

func _ready() -> void:
	turn_controller.connect("changed_turn", Callable(self, "_on_changed_turn"))
	set_turn(turn_controller.turn)
	
func _on_changed_turn(turn: GameController.Turn):
	set_turn(turn)

func set_turn(turn):
	mouse.set_cursor_normal()
	
	if turn == GameController.Turn.PLAYER:
		finish_turn_btn.disabled = false
		enemy_finish_turn_btn.disabled = true
	else:
		finish_turn_btn.disabled = true
		enemy_finish_turn_btn.disabled = false
			
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
		
