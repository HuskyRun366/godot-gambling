extends Sprite2D

var value:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func flip(card:int):
	pass
	
func remove():
	self.queue_free()
	
func get_value() -> int:
	return value
