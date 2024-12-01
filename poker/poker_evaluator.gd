extends Node
# PokerHandEvaluator.gd
class_name poker_ev

# Define the Suit enum for clarity
enum Suit { HEARTS, DIAMONDS, CLUBS, SPADES }

# Define the Card class
class Card:
	var rank: int    # Rank from 2 to 14 (where 11=Jack, 12=Queen, 13=King, 14=Ace)
	var suit: int    # Suit based on the Suit enum

	func _init(rank: int, suit: int):
		self.rank = rank
		self.suit = suit

# Function to evaluate the best poker hand from 7 cards
func evaluate_best_hand(hole_cards: Array, community_cards: Array):
	# Combine hole cards and community cards
	var all_cards: Array = hole_cards + community_cards

	# Generate all possible 5-card combinations from the 7 cards
	var combinations = get_combinations(all_cards, 5)

	var best_hand_rank = -1
	#var best_hand_type = ""
	var best_hand_type = 0

	for hand in combinations:
		var hand_rank = evaluate_hand_rank(hand)
		if hand_rank > best_hand_rank:
			best_hand_rank = hand_rank
			#best_hand_type = get_hand_name(hand_rank)
			best_hand_type = hand_rank

	return best_hand_type

# Helper function to generate combinations
func get_combinations(arr: Array, n: int) -> Array:
	if n == 0:
		return [[]]
	if arr.size() == 0:
		return []
	var result = []
	var first = arr[0]
	var rest = arr.slice(1, arr.size())
	for c in get_combinations(rest, n - 1):
		result.append([first] + c)
	result += get_combinations(rest, n)
	return result

# Function to evaluate the rank of a hand
func evaluate_hand_rank(hand: Array) -> int:
	# Ranks for hand types (higher is better)
	const HAND_RANKS = {
		"High Card": 1,
		"One Pair": 2,
		"Two Pair": 3,
		"Three of a Kind": 4,
		"Straight": 5,
		"Flush": 6,
		"Full House": 7,
		"Four of a Kind": 8,
		"Straight Flush": 9,
		"Royal Flush": 10
	}

	# Extract ranks and suits
	var ranks: Array = []
	var suits: Array = []
	for card1 in hand:
		ranks.append(card1.rank)
		suits.append(card1.suit)

	# Sort ranks
	ranks.sort()

	# Check for Flush
	var suit_counts = {}
	for suit in suits:
		suit_counts[suit] = suit_counts.get(suit, 0) + 1
	var is_flush: bool = suit_counts.values().has(5)

	# Check for Straight
	var is_straight = check_straight(ranks)

	# Special case for Ace-low straight (A-2-3-4-5)
	if ranks == [2, 3, 4, 5, 14]:
		is_straight = true

	# Count occurrences of each rank
	var rank_counts = {}
	for rank in ranks:
		rank_counts[rank] = rank_counts.get(rank, 0) + 1

	# Get counts of each rank frequency
	var counts = rank_counts.values()
	counts.sort()

	# Determine hand type and rank
	if is_straight and is_flush:
		if ranks[-1] == 14 and ranks[0] == 10:
			return HAND_RANKS["Royal Flush"]
		else:
			return HAND_RANKS["Straight Flush"]
	elif counts == [1, 4]:
		return HAND_RANKS["Four of a Kind"]
	elif counts == [2, 3]:
		return HAND_RANKS["Full House"]
	elif is_flush:
		return HAND_RANKS["Flush"]
	elif is_straight:
		return HAND_RANKS["Straight"]
	elif counts == [1, 1, 3]:
		return HAND_RANKS["Three of a Kind"]
	elif counts == [1, 2, 2]:
		return HAND_RANKS["Two Pair"]
	elif counts == [1, 1, 1, 2]:
		return HAND_RANKS["One Pair"]
	else:
		return HAND_RANKS["High Card"]

# Helper function to check for a straight
func check_straight(ranks: Array) -> bool:
	ranks = ranks.duplicate()
	ranks.sort()
	for i in range(len(ranks) - 1):
		if ranks[i + 1] != ranks[i] + 1:
			# Check for Ace-low straight
			if ranks == [2, 3, 4, 5, 14]:
				return true
			return false
	return true

# Helper function to get hand name from rank
func get_hand_name(rank: int) -> String:
	var HAND_NAMES = [
		"High Card",
		"One Pair",
		"Two Pair",
		"Three of a Kind",
		"Straight",
		"Flush",
		"Full House",
		"Four of a Kind",
		"Straight Flush",
		"Royal Flush"
	]
	return HAND_NAMES[rank - 1]


"""
# Example usage:
func _ready():
	# Hole cards
	var hole_cards = [
		Card.new(14, Suit.HEARTS),  # Ace of Hearts
		Card.new(13, Suit.SPADES)   # King of Spades
	]

	# Community cards
	var community_cards = [
		Card.new(12, Suit.HEARTS),  # Queen of Hearts
		Card.new(11, Suit.HEARTS),  # Jack of Hearts
		Card.new(10, Suit.HEARTS),  # 10 of Hearts
		Card.new(2, Suit.CLUBS),    # 2 of Clubs
		Card.new(3, Suit.DIAMONDS)  # 3 of Diamonds
	]

	var result = evaluate_best_hand(hole_cards, community_cards)
	print("Best Hand: ", result)  # Output: Best Hand: Royal Flush
"""
