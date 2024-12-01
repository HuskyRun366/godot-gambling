extends Node

@onready var callb = $callb
@onready var raise = $raise
@onready var fold = $fold
@onready var player2List = $Player2Zone

const FIRST_POS = Vector2(381,241)
const SEC_POS = Vector2(480,241)
const THIR_POS = Vector2(577,241)
const FOU_POS = Vector2(678, 241)
const FITH_POS = Vector2(770, 241)
const HAND_POS = Vector2(939,571)
const HAND2_POS = Vector2(1031,571)
const P1C1 = Vector2(184, 377)
const P1C2 = Vector2(254, 377)
const P2C1 = Vector2(184, 111)
const P2C2 = Vector2(254, 111)
const P3C1 = Vector2(900, 111)
const P3C2 = Vector2(975,111)
const P4C1 = Vector2(903, 377)
const P4C2 = Vector2(973, 377)

const SCALE = Vector2(1.35,1.35)
const NPC_SCALE = Vector2(1.1, 1.1)

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

var cp_cards = []

var p1_cards = []
var p2_cards = []
var p3_cards = []
var p4_cards = []
var own_cards = []
var com_cards = []

var p1_values = []
var p2_values = []
var p3_values = []
var p4_values = []
var own_values = []
var com_values = []

var bb:int
var sb:int

var active_players = [1,2,3,4,5]
var winner = []

var game_state:int

#enum Suit { HEARTS, DIAMONDS, CLUBS, SPADES }

# 2 = Hearts
# 4 = Diamonds
# 5 = Spade
# 7 = Clubs

func _ready() -> void:
	callb.pressed.connect(_on_call)
	raise.pressed.connect(_on_raise)
	fold.pressed.connect(_on_fold)
	_start_game()
	
func _to_enum(card_strings:Array):
	var suit_mapping = {
		"2": poker_ev.Suit.HEARTS,
		"4": poker_ev.Suit.DIAMONDS,
		"5": poker_ev.Suit.SPADES,
		"7": poker_ev.Suit.CLUBS
		}
	# Mapping from card face strings to rank integers
	var rank_mapping = {
		"2": 2,
		"3": 3,
		"4": 4,
		"5": 5,
		"6": 6,
		"7": 7,
		"8": 8,
		"9": 9,
		"10": 10,
		"J": 11,
		"Q": 12,
		"K": 13,
		"A": 14
	}
	var cards = []
	for card_str in card_strings:
		var parts = card_str.split(".")
		if parts.size() != 2:
			push_error("Invalid card format: " + card_str)
			continue
		var rank_str = parts[0]
		var suit_code = parts[1]

		# Get rank and suit
		var rank = rank_mapping.get(rank_str)
		var suit = suit_mapping.get(suit_code)

		if rank == null:
			push_error("Invalid rank in card: " + card_str)
			continue
		if suit == null:
			push_error("Invalid suit code in card: " + card_str)
			continue
		var card1 = poker_ev.Card.new(rank,	suit)
		cards.append(card1)
	return cards
	
func add_card(card_pos:Vector2, value:String, array:Array, value_arr:Array ,is_npc=true, flip=false):
	var n_card = card.new()
	n_card.flip(value, !flip)
	n_card.position = card_pos
	n_card._set_value(value)
	#n_card.visible = true
	if is_npc:
		n_card.apply_scale(NPC_SCALE)
	else:
		n_card.apply_scale(SCALE)
	array.append(n_card)
	value_arr.append(value)
	add_child(n_card)
	
func _add_public_cards(state:int):
	match state:
		1:
			add_card(FIRST_POS, cp_cards[0], com_cards, com_values, false, true)
			cp_cards.pop_front()
			add_card(SEC_POS, cp_cards[0], com_cards, com_values, false, true)
			cp_cards.pop_front()
			add_card(THIR_POS, cp_cards[0], com_cards, com_values, false, true)
			cp_cards.pop_front()
		2:
			add_card(FOU_POS, cp_cards[0], com_cards, com_values, false, true)
			cp_cards.pop_front()
		3:
			add_card(FITH_POS, cp_cards[0], com_cards, com_values, false, true)
			cp_cards.pop_front()
	

