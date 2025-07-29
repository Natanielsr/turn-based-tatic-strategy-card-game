extends Effect

class_name ProvokeEffect

const CLOUD_BLACK_SMOKE = preload("res://textures/crawl-tiles Oct-5-2010/effect/cloud_black_smoke.png")
const PLAGUE_PARTICLE = preload("res://particles/plague_particle.tscn")

var entity : Entity
var provoker : Entity

func _init(_provoker : Entity, _target : Entity) -> void:
	super._init("Provoked by "+_provoker.name, 3, Moment.START_TURN, CLOUD_BLACK_SMOKE, PLAGUE_PARTICLE)
	self.provoker = _provoker
	self.entity = _target
	provoker.died.connect(_on_provoker_died)
	
func apply_effect(_entity : Entity):
	self.entity = _entity
	spawn_particle(_entity.global_position)
	print("%s provoked by %s!" % [entity.name, provoker.name])
	
func _on_provoker_died(_provoker, _killed_by):
	if entity:
		entity.effects_manager.remove_effect(self)
	
