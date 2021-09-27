extends Node


signal turn_off(line_index)
signal submit()
signal start_thinking(time)


var my_move : PoolByteArray = [-1, -1]
var moves_left : int = 0
var time : float = 0
var remaining : int = 0


func cpu_turn(heaps : PoolByteArray) -> void:
	my_move = Nim.play(heaps)
	moves_left = Nim.moves_left(heaps)
	time = RNG.rng.randf_range(moves_left-1, moves_left)
	emit_signal("start_thinking", time)


func thinking_finished() -> void:
	remaining = my_move[1]
	$ExtinguisherTimer.start()


func _on_ExtinguisherTimer_timeout():
	emit_signal("turn_off", my_move[0])
	remaining -= 1
	if remaining > 0:
		$ExtinguisherTimer.start()
	else:
		emit_signal("submit")
