extends Node2D

var deck = []				# Deck (all 50 cards)
var deck_cards_taken = []	# Cards that was taken from deck (indexes)
var card_height = 128
var game_is_running = false
var bet = 0
var min_bet = 50
var game_was_started = false
var max_chips = 15
var max_bet = 5000

var menu_mode = true
var bet_is_set = false
var menu_options = []
var current_menu_option_index = 0
var resume_menu_texture = preload("res://assets/Menu options/resume.png")
var start_menu_texture = preload("res://assets/Menu options/start.png")


var player = Player.new()
var enemy = Enemy.new()

var bet_chips

var chips_textures = {
	500: preload("res://assets/Chips/chip_500.png"),
	100: preload("res://assets/Chips/chip_100.png"),
	25: preload("res://assets/Chips/chip_25.png"),
	10: preload("res://assets/Chips/chip_10.png"),
	5: preload("res://assets/Chips/chip_5.png"),
	1: preload("res://assets/Chips/chip_1.png")
}

### SOUNDS
var sound_win = preload("res://assets/sounds/win.wav")
var sound_lose = preload("res://assets/sounds/lose.wav")
var sound_draw = preload("res://assets/sounds/draw.wav")

var sounds_chips = {
	0: preload("res://assets/sounds/chip1.wav"),
	1: preload("res://assets/sounds/chip2.wav")
}

var sounds_cards = {
	0: preload("res://assets/sounds/card1.wav"),
	1: preload("res://assets/sounds/card2.wav"),
	2: preload("res://assets/sounds/card3.wav")
}


###########################################################################################
##################################### GODOT FUNCTIONS #####################################

func _ready():
	menu_options = $UI/Menu/MenuOptions/.get_children()

	randomize()
	
	enemy.connect("give_me_card", self, "give_card_to_enemy", [false])
	enemy.set_timer($Timers/GiveEnemyCardTimer)

	init_menu()



func _process(_delta):
	if !game_is_running && bet_is_set:		
		game_is_running = true
		give_card_to_player()
		give_card_to_player()
		give_card_to_enemy(true)
		give_card_to_enemy()


	if game_is_running:
		enemy.check_ready()

		if enemy.is_ready && player.is_ready:
			player.is_ready = false
			enemy.show_cards()
			$UI/GameUI/EnemyPointsLabel.show()
			compare_results()


###########################################################################################
##################################### CUSTOM FUNCTIONS ####################################

# (Re)init game
func init():
	reset_bet()
	game_is_running = false

	deck_cards_taken = []
	player.reset()
	enemy.reset()

	$UI/GameUI/BetMoneyLabel.text = "0$"
	bet = 0
	bet_chips = {
		500: 0,
		100: 0,
		25: 0,
		10: 0,
		5: 0,
		1: 0
	}

	draw_bet_chips()
	draw_player_chips()

	$UI/GameUI/PlayerMoneyLabel.text = str(player.money) + "$"

	$UI/GameUI/PlayerPointsLabel.text = '0'
	$UI/GameUI/EnemyPointsLabel.text = '0'

	$UI/GameUI/MessageBackground.hide()
	$UI/GameUI/VictoryMessage.hide()

	$UI/GameUI/NoteLabel.text = "Minimal bet is " + str(min_bet) + "$"
	$UI/GameUI/ReadyButton.set_disabled(true)

	$UI/GameUI/EnemyPointsLabel.hide()


func reset_bet():
	bet = 0
	bet_is_set = false
	$UI/GameUI/ReadyButton.text = "Bet"

func start_game():
	player.money = 5000
	draw_player_chips()
	init_deck()
	init()


func update_menu():
	var indicator = $UI/Menu/current_option_indicator
	var current_menu_option = menu_options[current_menu_option_index]
	
	for i in menu_options.size():
		if (i == current_menu_option_index):
			current_menu_option.position.x = 12
		else:
			menu_options[i].position.x = 0

	indicator.transform = current_menu_option.get_global_transform_with_canvas() 
	indicator.position.x -= 12
	indicator.position.y += current_menu_option.offset.y


func select_next_menu_option():
	while true:
		current_menu_option_index += 1

		if current_menu_option_index >= menu_options.size():
			current_menu_option_index = 0

		if menu_options[current_menu_option_index].visible:
			break;

	update_menu()


func select_prev_menu_option():

	while true:
		current_menu_option_index -= 1
	
		if current_menu_option_index < 0:
			current_menu_option_index = menu_options.size() - 1

		if menu_options[current_menu_option_index].visible:
			break;
	
	update_menu()


func init_menu():
	$UI/Menu/.visible = true
	menu_mode = true
	current_menu_option_index = 0
	update_menu()

func close_menu():
	menu_mode = false
	$UI/Menu/.visible = false


# Init deck with all possible cards
func init_deck():
	deck = []

	for suit in PlayingCard.Suit:
		for rank in PlayingCard.Rank:
			deck.push_back(PlayingCard.new(suit, rank))


