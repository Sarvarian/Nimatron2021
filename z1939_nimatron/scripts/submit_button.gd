extends AnimatedSprite


func go_red() -> void:
	play("Red")
#

func go_green() -> void:
	play("Green")
#

func pressed() -> void:
	modulate.v = .5
#

func released() -> void:
	modulate.v = 1
#
