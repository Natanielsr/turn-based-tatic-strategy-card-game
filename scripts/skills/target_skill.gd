extends Skill

class_name TargetSkill

@onready var game_controller: GameController = get_node("/root/Base/Controllers/GameController")
@onready var mouse: Mouse = get_node("/root/Base/UI/Mouse")

func _init(
	_skill_name : String,
	_description : String,
	_image : Texture2D,
	_particle,
	_type : Type,
	_skill_owner : Entity) -> void:
	super._init(
		_skill_name,
		_description,
		 _image,
		_particle,
		_type,
		_skill_owner
		)

func activate(_target : Entity):
	changeGameStateToLookingTarget()
	set_mouse_to_aim()

func target_entity(_target: Entity):
	self.target = _target
	spawn_particle(target.position)
	
	execute(target)
	
	set_state_to_running()
	set_mouse_to_normal()
	
func execute(_target: Entity):
	pass
	
func changeGameStateToLookingTarget():
	game_controller.change_to_target_waiting(self)
	
func set_mouse_to_aim():
	if skill_owner.faction == Entity.EntityFaction.ALLY:
		mouse.set_cursor_aim()
	
func set_state_to_running():
	game_controller.change_game_state(GameController.GameState.RUNNING)

func set_mouse_to_normal():
	mouse.set_cursor_normal()
