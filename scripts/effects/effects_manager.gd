extends Node

class_name EffectsManager

@onready var turn_controller: TurnController = $Controllers/TurnController

var entity: Entity

var effects : Array[Effect]

func _init(_entity : Entity) -> void:
	self.entity = _entity

func _ready() -> void:
	turn_controller.connect("changed_turn", Callable(self, "_on_changed_turn"))
	
func _on_changed_turn(_turn):
	pass

func process_effects_start_turn():
	for effect in effects:
		if effect.apply_momment == Effect.Moment.START_TURN:
			effect.apply_effect(entity)
			
func process_effects_end_turn():
	for effect in effects:
		if effect.apply_momment == Effect.Moment.END_TURN:
			effect.apply_effect(entity)
			
	expire_effects()
			
func expire_effects():
	for effect in effects.duplicate():
		effect.duration -= 1
		if effect.duration <= 0:
			effect.expire(entity)
			effects.erase(effect)

func add_effect(effect : Effect):
	effects.append(effect)
	if effect.apply_momment == Effect.Moment.FIXED:
		effect.apply_effect(entity)
	
func remove_effect(effect : Effect):
	effects.erase(effect)
	
