extends Area2D
class_name Food

var cell_index: int = -1

signal eaten

func _on_body_entered(body: Node2D) -> void:
	if body is Head:
		eaten.emit()
		queue_free()
