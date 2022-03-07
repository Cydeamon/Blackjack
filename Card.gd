extends Area2D

var card: PlayingCard

func set_card(new_card):
	card = new_card
	update_label()

func update_label():
	$CardLabel.text = str(card.get_suit()) + "\n" + str(card.get_rank())
