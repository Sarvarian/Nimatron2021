extends Sprite


var is_on : bool = true setget ,get_is_on


func _init() -> void:
	add_to_group("light_bulbs")


func on() -> void:
	modulate.a = 1
	is_on = true
	pass


func off() -> void:
	modulate.a = .2
	is_on = false
	pass


func get_is_on() -> bool:
	return is_on
