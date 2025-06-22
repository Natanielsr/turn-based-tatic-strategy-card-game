extends Entity

class_name MobileTroop 

@onready var tile_grid: TileMapLayer = get_node("/root/Base/Tiles/TileGrid")
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var atk_points_label: Label = $"./Status/AtkPoints"
@onready var walk_points_label: Label = $"./Status/WalkPoints"

@export var attack_damage : int = 2
@export var total_attack_count : int = 1
var _current_attack_count = total_attack_count
@export var attack_distance : int = 1

var moviment_speed : float = 1
@export var walk_distance = 5
var _current_walk_points = walk_distance

var target_position: Vector2
var clicked_target_position : Vector2
var started_walk_position : Vector2
var is_moving: bool
var _current_id_path: Array[Vector2i]

var _current_state : TroopState
enum TroopState{
	NONE,
	WALK,
	ATTACK
}

func _on_changed_turn(turn):
	if is_my_turn():
		set_walk_points(walk_distance)
		_current_attack_count = total_attack_count
		_current_state = TroopState.NONE

func _ready() -> void:
	base_ready()
	#define the actual poistion not walkable
	grid_controller.set_walkable_position(
		global_position,
		false
	)
	_current_state = TroopState.NONE
	toggle_outline(false)
	update_atk_label()
	
	set_walk_points(walk_distance) 
	_current_attack_count = total_attack_count
	
	if faction == EntityFaction.ENEMY:
		$"./Status/AtkSprite".modulate = Color(1, 0, 0) 
		
	
			
func _physics_process(_delta: float) -> void:
	if not is_moving:
		return
		
	#move the troop	
	global_position = global_position.move_toward(target_position, moviment_speed)
	
	#arrived in position
	if global_position == target_position:
		_current_id_path.pop_front() #remove the position
		set_walk_points(_current_walk_points - 1) #remove walk point
		
		if not _current_id_path.is_empty(): #verify if have next position
			target_position = tile_grid.map_to_local(_current_id_path.front()) #pass to next position
		else: #arrived
			arrived()

func set_walk_points(walk_points : int):
	_current_walk_points = walk_points
	walk_points_label.text = str(_current_walk_points)

func arrived():
	is_moving = false
	change_state(TroopState.NONE)
	game_controller.deselect_troop()
	grid_controller.set_walkable_position(global_position, false)
	print(name, " arrived")
	

func get_current_walk_points():
	return _current_walk_points
			
func move_troop():
	if is_moving:
		return false
		
	if _current_walk_points <= 0:
		print("Troop ",name," Dont Have Walk Points")
		return
	
	clicked_target_position = get_global_mouse_position()
	var id_path = grid_controller.calculate_path(
		global_position,
		clicked_target_position)
	
	if id_path.is_empty(): #verify have path
		return false
		
	if id_path.size() > _current_walk_points:
		print("walk distance is to far to ", name)
		return false
	
	_current_id_path = id_path
	target_position = tile_grid.map_to_local(_current_id_path.front())
	grid_controller.set_walkable_position(global_position, true)
	started_walk_position = global_position
	print(name," is moving")
	is_moving = true
	
	return is_moving
	
	
func attack(entity : Entity):
	
	if _current_attack_count <= 0:
		print( name, " dont have attack points ")
		return
	
	var distance = entity.get_distance(global_position)
	if distance > attack_distance:
		print("too far to ", name, " attack ",entity.name," distance: ",distance)
		return
	
	print(name, " attacks ", entity.name, " with ", attack_damage, " damage")
	entity.take_damage(attack_damage)
	_current_attack_count -= 1
	
	change_state(TroopState.NONE)
	
	if entity is MobileTroop:
		take_damage(entity.attack_damage)
		
func get_distance(pos : Vector2):
	var distance = grid_controller.get_distance_to_attack_in_diagonal(
		global_position,
		pos
	)
	
	return distance
	
func die():
	print(name," Die")
	grid_controller.set_walkable_position(global_position, true)
	queue_free()
	
func update_atk_label():
	atk_points_label.text = str(attack_damage)
		
func change_state(new_state : TroopState):
	_current_state = new_state

func get_current_state():
	return _current_state
	
func get_attack_count():
	return _current_attack_count
