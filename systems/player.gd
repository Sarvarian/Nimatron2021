class_name Player
extends Reference


# reference from main.
var main : Node
# player turn check
var is_player_turn : bool = true
# input handling data
var this_frame_line_idx : int = 3
var last_frame_line_idx : int = 3
var chained_score : int = 0


func _init(main_node : Node) -> void:
	main = main_node


func line_pressed(line_idx : int) -> void:
	if not is_player_turn:
		return
	
	if line_idx == 3:
		new_frame(line_idx)
		return
	
	this_frame_line_idx = line_idx
	
	var score : int = chained_score
	if last_frame_line_idx != line_idx:
		score = 1
	
	for _i in range(score):
		main.extinguish(line_idx)


func new_frame(line_idx : int) -> void:
	if last_frame_line_idx == this_frame_line_idx:
		chained_score += 1
	else:
		chained_score = 1
	last_frame_line_idx = this_frame_line_idx
	this_frame_line_idx = line_idx
	main.extinguish(line_idx)
