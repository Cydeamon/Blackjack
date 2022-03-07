extends Node2D

var deck = []				# Deck (all 50 cards)
var deck_cards_taken = []	# Cards that was taken from deck (indexes)

###########################################################################################
##################################### GODOT FUNCTIONS #####################################
func _ready():
	init()
	
###########################################################################################
##################################### CUSTOM FUNCTIONS ####################################

func init():
	init_deck()
	deck_cards_taken = []


func init_deck():
	deck = []
	for suit in PlayingCard.Suit:
		for rank in PlayingCard.Rank:
			deck.push_back(PlayingCard.new(suit, rank))


func give_player_card():
	var card = preload('Card.tscn').instance()
	card.position = $CardDeck/CardDeckSprite.position
	card.set_card(take_random_card_from_deck())
	add_child(card)
	
func take_random_card_from_deck():
	var random_card_index = randi() % deck.size() - 1

	while deck_cards_taken.has(random_card_index):
		random_card_index = randi() % deck.size() - 1

	var card = deck[random_card_index]
	deck_cards_taken.push_back(random_card_index)

	return card

			
###########################################################################################
######################################### SIGNALS #########################################

func _on_CardDeck_input_event(_viewport:Node, event:InputEvent, _shape_idx:int):
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		give_player_card()
