extends Node2D

var deck = []				# Deck (all 50 cards)
var deck_cards_taken = []	# Cards that was taken from deck (indexes)
var card_height = 128
var game_is_running = false

var player = Player.new()
var enemy = Enemy.new()

var chips_textures = {
	500: preload("res://assets/chip_500.png"),
	100: preload("res://assets/chip_100.png"),
	25: preload("res://assets/chip_25.png"),
	10: preload("res://assets/chip_10.png"),
	5: preload("res://assets/chip_5.png"),
	1: preload("res://assets/chip_1.png")
}


###########################################################################################
##################################### GODOT FUNCTIONS #####################################

func _ready():
	randomize()
	
	enemy.connect("give_me_card", self, "give_card_to_enemy")
	enemy.set_timer($Timers/GiveEnemyCardTimer)

	init_deck()
	init()
	draw_player_chips()


func _process(_delta):
	if game_is_running:
		enemy.check_ready()

		if enemy.is_ready && player.is_ready:
			player.is_ready = false
			enemy.show_cards()
			$UI/EnemyPointsLabel.show()
			compare_results()


###########################################################################################
##################################### CUSTOM FUNCTIONS ####################################

# (Re)init game
func init():
	game_is_running = false

	deck_cards_taken = []
	player.reset()
	enemy.reset()

	$UI/PlayerPointsLabel.text = '0'
	$UI/EnemyPointsLabel.text = '0'

	$UI/MessageBackground.hide()
	$UI/VictoryMessage.hide()

	$Timers/TimeoutBeforeStart.start()
	$UI/ReadyButton.text = "READY"

	$UI/EnemyPointsLabel.hide()


# Init deck with all possible cards
func init_deck():
	deck = []

	for suit in PlayingCard.Suit:
		for rank in PlayingCard.Rank:
			deck.push_back(PlayingCard.new(suit, rank))


# Give card to player and move it to center of screen
func give_card_to_player():
	if game_is_running && !player.is_ready:
		var card = preload('Card.tscn').instance()
		card.position = $CardDeck/CardDeckSprite.position
		card.set_card(take_random_card_from_deck())
		$CardsLayer.add_child(card)
		player.add_card(card)
		card.flip()
		move_cards_to_center(get_viewport().get_visible_rect().size.y - card_height - 15, player.get_cards())
		$UI/PlayerPointsLabel.text = str(player.calc_points());

		if player.calc_points() > 21:
			_on_ReadyButton_pressed()


# Give card to enemy and move it to center of screen
func give_card_to_enemy():
	if game_is_running:
		var card = preload('Card.tscn').instance()
		card.position = $CardsSpawnPosition.position
		card.set_front_face_visible(false)
		card.set_card(take_random_card_from_deck())
		$CardsLayer.add_child(card)
		enemy.add_card(card)
		move_cards_to_center(10, enemy.get_cards())
		$UI/EnemyPointsLabel.text = str(enemy.calc_points());

	
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
	var space_between = -69
	var card_width = 85
	var space_needed = (cards.size() * (card_width + space_between)) - space_between
	var start_position : int = (viewport_width - space_needed) / 2

	if (start_position < 98):
		start_position = 98

	for i in cards.size():
		var draw_x = start_position + (i * (card_width))

		if i != 0:
			draw_x += space_between * i

		cards[i].move_to(Vector2(draw_x, draw_y))

		draw_y += 2

# Compare results of players
func compare_results():
	var player_score = player.calc_points()
	var enemy_score = enemy.calc_points()

	var enemy_overdraft = enemy_score > 21
	var player_overdraft = player_score > 21

	var message

	if player_overdraft && enemy_overdraft:
		message = "draw"
	elif player_overdraft && !enemy_overdraft:
		message = "lost"
	elif !player_overdraft && enemy_overdraft:
		message = "victory"
	elif player_score > enemy_score:
		message = "victory"
	else:
		message = "lost"

	show_message(message)

	if message == "lost":
		enemy.increase_limit()
	else:
		enemy.decrease_limit()



func show_message(message):
	$UI/MessageBackground.show()
	$UI/VictoryMessage.show()

	$UI/VictoryMessage.set_texture(load("res://assets/" + message + "_msg.png"))
	$AnimationPlayer.current_animation = "show_victory_message"
	$AnimationPlayer.play()
	
	
	
func draw_player_chips():
	delete_children($PlayerChips)
	draw_chips(get_player_chips(player), $PlayerChips)
	
	
func draw_chips(chips_amount, parent_node):
	var x_offset = 0
	var y_offset = 0
	var chips_in_row = 3
	var cur_stack = 0
	
	for chip_value in chips_amount:
		var amount = chips_amount[chip_value]
		var texture = chips_textures[chip_value]
		var group_node = Node2D.new()

		if (cur_stack) % chips_in_row == 0:
			y_offset += 1
			x_offset = 0

		for i in amount:
			var chip = preload("res://Chip.tscn").instance()			
			var chip_position = Vector2.ZERO
			
			chip_position.x -= (texture.get_width() + 2) * x_offset
			chip_position.y -= ((texture.get_height() + 2) * y_offset) + i * 2
			chip.position = chip_position
		
			chip.get_node("Sprite").set_texture(texture)
			group_node.add_child(chip)
		
		x_offset += 1
		cur_stack += 1
		
		parent_node.add_child(group_node)
		parent_node.move_child(group_node, 0)

	
func get_player_chips(player):
	var result = {
		500: 0,
		100: 0,
		25:  0,
		10:  0,
		5:   0,
		1:   0
	}	
	
	var player_money = player.money
	var prev_chip_value = null
	
	for chip_value in result:
		var chips_amount = int(player_money / int(chip_value))
		player_money -= chips_amount * chip_value
		
		if chips_amount == 0 && prev_chip_value && result[prev_chip_value] > 2:
			var temp_money = int(prev_chip_value) * 2
			result[prev_chip_value] -= 2
			chips_amount = int(temp_money / int(chip_value))
			temp_money -= chips_amount * int(chip_value)
			player_money += temp_money
		
		result[chip_value] = chips_amount
		prev_chip_value = chip_value
	
	return result 

func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
			
			
###########################################################################################
######################################### SIGNALS #########################################

func _on_CardDeck_input_event(_viewport:Node, event:InputEvent, _shape_idx:int):
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		if game_is_running:
			give_card_to_player()


func _on_ReadyButton_pressed():
	player.set_ready(true)
	$UI/ReadyButton.text = "WAITING"


func _on_AnimationPlayer_animation_finished(anim_name:String):
	if anim_name == "show_victory_message":
		$AnimationPlayer.seek(0)
		move_cards_to_center(-200, enemy.get_cards())
		move_cards_to_center(get_viewport().get_visible_rect().size.y + 200, player.get_cards())

		var t = Timer.new()
		t.set_wait_time(0.5)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		init()


func _on_TimeoutBeforeStart_timeout():
	game_is_running = true

	give_card_to_player()
	give_card_to_player()
	give_card_to_enemy()
	give_card_to_enemy()
