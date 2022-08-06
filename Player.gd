class_name Player

var cards = []
var is_ready = false
var money = 5000

func set_cards(new_cards):
	cards = new_cards


func get_cards():
	return cards


func add_card(card):
	cards.push_back(card)


func clear_cards():
	for card in cards:
		card.hide()
		card.queue_free()

	cards = []


func calc_points():
	var sum = 0
	var aces_amount = 0

	for card in cards:
		sum += card.card.get_card_value()

		if card.card.get_card_value() == 11:
			aces_amount += 1
			
		if sum > 21:
			for i in aces_amount:
				sum -= 10
				aces_amount -= 1
				i = 0

				if sum <= 21:
					break

	return sum



func set_ready(val: bool):
	is_ready = val

		
func reset():
	clear_cards()
	is_ready = false
