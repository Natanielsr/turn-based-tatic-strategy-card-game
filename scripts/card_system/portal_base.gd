extends Node2D

class_name PortalBase

const PORTAL = preload("res://sounds/Portal.ogg")
@onready var sound_fx: SoundFX = $"../../Sound/SoundFX"

var cards_to_trade = 0

func trade_card(_card : Card):
	if have_points_to_trade():
		sound_fx.play_temp_sound(PORTAL, global_position)
		cards_to_trade -= 1
		execute_trade(_card)
		
func execute_trade(_card):
	pass

func have_points_to_trade():
	if cards_to_trade > 0:
		return true
	else:
		return false
