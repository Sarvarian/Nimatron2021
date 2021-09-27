extends Node2D



func _ready() -> void:
	InputMap.add_action("full_screen")
	var event : InputEventKey = InputEventKey.new()
	event.scancode = KEY_F11
	InputMap.action_add_event("full_screen", event)
#	get_tree().get_root().set_transparent_background(true)


func _input(event : InputEvent) -> void:
	if event.is_action_pressed("full_screen"):
		if OS.window_fullscreen:
			OS.window_fullscreen = false
		else:
			OS.window_fullscreen = true


func reset_game() -> void:
	pass
