extends Player
class_name Enemy

signal give_me_card

var points_limit
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
    else:
        set_ready(true)

    decide_timer.set_wait_time(get_think_time())
    decide_timer.start()

func set_timer(timer):
    decide_timer = timer
    decide_timer.set_wait_time(get_think_time())
    decide_timer.connect("timeout", self, "ask_for_card")
    decide_timer.start()