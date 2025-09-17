extends Node2D
class_name Cell

enum CellType {EMPTY, RAT, SNAKE}
var type: CellType = CellType.EMPTY
var coordinate: Vector2
var occupied_for: int = 0
var is_occupied: bool:
	get:
		return occupied_for > 0
var body_index: int = -1
#@onready var label: Label = $Label
#
#func set_label(ind: int)-> void:
	#label.text = str(ind)

func occupy_snake(duration: int)-> void:
	type = CellType.SNAKE
	occupied_for = duration

func occupy_rat()-> void:
	type = CellType.RAT
	occupied_for = 999999

func clear()-> void:
	type = CellType.EMPTY
	occupied_for = 0

func tick()-> void:
	if type == CellType.SNAKE and occupied_for > 0:
		occupied_for -= 1
		if occupied_for == 0:
			type = CellType.EMPTY

func is_snake_occupied()-> bool:
	if type == CellType.SNAKE:
		return true
	else:
		return false
