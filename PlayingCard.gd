class_name PlayingCard
enum Suit {CLUBS, CROSS, HEARTS, SPADES}
enum Rank {RANK_A, RANK_2 = 2, RANK_3, RANK_4, RANK_5, RANK_6, RANK_7, RANK_8, RANK_9, RANK_10, RANK_J, RANK_Q, RANK_K}

var suit
var rank

func _init(new_suit, new_rank):
	suit = Suit[new_suit]
	rank = Rank[new_rank]

func get_suit():	
	return suit

func get_rank():	
	return rank

	
func get_suit_str():	
	var index = Suit.values().find(suit)
	return Suit.keys()[index]

func get_rank_str():	
	var index = Rank.values().find(rank)
	return Rank.keys()[index]


func get_card_min_value():
	if rank == Rank.RANK_A:
		return 1
	elif rank == Rank.RANK_J || rank == Rank.RANK_Q || rank == Rank.RANK_K:
		return 10
	else: 
		return int(rank)


func get_card_max_value():
	if rank == Rank.RANK_A:
		return 11
	elif rank == Rank.RANK_J || rank == Rank.RANK_Q || rank == Rank.RANK_K:
		return 10
	else: 
		return int(rank)