extends Node2D

class_name Card

signal hovered
signal hovered_off

var card_id
var type
var attack_points : int
var life_points: int
var energy_cost : int
var description : String

var start_position

var is_dragging = false

var faction : Entity.EntityFaction

var discarded = false

func _ready() -> void:
	#All cards must be a child of CardManager or this will error
	if get_parent().has_method("connect_card_signals"):
		get_parent().connect_card_signals(self)

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
	


func set_card_data(card_data, _faction):
	
	faction = _faction
	
	card_id = card_data.card_id
	var card_image_path = str("res://textures/cards/"+card_id+".png")
	$CardImage.texture = load(card_image_path)
	$Name.text = str(card_data.name)
	$Energy.text = str(card_data.energy_cost)
	energy_cost = card_data.energy_cost
	type = card_data.type
	description = card_data.description
	if card_data.type == "monster":
		$Attack.text = str(card_data.attack)
		attack_points = int(card_data.attack)
		$Health.text = str(card_data.health)
		life_points = int(card_data.health)
	else:
		$Attack.visible = false 
		$Health.visible = false
		$CardTemplate/Atk.visible = false 
		$CardTemplate/Life.visible = false
	
	name = generate_id()
	
	return self
	
func generate_id():
	return str(card_id + "_"+Entity.EntityFaction.keys()[faction] +"_"+str(randi()))

func remove_card():
	discarded = true
	$Area2D/CollisionShape2D.disabled = true
	$AnimationPlayer.play("disappear")
	$RemoveSprite.visible = false
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "disappear":
		queue_free()