# Give card to player and move it to center of screen
func give_card_to_player():	
	
	if game_is_running && !player.is_ready:
		$SoundsPlayer.stream = sounds_cards[randi() % (sounds_cards.size() - 1)]
		$SoundsPlayer.play()
		
		var card = preload('Card.tscn').instance()
		card.position = $CardDeck/CardDeckSprite.position
		card.set_card(take_random_card_from_deck())
		$CardsLayer.add_child(card)
		player.add_card(card)
		card.flip()
		move_cards_to_center(get_viewport().get_visible_rect().size.y - card_height - 15, player.get_cards())
		$UI/GameUI/PlayerPointsLabel.text = str(player.calc_points());

		if player.calc_points() > 21:
			_on_ReadyButton_pressed()


# Give card to enemy and move it to center of screen
func give_card_to_enemy(front_face_visible = false):
	if game_is_running:		
		$SoundsPlayer.stream = sounds_cards[randi() % (sounds_cards.size() - 1)]
		$SoundsPlayer.play()

		var card = preload('Card.tscn').instance()
		card.position = $CardsSpawnPosition.position
		card.set_front_face_visible(front_face_visible)
		card.set_card(take_random_card_from_deck())
		$CardsLayer.add_child(card)
		enemy.add_card(card)
		move_cards_to_center(10, enemy.get_cards())
		$UI/GameUI/EnemyPointsLabel.text = str(enemy.calc_points());

	
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
	elif player_score == enemy_score:
		message = "draw"
	else:
		message = "lost"

	if message == "victory" && player_score == 21 && player.cards.size() == 2:
		message = "blackjack"

	show_message(message)

	if message == "victory":
		player.money += bet*2
		
	if message == "blackjack":
		player.money += bet + bet * 1.5;

	if message == "draw":
		player.money += bet

	if message == "lost":
		enemy.increase_limit()
	else:
		enemy.decrease_limit()

	if message == "blackjack":
		message = "victory"


func show_message(message):
	$UI/GameUI/MessageBackground.show()
	$UI/GameUI/VictoryMessage.show()

	if message == "draw":
		$WinLoseSounds.stream = sound_draw
	elif message == "victory":
		$WinLoseSounds.stream = sound_win
	elif message == "lost":
		$WinLoseSounds.stream = sound_lose

	$WinLoseSounds.play()

	$UI/GameUI/VictoryMessage.set_texture(load("res://assets/" + message + "_msg.png"))
	$AnimationPlayer.current_animation = "show_victory_message"
	$AnimationPlayer.play()
	
	
	
func draw_player_chips():
	delete_children($PlayerChips)
	draw_chips(get_player_chips(), $PlayerChips, "player")
	
	
func draw_chips(chips_amount, parent_node, mode):
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

			chip.chip_value = chip_value
			chip.connect("mouse_exited", self, "clear_note_text")

			if mode == "player": 
				chip.connect("mouse_entered", self, "show_bet_note", [chip])

				if i == amount - 1:
					chip.connect("mouse_clicked", self, "add_to_bet")
			
			if mode == "bet": 
				chip.connect("mouse_entered", self, "show_reduce_bet_note", [chip])
				chip.connect("mouse_clicked", self, "remove_from_bet")

			
			chip_position.x -= (texture.get_width() + 2) * x_offset
			chip_position.y -= ((texture.get_height() + 2) * y_offset) + i * 2

			chip_position.x += randi() % 4 - 2

			chip.position = chip_position
		
			chip.get_node("Sprite").set_texture(texture)
			group_node.add_child(chip)

			if i >= max_chips: 
				break
		
		x_offset += 1
		cur_stack += 1
		
		parent_node.add_child(group_node)
		parent_node.move_child(group_node, 0)



func show_bet_note(chip):
	$UI/GameUI/NoteLabel.text = "Add " + str(chip.chip_value) + "$ to the bet and exchange chips"
	$SoundsPlayer.stream = sounds_chips[randi() % (sounds_chips.size() - 1)]
	$SoundsPlayer.play()


	
func get_player_chips():
	var player_money = player.money	
	var result = recalc_chips(player_money)

	if result[500] > max_chips:
		result[500] = max_chips
	if result[100] > max_chips:
		result[100] = max_chips
	if result[25] > max_chips:
		result[25] = max_chips
	if result[10] > max_chips:
		result[10] = max_chips
	if result[5] > max_chips:
		result[5] = max_chips
	if result[1] > max_chips:
		result[1] = max_chips

	return result 



func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
			
			
			
func clear_note_text():
	$UI/GameUI/NoteLabel.text = ""



func show_reduce_bet_note(chip):
	$UI/GameUI/NoteLabel.text = "Remove " + str(chip.chip_value) + "$ from the bet"
	$SoundsPlayer.stream = sounds_chips[randi() % (sounds_chips.size() - 1)]
	$SoundsPlayer.play()

