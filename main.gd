class_name Main
extends Node


var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var line_buttons_state : PoolByteArray = [false, false, false, false]
var this_turn_lights : Array = []
var previous_line : int = 0


func _ready() -> void:
	rng.randomize()
#	$Stars/AnimationPlayer.play("Initiate")
	VisualServer.set_default_clear_color(Color(.0, .0, .0, .0))
	var err : int = 0
	err = get_tree().root.connect("size_changed", self, "_size_changed", [], CONNECT_DEFERRED)
	if err:
		printerr("ERROR! ", err)
	_size_changed()
	$Panel.visible = get_tree().get_root().transparent_bg


func _input(event : InputEvent) -> void:
	if event.is_action_released("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
		
	elif event.is_action_released("borderless"):
		OS.window_borderless = not OS.window_borderless
		
	elif event.is_action_released("transparent"):
		var new_state : bool = not get_tree().get_root().transparent_bg
		get_tree().get_root().transparent_bg = new_state
		$Panel.visible = new_state
		
	elif event.is_action_released("quit"):
		get_tree().quit(0)



func _size_changed() -> void:
	var viewport : Viewport = get_tree().root as Viewport
	var panel : Panel = $Panel as Panel
	
	panel.rect_position = -viewport.size
	panel.rect_size = viewport.size * 2


func _on_CircleInput_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		player_circle_input(event.position + $CircleInput.rect_position)


func _on_SubmitButton_pressed() -> void:
	this_turn_lights.clear()
	$CircleInput.visible = false
	$Submit.go_red()
	ai_turn()


func player_circle_input(mouse_pos: Vector2) -> void:
	var line_idx : int = player_circle_input_check(mouse_pos)
	if line_idx > -1:
		extinguish(line_idx)
	if this_turn_lights:
		$Submit.go_green()
	else:
		$Submit.go_red()


func player_circle_input_check(mouse_pos : Vector2) -> int:
	var center : Vector2 = $Game.global_position
	for point_node in $CircleInput.get_children():
		var point : Position2D = point_node as Position2D
		var point_dis : float = center.distance_squared_to(point.global_position)
		var mouse_dis : float = center.distance_squared_to(mouse_pos)
		if mouse_dis < point_dis:
			return point.get_index()
	return -1


func ai_turn() -> void:
	# Initial data.
	var heaps : PoolByteArray = get_heaps()
	var my_move : PoolByteArray = Nim.play(heaps, rng)
	var moves_left : int = Nim.moves_left(heaps)
	var time : float = rng.randf_range(moves_left-1, moves_left)
	# Thinking animation.
	var anim_player : AnimationPlayer = $Stars/AnimationPlayer
	anim_player.get_animation("Thinking").loop = true
	anim_player.play("Thinking")
	yield(get_tree().create_timer(time, false), "timeout")
	anim_player.get_animation("Thinking").loop = false
	var err : int = 0
	err = anim_player.connect("animation_finished", self,"ai_move", [my_move], CONNECT_DEFERRED | CONNECT_ONESHOT)
	if err:
		printerr("ERROR! ", err)


func ai_move(_anim_name : String, move: PoolByteArray) -> void:
	for _i in range(move[1]):
		yield(get_tree().create_timer(.7, false), "timeout")
		extinguish(move[0])
	this_turn_lights.clear()
	$CircleInput.visible = true


func extinguish(line_idx : int) -> void:
	if previous_line != line_idx:
		this_turn_lights_back_on()
		previous_line = line_idx
		this_turn_lights.clear()
	
	for light_bulb in $Game.get_child(line_idx).get_children():
		var l : Sprite = (light_bulb as Sprite)
		if l.modulate.a == 1:
			l.modulate.a = .2
			this_turn_lights.append(l)
			return
	
	this_turn_lights_back_on()
	this_turn_lights.clear()


func this_turn_lights_back_on() -> void:
	for light_bulb in this_turn_lights:
		(light_bulb as Sprite).modulate.a = 1


func get_heaps() -> PoolByteArray:
	var heaps : PoolByteArray = [0, 0, 0, 0]
	
	for line_idx in range(4):
		var line_node : Node = $Game.get_child(line_idx) as Node
		for light_bulb in line_node.get_children():
			if (light_bulb as Sprite).modulate.a == 1:
				heaps[line_idx] += 1
	
	return heaps








