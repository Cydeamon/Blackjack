extends Area2D

var smooth_speed = 0.287
var move_speed = 20
var move_destination
var card: PlayingCard

func _process(delta):
	if (move_destination):
		var position_difference = move_destination - position
		var smoothed_velocity = position_difference * smooth_speed * delta * move_speed
		position += smoothed_velocity

		if position == move_destination:
			move_destination = null

func set_card(new_card):
	card = new_card
	update_label()

func update_label():
	$CardLabel.text = str(card.get_suit()) + "\n" + str(card.get_rank())

func move_to(position):
	move_destination = position
