extends Entity

class_name MobileTroop 

signal walk_finish()
signal attack_finished()

signal mouse_on(troop : MobileTroop)
signal mouse_left(troop : MobileTroop)

@onready var tile_grid: TileMapLayer = get_node("/root/Base/Tiles/TileGrid")
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var atk_points_label: Label = $"./Status/AtkPoints"
@onready var walk_points_label: Label = $"./Status/WalkPoints"
@onready var troop_manager: TroopManager = get_node("/root/Base/TroopManager")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var card_id : String
var attack_points : int = 1
@export var total_attack_count : int = 1
var _current_attack_count = total_attack_count
@export var attack_distance : int = 1
var oponent_to_attack : Entity
var is_attacking = false

var moviment_speed : float = 2
@export var walk_distance = 5
var _current_walk_points = walk_distance

var target_position: Vector2
var started_walk_position : Vector2
var final_walk_position : Vector2
var is_moving: bool
var _current_id_path: Array[Vector2i]
var is_exausted = false

var skill_manager : SkillManager

func _on_changed_turn(_turn):
	var troop_turn = is_entity_turn()
		
	if troop_turn:
		invigorate()

func _ready() -> void:
	base_ready()
	#define the actual poistion not walkable
	grid_controller.set_walkable_position(
		global_position,
		false
	)
	toggle_outline(false)
	update_atk_label()
	
	set_walk_points(walk_distance) 
	_current_attack_count = 0 #start with no atack 
	
	if faction == EntityFaction.ENEMY:
		$"./Status/AtkSprite".modulate = Color(1, 0, 0) 
	
	is_exausted = false
	
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
	game_controller.deselect_troop()
	grid_controller.set_walkable_position(global_position, false)
	_current_walk_points = 0
	if _current_attack_count <= 0:
		set_exausted()
	emit_signal("walk_finish")

func get_current_walk_points():
	return _current_walk_points
			
func move_troop(pos_to_go):
	if is_exausted:
		emit_signal("walk_finish")
		return
		
	if is_moving:
		emit_signal("walk_finish")
		return false
		
	if _current_walk_points <= 0:
		print("Troop ",name," Dont Have Walk Points")
		emit_signal("walk_finish")
		return
	
	var id_path = grid_controller.calculate_path(
		global_position,
		pos_to_go)
	
	if id_path.is_empty(): #verify have path
		
		print("path return 0")
		emit_signal("walk_finish")
		return false
		
	if id_path.size() > _current_walk_points:
		print("walk distance is to far to ", name)
		emit_signal("walk_finish")
		return false
	
	_current_id_path = id_path
	target_position = tile_grid.map_to_local(_current_id_path.front())
	grid_controller.set_walkable_position(global_position, true)
	
	started_walk_position = global_position
	final_walk_position = tile_grid.map_to_local(id_path.back()) 
	
	is_moving = true
	
	return is_moving
	
func set_attack_points(atk : int):
	attack_points = atk

func attack(entity : Entity):
	if not entity.is_alive():
		return
	
	if is_attacking:
		print("is already attacking")
		return
	
	
	if _current_attack_count <= 0:
		print( name, " dont have attack points ")
		emit_signal("attack_finished")
		return
	
	var distance = entity.get_distance(global_position)
	if distance > attack_distance:
		print("too far to ", name, " attack ",entity.name," distance: ",distance)
		emit_signal("attack_finished")
		return
	
	is_attacking = true
	oponent_to_attack = entity
	_perform_attack_animation()

func _perform_attack_animation():
	var start_pos = global_position
	var dir = (oponent_to_attack.global_position - start_pos).normalized()
	var charge_pos = start_pos - dir * 20      # recua um pouco
	var attack_pos = oponent_to_attack.global_position + dir * 1  # avança até o alvo, passa um pouco

	var tween = create_tween()
	tween.tween_property(self, "global_position", charge_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", attack_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position", start_pos, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.connect("finished", Callable(self, "_on_attack_animation_finished"))

func _on_attack_animation_finished():
	trigger_attack()

func trigger_attack() -> void:
	oponent_to_attack.take_damage(attack_points)
	_current_attack_count -= 1
	
	if oponent_to_attack is MobileTroop:
		take_damage(oponent_to_attack.attack_points)
		
	skill_manager.activate_skill_attack(oponent_to_attack)
		
	set_exausted()
	game_controller.deselect_troop()
	oponent_to_attack = null
	is_attacking = false
	
	emit_signal("attack_finished")
	
func invigorate():	
	_current_attack_count = total_attack_count
	_current_walk_points = walk_distance
	sprite_2d.modulate = Color(1, 1, 1)  
	
	is_exausted = false
	
func set_exausted():
	_current_attack_count = 0
	_current_walk_points = 0
	
	is_exausted = true
	sprite_2d.modulate = Color(0.5, 0.5, 0.5)  

 
func get_distance(pos : Vector2):
	var distance = grid_controller.get_distance_to_attack_in_diagonal(
		global_position,
		pos
	)
	
	return distance
	
func die():
	grid_controller.set_walkable_position(global_position, true)
	troop_manager.remove_troop(self)
	$Status.visible = false
	animation_player.play("die")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		queue_free()
	
func update_atk_label():
	atk_points_label.text = str(attack_points)
	
func get_attack_count():
	return _current_attack_count
	
func get_tile_pos():
	return tile_grid.local_to_map(global_position)
	
func can_move():
	if _current_walk_points > 0:
		return true
	else:
		return false
	
func can_attack():
	if _current_attack_count > 0:
		return true
	else:
		return false

func _on_mouse_entered() -> void:
	emit_signal("mouse_on", self)

func _on_mouse_exited() -> void:
	emit_signal("mouse_left", self)
