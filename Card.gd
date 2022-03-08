extends Area2D

var smooth_speed = 0.287
var move_speed = 15
var move_destination = null
var is_front_face_visible = true
var card: PlayingCard


func _process(delta):
	if position == move_destination:
		move_destination = null

	if move_destination:
		var position_difference = move_destination - position
		var smoothed_velocity = position_difference * smooth_speed * delta * move_speed
		position += smoothed_velocity


func set_card(new_card):
	card = new_card
	update_view()


func update_view():
	if is_front_face_visible:
		update_suit()
		update_rank()
	else:
		$CardContent/CardSprite.set_texture(load("res://assets/card_back.png"))
		
func set_front_face_visible(val :bool):
	is_front_face_visible = val

	$CardContent/RankTop.hide()
	$CardContent/RankBottom.hide()
	$CardContent/SuitBottom.hide()
	$CardContent/CentralImage.hide()
	$CardContent/SuitTop.hide()

	if is_front_face_visible:
		$CardContent/RankTop.show()
		$CardContent/RankBottom.show()
		$CardContent/SuitBottom.show()
		$CardContent/SuitTop.show()

		print(card.get_rank_str())
		if (card.get_rank_str() == "RANK_J" || card.get_rank_str() == "RANK_Q" || card.get_rank_str() == "RANK_K" || card.get_rank_str() == "RANK_A"):
			$CardContent/CentralImage.show()

func update_rank():
	var rank = card.get_rank_str().replace("RANK_", "")
	var suit = card.get_suit_str().to_lower()

	$CardContent/RankTop.text = rank
	$CardContent/RankBottom.text = rank
	reset_sprites()

	if int(rank) >= 2 && int(rank) <= 10:
		show_pattern(rank, suit)

	if rank == "A":
		show_central_image("res://assets/" + suit + "_a.png")

	if rank == "J" || rank == "Q" || rank == "K":
		show_central_image("res://assets/" + rank.to_lower() + ".png")


func update_suit():
	var suit = card.get_suit_str().to_lower()
	$CardContent/SuitTop.set_texture(load("res://assets/" + suit + "_small.png"))
	$CardContent/SuitBottom.set_texture(load("res://assets/" + suit + "_small.png"))


func show_central_image(texture):
	$CardContent/CentralImage.set_texture(load(texture))
	$CardContent/CentralImage.show()


func show_pattern(rank, suit):
	var pattern_node = get_node("CardContent/Pattern" + rank)
	var sprites = pattern_node.get_children()
	var resource = load("res://assets/" + suit + "_medium.png")

	for sprite in sprites:
		sprite.set_texture(resource)

	pattern_node.show()


func reset_sprites():
	$CardContent/CentralImage.hide()
	$CardContent/Pattern10.hide()
	$CardContent/Pattern9.hide()
	$CardContent/Pattern8.hide()
	$CardContent/Pattern7.hide()
	$CardContent/Pattern6.hide()
	$CardContent/Pattern5.hide()
	$CardContent/Pattern4.hide()
	$CardContent/Pattern3.hide()
	$CardContent/Pattern2.hide()


func move_to(position):
	move_destination = position

func flip():
	$CardContent.hide()
	$FlipAnimation.show()
	$FlipAnimation.play()
	$CardContent/CardSprite.set_texture(load("res://assets/card_front.png"))
	set_front_face_visible(true)
	update_view()

func _on_FlipAnimation_animation_finished():
	$FlipAnimation.hide()
	$CardContent.show()
