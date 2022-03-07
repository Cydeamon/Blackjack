extends Node2D

var deck = []				# Deck (all 50 cards)
var deck_cards_taken = []	# Cards that was taken from deck (indexes)
var player_cards = []		# Player card (scene object)
var enemy_cards = []		# Enemy card (scene object)	
var card_height = 128

###########################################################################################
##################################### GODOT FUNCTIONS #####################################
func _ready():
	init_deck()
	init()
	
###########################################################################################
##################################### CUSTOM FUNCTIONS ####################################

# (Re)init game
func init():
	deck_cards_taken = []
	player_cards = []
	enemy_cards = []

# Init deck with all possible cards
func init_deck():
	deck = []
	for suit in PlayingCard.Suit:
		for rank in PlayingCard.Rank:
			deck.push_back(PlayingCard.new(suit, rank))


# Give card to player and move it to center of screen
func give_card_to_player():
	var card = preload('Card.tscn').instance()
	card.position = $CardDeck/CardDeckSprite.position
	card.set_card(take_random_card_from_deck())
	add_child(card)
	player_cards.push_back(card)
	move_cards_to_center(get_viewport().get_visible_rect().size.y - card_height - 10, player_cards)
	give_card_to_enemy()


# Give card to enemy and move it to center of screen
func give_card_to_enemy():
	var card = preload('Card.tscn').instance()
	card.position = $CardDeck/CardDeckSprite.position
	card.set_card(take_random_card_from_deck())
	add_child(card)
	enemy_cards.push_back(card)
	move_cards_to_center(10, enemy_cards)

	
# Get random card from deck
func take_random_card_from_deck():
	var random_card_index = randi() % deck.size() - 1

	while deck_cards_taken.has(random_card_index):
		random_card_index = randi() % deck.size() - 1

	var card = deck[random_card_index]
	deck_cards_taken.push_back(random_card_index)

	return card


# Animated transition of cards towards center of screen on specified Y position
func move_cards_to_center(draw_y, cards):
	var viewport_width = get_viewport().get_visible_rect().size.x
	var space_between = 5
	var card_width = 85
	var space_needed = (cards.size() * (card_width + space_between)) - space_between
	var start_position : int = (viewport_width - space_needed) / 2

	for i in cards.size():
		var draw_x = start_position + (i * (card_width))

		if i != 0:
			draw_x += space_between * i

		cards[i].move_to(Vector2(draw_x, draw_y))

			
###########################################################################################
######################################### SIGNALS #########################################

func _on_CardDeck_input_event(_viewport:Node, event:InputEvent, _shape_idx:int):
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		give_card_to_player()
