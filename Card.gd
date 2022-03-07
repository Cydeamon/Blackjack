extends Area2D

var card: PlayingCard

func set_card(new_card):
	card = new_card
	update_label()

func update_label():
	var label_text = card.suit + "\n" + card.rank
	$CardLabel.text(label_text)
