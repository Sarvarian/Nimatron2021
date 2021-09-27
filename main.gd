class_name Main
extends Node


var line_buttons_state : PoolByteArray = [false, false, false, false]
var this_turn_lights : Array = []
var previous_line : int = 0


func _on_CircleInput_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		player_circle_input(event.position + $CircleInput.rect_position)


func _on_SubmitButton_released() -> void:
	var button : TouchScreenButton = $Submit/SubmitButton as TouchScreenButton
	var mouse_pos : Vector2 = button.get_local_mouse_position()
	if mouse_pos.x < 0 or mouse_pos.y < 0 or mouse_pos.x > button.position.x or mouse_pos.y > button.y:
		print("out")
	else:
		print("in")


func player_circle_input(mouse_pos: Vector2) -> void:
	var line_idx : int = player_circle_input_check(mouse_pos)
	if line_idx > -1:
		extinguish(line_idx)


func player_circle_input_check(mouse_pos : Vector2) -> int:
	var center : Vector2 = $Game.global_position
	for point_node in $CircleInput.get_children():
		var point : Position2D = point_node as Position2D
		var point_dis : float = center.distance_squared_to(point.global_position)
		var mouse_dis : float = center.distance_squared_to(mouse_pos)
		if mouse_dis < point_dis:
			return point.get_index()
	return -1


func extinguish(line_idx : int) -> void:
	if previous_line != line_idx:
		light_on_line(previous_line)
		previous_line = line_idx
		this_turn_lights.clear()
	
	for light_bulb in $Game.get_child(line_idx).get_children():
		var l : Sprite = (light_bulb as Sprite)
		if l.modulate.a == 1:
			l.modulate.a = .2
			this_turn_lights.append(l)
			return
	
	light_on_line(line_idx)
	this_turn_lights.clear()


func light_on_line(line_idx : int) -> void:
	for light_bulb in $Game.get_child(line_idx).get_children():
		(light_bulb as Sprite).modulate.a = 1
