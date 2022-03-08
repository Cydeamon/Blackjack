class_name Player

var cards = []


func set_cards(new_cards):
    cards = new_cards


func get_cards():
    return cards


func add_card(card):
    cards.push_back(card)


func clear_cards():
    cards = []


func calc_points():
    var min_value = 0
    var max_value = 0
    var value = 0

    for card in cards:
        min_value += card.card.get_card_min_value()
        max_value += card.card.get_card_max_value()

    if max_value > 21:
        value = min_value
    else:
        value = min_value

    return value