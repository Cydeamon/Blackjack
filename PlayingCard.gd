class_name PlayingCard
enum Suit {CLUBS, CROSS, HEARTS, SPADES}
enum Rank {RANK_A, RANK_2, RANK_3, RANK_4, RANK_5, RANK_6, RANK_7, RANK_8, RANK_9, RANK_10, RANK_J, RANK_Q, RANK_K}

var suit
var rank

func _init(new_suit, new_rank):
	suit = new_suit
	rank = new_rank	

func get_suit():	
	return suit

func get_rank():	
	return rank