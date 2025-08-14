extends Node2D

@onready var line = $Line2D
@onready var anim = $AnimationPlayer
@onready var sound = $AudioStreamPlayer2D
@export var lifetime: float = 1.0 # time in seconds

func _ready():
	# Define cor e largura
	line.width = 3
	line.default_color = Color(1, 1, 1) # branco
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func strike(target_pos: Vector2):
	# Começa o raio no topo da tela e termina no inimigo
	var start_pos = Vector2(target_pos.x, target_pos.y - 300)
	line.points = _generate_lightning_points(start_pos, target_pos)
	
	# Toca som e anima
	sound.play()
	anim.play("flash")

func _generate_lightning_points(start_pos: Vector2, end_pos: Vector2) -> PackedVector2Array:
	var points: PackedVector2Array = []
	var segments = 8
	for i in range(segments + 1):
		var t = float(i) / segments
		var pos = start_pos.lerp(end_pos, t)
		pos.x += randf_range(-10, 10) # desvio horizontal
		points.append(pos)
	return points
