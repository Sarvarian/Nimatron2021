extends Node


signal turn_off(line_index)
signal reset(line_index)
signal submit()
signal go_red()
signal go_green()


var my_turn : bool = true
var do_move : bool = false
var last_line_index : int = 0
var line_buttons_state : PoolByteArray = [false, false, false, false]


func _process(_delta : float):
	if not my_turn:
		return
	if line_buttons_state[3]:
		turn_off()
		for i in line_buttons_state.size():
			line_buttons_state[i] = false


func submit() -> void:
	if my_turn and do_move:
		emit_signal("submit")
		my_turn = false
		do_move = false
		emit_signal("go_red")
#

func line_pressed(line_index : int) -> void:
	line_buttons_state[line_index] = true
#

func turn_off() -> void:
	for i in line_buttons_state.size():
		if line_buttons_state[i]:
			if i != last_line_index:
				emit_signal("reset", last_line_index)
			last_line_index = i
			do_move = true
			emit_signal("go_green")
			emit_signal("turn_off", i)
			return
#

func line_reset() -> void:
	do_move = false
	emit_signal("go_red")
#

func player_turn() -> void:
	my_turn = true
#