func remove_from_bet(params):
	if !bet_is_set:
		var chip = params[0]

		bet -= int(chip.chip_value)
		player.money += int(chip.chip_value)
		
		bet_chips[chip.chip_value] -= 1
		draw_player_chips()
		draw_bet_chips()
		$UI/GameUI/BetMoneyLabel.text = str(bet) + "$"
		$UI/GameUI/PlayerMoneyLabel.text = str(player.money) + "$"
		check_bet()

		if bet < min_bet:
			$UI/GameUI/NoteLabel.text = "Minimal bet is " + str(min_bet) + "$"

func add_to_bet(params):
	if !bet_is_set:
		var chip = params[0]

		if bet + int(chip.chip_value) <= max_bet:
			bet += int(chip.chip_value)
			player.money -= int(chip.chip_value)
			bet_chips[chip.chip_value] += 1
			draw_player_chips()
			draw_bet_chips()
			$UI/GameUI/BetMoneyLabel.text = str(bet) + "$"
			$UI/GameUI/PlayerMoneyLabel.text = str(player.money) + "$"
			check_bet()
		else:
			$UI/GameUI/NoteLabel.text = "Max bet is " + str(max_bet) + "$"

func recalc_chips(money):	
	var prev_chip_value = null
	var chips = {
		500: 0,
		100: 0,
		25:  0,
		10:  0,
		5:   0,
		1:   0
	}	

	for chip_value in chips:
		var chips_amount = int(money / int(chip_value))
		money -= chips_amount * chip_value
		
		if chips_amount <= 2 && prev_chip_value && chips[prev_chip_value] > 1:
			var temp_money = int(prev_chip_value) * 1
			chips[prev_chip_value] -= 1
			chips_amount = int(temp_money / int(chip_value))
			temp_money -= chips_amount * int(chip_value)
			money += temp_money
		
		chips[chip_value] = chips_amount
		prev_chip_value = chip_value

	return chips


func check_bet():
	if bet >= min_bet:
		$UI/GameUI/ReadyButton.set_disabled(false)



func draw_bet_chips():
	delete_children($BetChips)
	draw_chips(bet_chips, $BetChips, "bet")

func gameover():
	current_menu_option_index = 0
	update_menu()

	game_is_running = false
	game_was_started = false
	menu_mode = true

	$UI/Menu/gameover_sprite.visible = true
	$UI/Menu/MenuOptions/start_resume_game.texture = start_menu_texture
	$UI/Menu/MenuOptions/new_game.visible = false
	$UI/Menu.visible = true

###########################################################################################
######################################### SIGNALS #########################################

func _on_CardDeck_input_event(_viewport:Node, event:InputEvent, _shape_idx:int):
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		if game_is_running:
			give_card_to_player()


func _on_ReadyButton_pressed():
	if !bet_is_set:
		bet_is_set = true
		$UI/GameUI/ReadyButton.text = "STAND"
	else:
		player.set_ready(true)
		$UI/GameUI/ReadyButton.text = "WAITING"

	


func _on_AnimationPlayer_animation_finished(anim_name:String):
	if player.money < min_bet:
		gameover()

	if anim_name == "show_victory_message":
		$AnimationPlayer.seek(0)
		move_cards_to_center(-200, enemy.get_cards())
		move_cards_to_center(get_viewport().get_visible_rect().size.y + 200, player.get_cards())

		init()
		var t = Timer.new()
		t.set_wait_time(0.5)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
	

func _on_CardDeck_mouse_entered():
	$UI/GameUI/NoteLabel.text = "Take a card from the deck"


func _on_ReadyButton_mouse_entered():
	$UI/GameUI/NoteLabel.text = "No more cards"

func _unhandled_input(event):
	if menu_mode && event.is_action_pressed("ui_down"):
		select_next_menu_option()
	elif menu_mode && event.is_action_pressed("ui_up"):
		select_prev_menu_option()
	elif menu_mode && event.is_action_pressed("ui_cancel") && game_was_started:
		close_menu()
	elif !menu_mode && event.is_action_pressed("ui_cancel"):
		init_menu()
		$UI/Menu/MenuOptions/start_resume_game.texture = resume_menu_texture

	elif menu_mode && event.is_action_pressed("ui_accept"):
		process_menu_select()
		
func process_menu_select():
	match (menu_options[current_menu_option_index].name):
		"start_resume_game": 
			close_menu()
			start_game()
			game_was_started = true
			$UI/Menu/MenuOptions/new_game.visible = true
		"new_game": 
			init()
			start_game()
			close_menu()
		"exit_game": 
			get_tree().quit()


func _on_menu_option_mouse_event(viewport:Node, event:InputEvent, shape_idx:int, menu_index:int):
	current_menu_option_index = menu_index
	
	if event is InputEventMouseButton && event.is_pressed():
		process_menu_select()

	if event is InputEventMouseMotion:
		update_menu()


func _on_MusicPlayer_finished():
	$MusicPlayer.play(0)
