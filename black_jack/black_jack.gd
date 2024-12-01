extends Node2D

@onready var cardb = $card
@onready var holdb = $hold
@onready var reset = $reset
@onready var label = $Label
@onready var own_value = $own_value
@onready var dealer_value = $dealer_value
@onready var reset_money = $reset_money
@onready var bet_set = $bet_value
@onready var cur_mon = $current_money
@onready var split = $split
@onready var insurance = $insurance
@onready var ins_bet_val = $ins_bet_val
@onready var insure_box = $insure
@onready var ins_out = $ins_label

var HAND_POS = Vector2(939,571)
const HAND2_POS = Vector2(1031,571)

const DEALER1_POS = Vector2(480,241)
var DEALER2_POS = Vector2(577,241)

var SPLIT_POS = Vector2(946, 384)

const SCALE = Vector2(1.35,1.35)
const NPC_SCALE = Vector2(1.1, 1.1)

var winner:int
var active_players = []

var cp_cards = []

var bet_amount:int
var split_bet:int
var won_insurance:bool
var accepted_insurance:bool
var insurance_am:int

var bj:bool

var cards = [
	"2.2", "2.4", "2.5", "2.7",
	"3.2", "3.4", "3.5", "3.7",
	"4.2", "4.4", "4.5", "4.7",
	"5.2", "5.4", "5.5", "5.7",
	"6.2", "6.4", "6.5", "6.7",
	"7.2", "7.4", "7.5", "7.7",
	"8.2", "8.4", "8.5", "8.7",
	"9.2", "9.4", "9.5", "9.7",
	"10.2", "10.4", "10.5", "10.7",
	"J.2", "J.4", "J.5", "J.7",
	"Q.2", "Q.4", "Q.5", "Q.7",
	"K.2", "K.4", "K.5", "K.7",
	"A.2", "A.4", "A.5", "A.7"
]

var own_cards = []
var dealer_cards = []

var own_values = []
var dealer_values = []

var split_cards = []
var split_values = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cardb.pressed.connect(_on_draw)
	holdb.pressed.connect(_on_hold)
	reset.pressed.connect(_on_reset)
	reset_money.pressed.connect(_on_m_reset)
	insurance.pressed.connect(_on_insure)
	split.pressed.connect(_on_split)
	split.visible = false
	insurance.visible = false
	ins_bet_val.visible = false
	insure_box.visible = false
	_start_game()
	
func _start_game():
	update_money(SimpleSave.data["money"])
	cp_cards = cards.duplicate()
	cp_cards.shuffle()
	add_dealer()
	add_own()
	
func add_card(card_pos:Vector2, value:String, array:Array, value_arr:Array ,is_npc=true, flip=false):
	var n_card = card.new()
	n_card.flip(value, !flip)
	n_card.position = card_pos
	n_card._set_value(value, true)
	#n_card.visible = true
	if is_npc:
		n_card.apply_scale(NPC_SCALE)
	else:
		n_card.apply_scale(SCALE)
	array.append(n_card)
	value_arr.append(n_card.get_value())
	add_child(n_card)

func add_dealer():
	add_card(DEALER1_POS, cp_cards.pop_front(), dealer_cards, dealer_values, false, true)
	add_card(DEALER2_POS, cp_cards.pop_front(), dealer_cards, dealer_values, false)
	
		
	if dealer_values[0] is String:
		insurance.visible = true
		if sum_array(dealer_values) == 21:
			won_insurance = true
		dealer_value.text = str(11)
		return
	dealer_value.text = str(dealer_values[0])
	
func add_own():
	add_card(HAND_POS, cp_cards.pop_front(), own_cards, own_values, false, true)
	add_card(HAND2_POS, cp_cards.pop_front(), own_cards, own_values, false, true)
	
	if str(own_values[0]) == str(own_values[1]):
		#split.visible = true
		pass
	if sum_array(own_values) == 21:
		bj = true
		if sum_array(dealer_values) == 21:
			bj = false
	own_value.text = str(sum_array(own_values))
	
func draw_card():
	HAND_POS = HAND_POS + Vector2(-60, 0)
	add_card(HAND_POS, cp_cards.pop_front(), own_cards, own_values, false, true)

	own_value.text = str(sum_array(own_values))
	
	#for i in own_values:
		#if own_values.count(own_values[i]) > 1:
			#split.visible = true
			#pass
			
	if sum_array(own_values) == 21:
		if 7 in own_values:
			bj = true
	if sum_array(own_values) > 21:
		cardb.disabled = true
		holdb.disabled = true
		dealer_cards[1].flip()
		winner = 6
		win()
	
