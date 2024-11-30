extends Node2D

@onready var call = $call
@onready var raise = $raise
@onready var fold = $fold
# Called when the node enters the scene tree for the first time.
#signal call
func _ready() -> void:
	call.pressed.connect(_on_call)
	raise.pressed.connect(_on_raise)
	fold.pressed.connect(_on_fold)
	
	#self.call.connect(self._on_call())


func _on_call():
	print("called from main")

func _on_fold():
	print("folded from main")
	
func _on_raise():
	print("raised from main")
