extends AnimatedSprite


var is_green : bool


func _ready() -> void:
	go_red()
#

func go_red() -> void:
	play("Red")
	is_green = false
#

func go_green() -> void:
	play("Green")
	is_green = true
#

func down() -> void:
	modulate.v = .5
#

func up() -> void:
	modulate.v = 1
#