func _start_game():
	cp_cards = cards.duplicate()
	cp_cards.shuffle()
	_add_npc_card(1)
	_add_npc_card(2)
	_add_npc_card(3)
	_add_npc_card(4)
	_deal_cards()
	_set_bb()
	_add_public_cards(1)
	_add_public_cards(2)
	_add_public_cards(3)
	print("own hand", _rank_hand(own_values))
	print("P1 hand", _rank_hand(p1_values))
	print("P2 hand", _rank_hand(p2_values))
	print("P3 hand", _rank_hand(p3_values))
	print("P4 hand", _rank_hand(p4_values))
	
	var temp = [
		_rank_hand(own_values),
		_rank_hand(p1_values),
		_rank_hand(p2_values),
		_rank_hand(p3_values),
		_rank_hand(p4_values)
	]
	var winning_hand = temp.max()
	print(winning_hand)
	if winning_hand == _rank_hand(own_values):
		print("Winner is you")
		winner.append(5)
	if winning_hand == _rank_hand(p1_values):
		print("Winner is Player 1")
		winner.append(1)
	if winning_hand == _rank_hand(p2_values):
		print("Winner is Player 2")
		winner.append(2)
	if winning_hand == _rank_hand(p3_values):
		print("Winner is Player 3")
		winner.append(3)
	if winning_hand == _rank_hand(p4_values):
		print("Winner is Player 4")
		winner.append(4)
	print("Winner is", winner)
	"""
	_rank_hand(own_values)
	_rank_hand(p1_values)
	_rank_hand(p2_values)
	_rank_hand(p3_values)
	_rank_hand(p4_values)
	_add_public_cards(1)
	_add_public_cards(2)
	_add_public_cards(3)
	for i in p1_cards:
		i.flip()
	for j in p2_cards:
		j.flip()
	for h in p3_cards:
		h.flip()
	for g in p4_cards:
		g.flip()
	"""
	
func _add_npc_card(npc_number:int):
	match npc_number:
		1:
			add_card(P1C1, cp_cards[0], p1_cards, p1_values, true)
			cp_cards.pop_front()
			add_card(P1C2, cp_cards[0], p1_cards, p1_values, true)
			cp_cards.pop_front()
		2:
			add_card(P2C1, cp_cards[0], p2_cards, p2_values, true)
			cp_cards.pop_front()
			add_card(P2C2, cp_cards[0], p2_cards, p2_values, true)
			cp_cards.pop_front()
		3:
			add_card(P3C1, cp_cards[0], p3_cards, p3_values, true)
			cp_cards.pop_front()
			add_card(P3C2, cp_cards[0], p3_cards, p3_values, true)
			cp_cards.pop_front()
		4:
			add_card(P4C1, cp_cards[0], p4_cards, p4_values, true)
			cp_cards.pop_front()
			add_card(P4C2, cp_cards[0], p4_cards, p4_values, true)
			cp_cards.pop_front()
	
func _deal_cards():
	add_card(HAND_POS, cp_cards[0], own_cards, own_values ,false, true)
	cp_cards.pop_front()
	add_card(HAND2_POS, cp_cards[0], own_cards, own_values, false, true)
	cp_cards.pop_front()
	
func _set_bb():
	var rng = RandomNumberGenerator.new()
	bb = rng.randi_range(1,5)
	if bb == 5:
		sb = 1
		return
	sb += 1
	
func _npc_turn():
	pass
	
func to_fold(player:int):
	if active_players.size() == 1:
		winner = active_players[0]
		return
	if  active_players.is_empty():
		return
	if active_players.find(player) != -1:
		active_players.pop_at(active_players.find(player))
	if active_players.size() == 1:
		winner.clear()
		winner = active_players[0]
	
func _rank_hand(hand:Array):
	var temp = poker_ev.new()
	var test = temp.evaluate_best_hand(_to_enum(hand), _to_enum(com_values))
	return test

func _on_call():
	print("called from main")

func _on_fold():
	to_fold(5)
	print(active_players)
	#print("folded from main")
	
	
func _on_raise():
	print("raised from main")
