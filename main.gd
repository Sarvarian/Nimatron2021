class_name Main
extends Node


var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var line_buttons_state : PoolByteArray = [false, false, false, false]
var this_turn_lights : Array = []
var previous_line : int = 0
var anim_name : String = ""
var anim_pos : float = .0
var anim_light_queue : Array = [[], [], [], []]

onready var line_anim_players : Array = [
	$LineAnimationPlayer1,
	$LineAnimationPlayer2,
	$LineAnimationPlayer3,
	$LineAnimationPlayer4,
]
onready var line_anims : Array = [
	line_anim_players[0].get_animation("Anim"),
	line_anim_players[1].get_animation("Anim"),
	line_anim_players[2].get_animation("Anim"),
	line_anim_players[3].get_animation("Anim"),
]


func _ready() -> void:
	rng.randomize()
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
		return
		
	elif event.is_action_released("borderless"):
		OS.window_borderless = not OS.window_borderless
		return
		
	elif event.is_action_released("transparent"):
		var new_state : bool = not get_tree().get_root().transparent_bg
		get_tree().get_root().transparent_bg = new_state
		$Panel.visible = new_state
		return
		
	elif event.is_action_pressed("add"):
		var new_val : float = $Panel.modulate.a + .05
		$Panel.modulate.a = clamp(new_val, 0, 1)
		return
		
	elif event.is_action_pressed("sub"):
		var new_val : float = $Panel.modulate.a - .05
		$Panel.modulate.a = clamp(new_val, 0, 1)
		return
		
	elif event.is_action_pressed("hue_shift_left"):
		var new_val : float = $Panel.modulate.h + .05
		if new_val > 1:
			new_val -= 1
		elif new_val < 0:
			new_val += 1
		$Panel.modulate.h = new_val
		return
		
	elif event.is_action_pressed("hue_shift_right"):
		var new_val : float = $Panel.modulate.h - .05
		if new_val > 1:
			new_val -= 1
		elif new_val < 0:
			new_val += 1
		$Panel.modulate.h = new_val
		return
		
	elif event.is_action_pressed("value_high"):
		var new_val : float = $Panel.modulate.v + .05
		$Panel.modulate.v = clamp(new_val, 0, 1)
		return
		
	elif event.is_action_pressed("value_low"):
		var new_val : float = $Panel.modulate.v - .05
		$Panel.modulate.v = clamp(new_val, 0, 1)
		return
		
	elif event.is_action_pressed("saturation_more"):
		var new_val : float = $Panel.modulate.s + .05
		$Panel.modulate.s = clamp(new_val, 0, 1)
		return
		
	elif event.is_action_pressed("saturation_less"):
		var new_val : float = $Panel.modulate.s - .05
		$Panel.modulate.s = clamp(new_val, 0, 1)
		return
		
	elif event.is_action_released("quit"):
		get_tree().quit(0)
		return
		
	elif event.is_action_released("one"):
		player_direct_input(0)
		return
		
	elif event.is_action_released("two"):
		player_direct_input(1)
		return
		
	elif event.is_action_released("three"):
		player_direct_input(2)
		return
		
	elif event.is_action_released("four"):
		player_direct_input(3)
		return
		
	elif event.is_action_released("submit"):
		_on_SubmitButton_pressed()
		return


func _size_changed() -> void:
	var viewport := get_tree().root as Viewport
	var panel := $Panel as Panel
	
	panel.rect_position = -viewport.size
	panel.rect_size = viewport.size * 2


func _on_SubmitButton_button_down() -> void:
	var anim_player : AnimationPlayer = $Stars/AnimationPlayer
	anim_name = anim_player.current_animation
	if anim_name:
		anim_pos = anim_player.current_animation_position
	else:
		anim_pos = .0
	anim_player.stop(false)
	var err : int = 0
	err =  anim_player.connect("animation_finished", self, "restart_the_game", [], CONNECT_DEFERRED | CONNECT_ONESHOT)
	if err:
		printerr("ERROR! ", err)
	anim_player.play("Charging")


func _on_SubmitButton_button_up() -> void:
	var anim_player : AnimationPlayer = $Stars/AnimationPlayer
	if anim_player.current_animation == "Charging":
		anim_player.stop(true)
		anim_player.play("Off")
		anim_player.seek(.0)
		if anim_name:
			anim_player.play(anim_name)
			anim_player.seek(anim_pos)
	anim_player.disconnect("animation_finished", self, "restart_the_game")


func _on_SubmitButton_pressed() -> void:
	if $Submit.is_green:
		this_turn_lights.clear()
		$CircleInput.visible = false
		$Submit.go_red()
		ai_turn()


func _on_CircleInput_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		player_circle_input(event.position + $CircleInput.rect_position)


func player_direct_input(line_idx : int) -> void:
	extinguish(line_idx)
	if this_turn_lights:
		$Submit.go_green()
	else:
		$Submit.go_red()


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
#			l.modulate.a = .2
			anim_add_light_bulb(line_idx, l, true)
			this_turn_lights.append(l)
			return
	
	this_turn_lights_back_on()
	this_turn_lights.clear()


func this_turn_lights_back_on() -> void:
	var light_bulb := this_turn_lights.pop_back() as Node
	while light_bulb:
		anim_add_light_bulb(
			light_bulb.get_parent().get_index(),
			light_bulb,
			false
			)
		light_bulb = this_turn_lights.pop_back() as Node


func get_heaps() -> PoolByteArray:
	var heaps : PoolByteArray = [0, 0, 0, 0]
	for line_idx in range(4):
		var line_node : Node = $Game.get_child(line_idx) as Node
		for light_bulb in line_node.get_children():
			if (light_bulb as Sprite).modulate.a == 1:
				heaps[line_idx] += 1
	return heaps


func restart_the_game(_anim_name : String = "") -> void:
	var err : int = get_tree().reload_current_scene()
	if err:
		printerr("ERROR! ", err)


func anim_add_light_bulb(line_idx : int, light_bulb : Node, on : bool) -> void:
	var player := line_anim_players[line_idx] as AnimationPlayer
	var path := "Game/Line{}/{}:modulate".format(
		[line_idx, light_bulb.name], "{}")
	anim_light_queue[line_idx].append([on, path])
	if not player.is_playing():
		_on_LineAnimation_animation_finished("", line_idx)


func _on_LineAnimation_animation_finished(_anim_name, line_idx):
	var data = anim_light_queue[line_idx].pop_front()
	if not data: return
	(line_anims[line_idx] as Animation).track_set_path(0, data[1])
	if data[0]:
		(line_anim_players[line_idx] as AnimationPlayer).play("Anim")
	else:
		(line_anim_players[line_idx] as AnimationPlayer).play_backwards("Anim")






























