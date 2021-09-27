extends Node2D


signal line_reset()


var offes : Array = []


func turn_off() -> void:
	for light_bulb in get_children():
		if light_bulb.is_on:
			light_bulb.off()
			offes.append(light_bulb)
			return
	reset()


func reset() -> void:
	for light_bulb in offes:
		light_bulb.on()
	emit_signal("line_reset")


func on_count() -> int:
	var counter : int = 0
	for light_bulb in get_children():
		if light_bulb.is_on:
			counter += 1
	return counter


func submit() -> void:
	offes.clear()
