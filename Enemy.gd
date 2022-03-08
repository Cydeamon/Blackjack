extends Player
class_name Enemy

signal give_me_card

var points_limit
var min_limit = 10
var max_limit = 21
var waiting = false
var decide_timer
var max_think_time = 5
var min_think_time = 2
    
func _init():
    randomize()
    points_limit = 14 + (randi() % 7)


func get_think_time():
    return min_think_time + (randi() % (max_think_time - min_think_time))


func ask_for_card():
    if !is_ready && calc_points() < points_limit:
        emit_signal('give_me_card')       

    decide_timer.set_wait_time(get_think_time())
    decide_timer.start()


func set_timer(timer):
    decide_timer = timer
    decide_timer.set_wait_time(get_think_time())
    decide_timer.connect("timeout", self, "ask_for_card")
    decide_timer.start()


func check_ready():
    if calc_points() >= points_limit:
        set_ready(true)


func increase_limit():
    points_limit += 1 + (randi() % 3)

    if points_limit > max_limit:
        points_limit = max_limit


func decrease_limit():
    points_limit -= 1 + (randi() % 3)

    if points_limit < min_limit:
        points_limit = min_limit


func show_cards():
    for card in cards:
        card.flip()