func draw_dealer():
	DEALER2_POS = DEALER2_POS + Vector2(+60, 0)
	add_card(DEALER2_POS, cp_cards.pop_front(), dealer_cards, dealer_values, false, true)

	dealer_value.text = str(sum_array(dealer_values))
	if sum_array(dealer_values) > 21:
		cardb.disabled = true
		holdb.disabled = true
		dealer_cards[1].flip()
		winner = 5
		win()
		return
	
func sum_array(array:Array):
	array.sort()
	for j in array:
		if j is String:
			array.append(array.pop_at(array.find(j)))
	var sum = 0.0
	for element in array:
		if element is String:
			if min(abs(sum + 1 - 21), abs(sum + 11 - 21)) == abs(sum + 1 - 21) and sum != 0 or sum+11 > 21:
				sum += 1
			else:
				sum += 11
		else:
			sum += element
	return sum
	
func hold(player:int):
	active_players.pop_at(active_players.find(player))
	if accepted_insurance:
		insurance_am = ins_bet_val.value
		insure_box.visible = false
	cardb.disabled = true
	holdb.disabled = true
	dealer_cards[1].flip()
	dealer_value.text = str(sum_array(dealer_values))
	
	while sum_array(dealer_values) < 17:
		draw_dealer()
	if sum_array(dealer_values) > 21:
		winner = 5
		win()
		return
	if sum_array(own_values) == sum_array(dealer_values):
		win(true)
		return
	if sum_array(own_values) < sum_array(dealer_values):
		winner = 6
		win()
	else:
		winner = 5
		win()
		
	
func win(draw_c=false):
	if draw_c:
		label.text = "It's a draw"
		return
	var win_str = ""
	if accepted_insurance:
		if won_insurance:
			SimpleSave.data["money"] += insurance_am
			ins_out.text = "You won the insurance"
		else:
			SimpleSave.data["money"] -= insurance_am
			ins_out.text = "You lost the insurance"
	match winner:
		5:
			if bj:
				SimpleSave.data["money"] += bet_amount * 1.5
				label.text = "You won the black jack"
			else:
				SimpleSave.data["money"] += bet_amount
				label.text = "You won the game"
			update_money(SimpleSave.data["money"])
		6:
			SimpleSave.data["money"] -= bet_amount
			update_money(SimpleSave.data["money"])
			label.text = "Dealer won the game"
	#print("The Winner Number is ", winner)
	
func update_money(amount):
	cur_mon.text = str(amount)
	
func reset_game():
	for i in dealer_cards:
		i.remove()
	for j in own_cards:
		j.remove()
	own_cards = []
	own_values = []
	dealer_cards = []
	dealer_values = []
	
	holdb.disabled = false
	cardb.disabled = false
	bet_set.visible = true
	split.visible = false
	insurance.visible = false
	insurance.disabled = false
	accepted_insurance = false
	won_insurance = false
	ins_bet_val.visible = false
	insure_box.visible = false
	
	label.text = ""
	ins_out.text = ""
	ins_bet_val.value = 10
	bet_set.value = 10
	DEALER2_POS = Vector2(577,241)
	HAND_POS = Vector2(939,571)
	_start_game()
	
func bet():
	bet_amount = bet_set.value
	bet_set.visible = false
	
func _on_reset():
	reset_game()

func _on_hold():
	bet()
	hold(5)
	
func _on_draw():
	bet()
	draw_card()
	
func _on_m_reset():
	update_money(1000)
	SimpleSave.data["money"] = 1000
	
func _on_split():
	for i in own_cards.duplicate().size():
		if own_values.count(own_values[i]) == 2:
			print(own_values[i])
			split_cards.append(own_cards[i])
			split_values.append(own_values[i])
			own_cards.pop_at(own_cards.find(i))
			own_values.pop_at(own_values.find(own_values[i]))
	for j in split_cards:
		j.position = SPLIT_POS
		SPLIT_POS += Vector2(-60,0)

func _on_insure():
	insurance.disabled = true
	accepted_insurance = true
	ins_bet_val.visible = true
	insure_box.visible = true
	
