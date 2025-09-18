extends Node2D

# set of cells
# 12 x 12

# scenes
const CELLSCENE = preload("res://scenes/cell.tscn")
const FOODSCENE = preload("res://scenes/food.tscn")

#
@onready var head: Head = $head
@onready var cell_container: Node = $"cell container"
@onready var food_container: Node = $"food container"
@onready var timer: Timer = $"food container/Timer"

# var
var cells: Array[Cell] = []
var h: Array[Head] =[]

func _ready() -> void:
	#initial snake pos
	h.append(head)
	head.position = Vector2(1,1) * Globals.CELL_SIZE
	head.moved.connect(update_cell)
	head.is_collide.connect(is_next_occupied)
	#initial body length
	for i in 6:
		head.add_body()
	#init cell
	for x in Globals.PLAY_AREA.x:
		for y in Globals.PLAY_AREA.y:
			var new_cell = CELLSCENE.instantiate();
			cell_container.add_child(new_cell)
			cells.append(new_cell)
			new_cell.position = Vector2(x,y) * Globals.CELL_SIZE
			new_cell.coordinate = Vector2(x,y)
#			new_cell.set_label(get_cell_index(new_cell.position))
	
	timer.timeout.connect(spawn_food)
	spawn_food()
	

func _process(delta: float) -> void:
	for he in h:
		he.move(delta)

func spawn_food()-> void:
	var pos = rand_position()
	
	while is_cell_occupied(pos):
		pos = rand_position()
	
	var new_food = FOODSCENE.instantiate()
	food_container.add_child(new_food)
	new_food.position = pos
	
	var index = get_cell_index(pos)
	new_food.cell_index = index
	new_food.eaten.connect(func(): head.add_body())
	cells[index].occupy_rat()

func rand_position() -> Vector2:
	var x: int = randi_range(0, Globals.PLAY_AREA.x - 1) * Globals.CELL_SIZE
	var y: int = randi_range(0, Globals.PLAY_AREA.y - 1) * Globals.CELL_SIZE
	return Vector2(x,y)

func is_cell_occupied(pos: Vector2) -> bool:
	var index = get_cell_index(pos)
	if index >= 0 and index < cells.size():
		return cells[index].is_occupied
	return false

func is_next_occupied(pos: Vector2) -> void:
	var t = is_cell_occupied(pos)
	if t:
		var index = get_cell_index(pos)
		if cells[index].is_snake_occupied():
			head.is_next_safe = false
	else:
		head.is_next_safe = true
	
func update_cell(new_pos: Vector2, length: int) -> void:
	var index = get_cell_index(new_pos)
	
	# First, tick ALL existing occupied cells
	for i in cells.size():
		if cells[i].is_occupied:
			cells[i].tick()
	
	# Then, mark the NEW head cell
	cells[index].occupy_snake(length)

func get_cell_index(pos: Vector2)-> int:
	var grid_x = int(pos.x / Globals.CELL_SIZE)
	var grid_y = int(pos.y / Globals.CELL_SIZE)
	return grid_y * int(Globals.PLAY_AREA.x) + grid_x




	
	
