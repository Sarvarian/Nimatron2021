class_name Main
extends Node


var line_buttons_state : PoolByteArray = [false, false, false, false]
var this_turn_lights : Array = []
var previous_line : int = 0
var player : Player = Player.new(self)


func _ready() -> void:
	var err : int = 0
	err = $PlayerInput/Line0.connect("pressed", self, "_on_Line_pressed", [0], CONNECT_DEFERRED)
	err = $PlayerInput/Line1.connect("pressed", self, "_on_Line_pressed", [1], CONNECT_DEFERRED)
	err = $PlayerInput/Line2.connect("pressed", self, "_on_Line_pressed", [2], CONNECT_DEFERRED)
	err = $PlayerInput/Line3.connect("pressed", self, "_on_Line_pressed", [3], CONNECT_DEFERRED)
	if err:
		printerr("ERROR!")


func _on_Line_pressed(line_idx : int) -> void:
	line_buttons_state[line_idx] = true
	player.line_pressed(line_idx)


func _on_CircleInput_gui_input(event : InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var pos : Vector2 = (event as InputEventMouseButton).position


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

