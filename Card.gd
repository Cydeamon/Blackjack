extends Area2D

var smooth_speed = 0.287
var move_speed = 15
var move_destination = null
var card: PlayingCard


func _process(delta):
	if position == move_destination:
		move_destination = null

	if (move_destination):
		var position_difference = move_destination - position
		var smoothed_velocity = position_difference * smooth_speed * delta * move_speed
		position += smoothed_velocity


func set_card(new_card):
	card = new_card
	update_suit()
	update_rank()


func update_rank():
	var rank = str(card.get_rank()).replace("RANK_", "")
	var suit = str(card.get_suit()).to_lower()

	$RankTop.text = rank
	$RankBottom.text = rank
	reset_sprites()

	if int(rank) >= 2 && int(rank) <= 10:
		show_pattern(rank, suit)

	if rank == "A":
		show_central_image("res://assets/" + suit + "_a.png")

	if rank == "J" || rank == "Q" || rank == "K":
		show_central_image("res://assets/" + rank.to_lower() + ".png")


func update_suit():
	var suit = str(card.get_suit()).to_lower()
	var image = Image.new()
	var image_texture = ImageTexture.new()

	image.load("res://assets/" + suit + "_small.png")
	image_texture.create_from_image(image)
	
	$SuitTop.set_texture(image_texture)
	$SuitBottom.set_texture(image_texture)


func show_central_image(texture):
	var image = Image.new()
	var image_texture = ImageTexture.new()

	image.load(texture)
	image_texture.create_from_image(image)
	$CentralImage.set_texture(image_texture)
	$CentralImage.show()


func show_pattern(rank, suit):
	var pattern_node = get_node("Pattern" + rank)
	var sprites = pattern_node.get_children()
	var image = Image.new()
	var image_texture = ImageTexture.new()

	image.load("res://assets/" + suit + "_medium.png")
	image_texture.create_from_image(image)

	for sprite in sprites:
		sprite.set_texture(image_texture)

	pattern_node.show()


func reset_sprites():
	$CentralImage.hide()
	$Pattern10.hide()
	$Pattern9.hide()
	$Pattern8.hide()
	$Pattern7.hide()
	$Pattern6.hide()
	$Pattern5.hide()
	$Pattern4.hide()
	$Pattern3.hide()
	$Pattern2.hide()


func move_to(position):
	move_destination = position
