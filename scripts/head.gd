extends Node2D
class_name Head
#TODO enum walkstate
#const
const PLAY_AREA = Globals.PLAY_AREA
const MOVE_DELAY: float = 0.4
#var
var direction: Vector2 = Vector2.RIGHT
var move_timer: float = 0.0
var direction_modifier:int = 1
#body
var bodies: Array[Body] = []
var length: int:
	get:
		return bodies.size() + 1
		
const HEADSCENE = preload("res://scenes/head.tscn")
const BODYSCENE = preload("res://scenes/body.tscn")

#signal
signal moved(new_pos: Vector2, length: int)

#collide signal
signal is_collide(next_pos: Vector2)
var is_next_safe: bool = true

signal splitted(new_head: Head)


	
func _input(event: InputEvent) -> void:
	var input_dir := Vector2.ZERO

	if event.is_action_pressed("Up"):
		input_dir = Vector2.UP
	elif event.is_action_pressed("Down"):
		input_dir = Vector2.DOWN
	elif event.is_action_pressed("Right"):
		input_dir = Vector2.RIGHT
	elif event.is_action_pressed("Left"):
		input_dir = Vector2.LEFT

	if input_dir != Vector2.ZERO and input_dir != -direction:
		direction = input_dir * direction_modifier

func move(delta: float)-> void:
	move_timer += delta
	
	if move_timer >= MOVE_DELAY:
		move_timer = 0
		
		var old_pos: Vector2 = position
		
		
		var next_pos = position + direction * Globals.CELL_SIZE
		is_collide.emit(next_pos)
		
		if valid_play_area(next_pos) and is_next_safe:			
			position += direction * Globals.CELL_SIZE
			
			moved.emit(position, length)
			
			var prev_pos: Vector2 = old_pos
			for body in bodies:
				var temp: Vector2 = body.position
				body.move(prev_pos)
				prev_pos = temp

func valid_play_area(target: Vector2) -> bool:
	return target.x >= 0 \
		and target.y >= 0 \
		and target.x < PLAY_AREA.x * Globals.CELL_SIZE \
		and target.y < PLAY_AREA.y * Globals.CELL_SIZE

func add_body()-> void:
	var new_body = BODYSCENE.instantiate()
	get_parent().add_child(new_body)
	if bodies.size() > 0:
		new_body.position = bodies[-1].position
	else:
		new_body.position = position
	bodies.append(new_body)
	

func split_body()-> void:
	var next_pos = position + direction * Globals.CELL_SIZE
	var hit_index: int = -1
	for i in range(bodies.size()):
		if bodies[i].position == next_pos:
			hit_index = i
			break
	
	if hit_index == -1:
		return
	
	if hit_index >= bodies.size() - 1:#delete last node
		return
	
	var new_head_pos: Vector2 = bodies[hit_index + 1].position
	var new_head = HEADSCENE.instantiate()
	new_head.position = new_head_pos
	new_head.direction = -direction
	get_parent().add_child(new_head)
	splitted.emit(new_head)
	direction_modifier *= -1
	
	var tail_nodes: Array = bodies.slice(hit_index + 1, bodies.size())
	
	for node: Body in tail_nodes:
		new_head.bodies.append(node)
	
	var colliding = bodies[hit_index]
	if colliding.get_parent():
		colliding.get_parent().remove_child(colliding)
	colliding.queue_free()
	
	bodies = bodies.slice(0,hit_index)
	print("Split at index: ", hit_index, " -> new head with ", new_head.bodies.size(), " bodies.ss")
	
	
func get_cell_index(pos: Vector2)-> int:
	var grid_x = int(pos.x / Globals.CELL_SIZE)
	var grid_y = int(pos.y / Globals.CELL_SIZE)
	return grid_y * int(Globals.PLAY_AREA.x) + grid_x
