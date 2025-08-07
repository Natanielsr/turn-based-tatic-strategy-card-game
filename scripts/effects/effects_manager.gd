extends Node

class_name EffectsManager
var turn_controller: TurnController

var entity: Entity

var effects : Array[Effect]

func _init(_entity : Entity) -> void:
	self.entity = _entity
	entity.died.connect(_on_entity_died)
	name = "EffectsManager"

func _on_entity_died(_entity_died, _killed_by) -> void:
	queue_free()
		
func set_turn_controller(_turn_controller: TurnController):
	
	turn_controller = _turn_controller
	
	if entity.faction == Entity.EntityFaction.ALLY:
		turn_controller.player_start_turn.connect(process_effects_start_turn)
		turn_controller.player_end_turn.connect(process_effects_end_turn)
	elif entity.faction == Entity.EntityFaction.ENEMY:
		turn_controller.enemy_start_turn.connect(process_effects_start_turn)
		turn_controller.enemy_end_turn.connect(process_effects_end_turn)
	
func _on_changed_turn(_turn):
	pass

func process_effects_start_turn():
	for effect in effects:
		if effect.apply_momment == Effect.Moment.START_TURN:
			effect.apply_effect(entity)
			expire_effect(effect)
			
func process_effects_end_turn():
	for effect in effects:
		if effect.apply_momment == Effect.Moment.END_TURN:
			effect.apply_effect(entity)
			expire_effect(effect)
			
	
			
func expire_effect(effect : Effect):
	effect.duration -= 1
	if effect.duration <= 0:
		effect.expire(entity)
		effects.erase(effect)

func add_effect(effect : Effect):
	effects.append(effect)
	add_child(effect)
	if effect.apply_momment == Effect.Moment.FIXED:
		effect.apply_effect(entity)
	
	
	
func remove_effect(effect : Effect):
	effects.erase(effect)
	
func get_effect(effect_class_type):
	for effect in effects:
		if effect.get_script() == effect_class_type:
			return effect
	
	return null
