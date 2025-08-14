extends Control

class_name Mouse

@onready var game_controller: GameController = get_node("/root/Base/Controllers/GameController")
@onready var troop_manager: TroopManager = get_node("/root/Base/TroopManager")

const cursor_attack_texture = preload("res://textures/crawl-tiles Oct-5-2010/item/weapon/long_sword1.png")
const TRAVEL_EXCLUSION_CENTRE = preload("res://textures/crawl-tiles Oct-5-2010/dc-misc/travel_exclusion_centre.png")
const BOOTS_1_BROWN = preload("res://textures/crawl-tiles Oct-5-2010/item/armour/boots1_brown.png")
const AIM = preload("res://textures/crawl-tiles Oct-5-2010/dc-misc/cursor_red.png")

var current_troop_select

var current_mouse_style = MouseStyle.NORMAL
enum MouseStyle{
	NORMAL,
	MOVE,
	ATTACK,
	CANCEL,
	AIM
}

func _ready():
	game_controller.on_select_tropp.connect(_on_select_troop)
	game_controller.on_deselect_troop.connect(_on_deselect_troop)
	troop_manager.mouse_on_troop.connect(_mouse_on_troop)
	troop_manager.mouse_left_troop.connect(_mouse_left_troop)

func _on_select_troop(_troop):
	set_cursor_boots()
	
func _on_deselect_troop(_troop):
	set_cursor_normal()
	
func _mouse_on_troop(troop):
	if not game_controller.is_running_state():
		return
	
	if game_controller.selected_troop and troop.faction == Entity.EntityFaction.ENEMY:
		set_cursor_attack()
	else:
		set_cursor_normal()
		
	current_troop_select = troop
	
func _mouse_left_troop(troop):
	if not game_controller.is_running_state():
		return
		
	if troop == current_troop_select:
		if game_controller.selected_troop:
			set_cursor_boots()
		else:
			set_cursor_normal()
		
		current_troop_select = null

func set_cursor_normal():
	Input.set_custom_mouse_cursor(null)
	current_mouse_style = MouseStyle.NORMAL
	return current_mouse_style
	
func set_cursor_cancel():
	Input.set_custom_mouse_cursor(TRAVEL_EXCLUSION_CENTRE, Input.CURSOR_ARROW, Vector2(16, 16))
	current_mouse_style = MouseStyle.CANCEL
	return current_mouse_style
	
func set_cursor_attack():
	Input.set_custom_mouse_cursor(cursor_attack_texture, Input.CURSOR_ARROW, Vector2(16, 16))
	current_mouse_style = MouseStyle.ATTACK
	return current_mouse_style
	
func set_cursor_boots():
	Input.set_custom_mouse_cursor(BOOTS_1_BROWN, Input.CURSOR_ARROW, Vector2(16, 16))
	current_mouse_style = MouseStyle.MOVE
	return current_mouse_style
	
func set_cursor_aim():
	Input.set_custom_mouse_cursor(AIM, Input.CURSOR_ARROW, Vector2(16, 16))
	current_mouse_style = MouseStyle.AIM
	return current_mouse_style
