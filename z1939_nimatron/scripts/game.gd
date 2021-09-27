extends Node2D


signal player_turn()
signal cpu_turn(heaps)
signal line_reset()


var is_player_turn : bool = true
var last_line_that_get_off : Node2D = null


func _ready() -> void:
	pass
#	for line in get_children():
#		line.connect("line_reset", self, "line_reset")


func get_heaps() -> PoolByteArray:
	var heaps : PoolByteArray = []
	for line in get_children():
		heaps.append(line.on_count())
	return heaps


func turn_off(line_index : int) -> void:
	get_child(line_index).turn_off()
	last_line_that_get_off = get_child(line_index)


func submit() -> void:
	last_line_that_get_off.submit()
	if is_player_turn:
		is_player_turn = false
		emit_signal("cpu_turn", get_heaps())
	else:
		emit_signal("player_turn")
		is_player_turn = true


func line_reset() -> void:
	emit_signal("line_reset")


func reset(line_index : int) -> void:
	get_child(line_index).reset()
