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
	var value = 0
	var aces_amount = 0

	for card in cards:
		var min_value = card.card.get_card_min_value()
		var max_value = card.card.get_card_max_value()

		if max_value == 11 && min_value == 1:
			aces_amount += 1

		if value + max_value > 21:
			value += min_value
		else:
			value += max_value

		if value > 21:
			for i in aces_amount:
				value -= 10
				aces_amount -= 1
				i = 0

				if value <= 21:
					break


	return value



func set_ready(val: bool):
	is_ready = val

		
func reset():
	clear_cards()
	is_ready = false
