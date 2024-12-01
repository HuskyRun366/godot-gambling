extends AnimatedSprite2D
class_name card

var value = 0
var value_path = ""
var suit = ""
var is_face_up = false

var value_map = {"J":11, "Q":12, "K":13, "A":14}

func _ready():
	# Default to card back
	#texture = load("res://deck-of-cards/Back2.png")
	add_to_group("cards")
	pass

func flip(card_value:String="", back=true):
	if card_value == "":
		animation = value_path
		return
	var tex = load("res://deck-of-cards/" + card_value + ".png") as Texture2D
	var back_an = load("res://deck-of-cards/Back2.png") as Texture2D
	sprite_frames = SpriteFrames.new()
	sprite_frames.add_animation(card_value)
	sprite_frames.add_frame(card_value, tex)
	sprite_frames.add_animation("back")
	sprite_frames.add_frame("back", back_an)
	if back:
		animation = "back"
	else:
		animation = card_value

func _set_value(cards:String, bj:bool=false):
	value_path = cards
	var card_value = cards.split(".")[0]
	if card_value.split(".")[0] in ["A", "K", "Q", "J"]:
		if bj and card_value.split(".")[0] != "A":
			value = 10
			return
		if bj and card_value.split(".")[0] == "A":
			value = "A"
			return
		value = value_map[card_value]
		return
	value = int(card_value)

func remove():
	self.queue_free()
	
func get_value():
	return value
	

"""
extends Sprite2D
class_name card

var value:int = 0

# Called when the node enters the scene tree for the first time.
#var pics = []
var values = {"K":10,"Q":9,"A":11}
func _ready() -> void:
	texture = load("res://deck-of-cards/Back2.png")
	
	#var images:Array[Resource]
	#for filePath in DirAccess.get_files_at("res://deck-of-cards/"):
		#if filePath.get_extension() == "png":  
			#pics.append( load(filePath) )
	#print(pics)


func flip(card_value:String):
	texture = load("res://deck-of-cards/" + card_value + ".png")
	
func _set_value(card:String):
	var card_value = card.split(".")[0]
	if card_value in ["A", "K", "Q"]:
		value = values[card_value]
		return
	value = int(card_value)

func remove():
	self.queue_free()
	
func get_value() -> int:
	return value
"""
